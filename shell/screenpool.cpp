/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "screenpool.h"
#include "primaryoutputwatcher.h"

#include <KWindowSystem>
#include <QDebug>
#include <QGuiApplication>
#include <QScreen>

ScreenPool::ScreenPool(const KSharedConfig::Ptr &config, QObject *parent)
    : QObject(parent)
    , m_configGroup(KConfigGroup(config, QStringLiteral("ScreenConnectors")))
    , m_primaryWatcher(new PrimaryOutputWatcher(this))
{
    connect(qGuiApp, &QGuiApplication::screenAdded, this, &ScreenPool::handleScreenAdded, Qt::UniqueConnection);
    connect(qGuiApp, &QGuiApplication::screenRemoved, this, &ScreenPool::handleScreenRemoved, Qt::UniqueConnection);
    connect(m_primaryWatcher, &PrimaryOutputWatcher::primaryOutputNameChanged, this, &ScreenPool::primaryOutputNameChanged, Qt::UniqueConnection);

    m_reconsiderOutputsTimer.setSingleShot(true);
    m_reconsiderOutputsTimer.setInterval(250);
    connect(&m_reconsiderOutputsTimer, &QTimer::timeout, this, &ScreenPool::reconsiderOutputs);

    m_configSaveTimer.setSingleShot(true);
    connect(&m_configSaveTimer, &QTimer::timeout, this, [this]() {
        m_configGroup.sync();
    });

    load(m_primaryWatcher->primaryScreen());
}

void ScreenPool::load(QScreen *primary)
{
    m_primaryConnector = QString();
    m_connectorForId.clear();
    m_idForConnector.clear();

    if (primary) {
        m_primaryConnector = primary->name();
        if (!m_primaryConnector.isEmpty()) {
            m_connectorForId[0] = m_primaryConnector;
            m_idForConnector[m_primaryConnector] = 0;
        }
    }

    // restore the known ids to connector mappings
    const auto keys = m_configGroup.keyList();
    for (const QString &key : keys) {
        QString connector = m_configGroup.readEntry(key, QString());
        const int currentId = key.toInt();
        if (!key.isEmpty() && !connector.isEmpty() && !m_connectorForId.contains(currentId) && !m_idForConnector.contains(connector)) {
            m_connectorForId[currentId] = connector;
            m_idForConnector[connector] = currentId;
        } else if (m_idForConnector.value(connector) != currentId) {
            m_configGroup.deleteEntry(key);
        }
    }

    // if there are already connected unknown screens, map those
    // all needs to be populated as soon as possible, otherwise
    // containment->screen() will return an incorrect -1
    // at startup, if it' asked before corona::addOutput()
    // is performed, driving to the creation of a new containment
    for (QScreen *screen : qGuiApp->screens()) {
        if (!m_idForConnector.contains(screen->name())) {
            insertScreenMapping(firstAvailableId(), screen->name());
        }
        handleScreenAdded(screen);
    }
}

ScreenPool::~ScreenPool()
{
    m_configGroup.sync();
}

QString ScreenPool::primaryConnector() const
{
    return m_primaryConnector;
}

void ScreenPool::setPrimaryConnector(const QString &primary)
{
    if (m_primaryConnector == primary) {
        return;
    }

    int oldIdForPrimary = m_idForConnector.value(primary, -1);
    if (oldIdForPrimary == -1) {
        // move old primary to new free id
        oldIdForPrimary = firstAvailableId();
        insertScreenMapping(oldIdForPrimary, m_primaryConnector);
    }

    m_idForConnector[primary] = 0;
    m_connectorForId[0] = primary;
    m_idForConnector[m_primaryConnector] = oldIdForPrimary;
    m_connectorForId[oldIdForPrimary] = m_primaryConnector;
    m_primaryConnector = primary;
    save();
}

void ScreenPool::save()
{
    QMap<int, QString>::const_iterator i;
    for (i = m_connectorForId.constBegin(); i != m_connectorForId.constEnd(); ++i) {
        m_configGroup.writeEntry(QString::number(i.key()), i.value());
    }
    // write to disck every 30 seconds at most
    m_configSaveTimer.start(30000);
}

void ScreenPool::insertScreenMapping(int id, const QString &connector)
{
    Q_ASSERT(!m_connectorForId.contains(id) || m_connectorForId.value(id) == connector);
    Q_ASSERT(!m_idForConnector.contains(connector) || m_idForConnector.value(connector) == id);

    if (id == 0) {
        m_primaryConnector = connector;
    }

    m_connectorForId[id] = connector;
    m_idForConnector[connector] = id;
    save();
}

int ScreenPool::id(const QString &connector) const
{
    return m_idForConnector.value(connector, -1);
}

QString ScreenPool::connector(int id) const
{
    Q_ASSERT(m_connectorForId.contains(id));

    return m_connectorForId.value(id);
}

QScreen *ScreenPool::screenForId(int id) const
{
    if (!m_connectorForId.contains(id)) {
        return nullptr;
    }

    // TODO: do QScreen bookeeping completely in screenpool, cache also available QScreens
    const QString name = m_connectorForId.value(id);
    for (QScreen *screen : qGuiApp->screens()) {
        if (screen->name() == name) {
            return screen;
        }
    }
    return nullptr;
}

QScreen *ScreenPool::screenForConnector(const QString &connector)
{
    for (QScreen *screen : qGuiApp->screens()) {
        if (screen->name() == connector) {
            return screen;
        }
    }
    return nullptr;
}

int ScreenPool::firstAvailableId() const
{
    int i = 0;
    // find the first integer not stored in m_connectorForId
    // m_connectorForId is the only map, so the ids are sorted
    foreach (int existingId, m_connectorForId.keys()) {
        if (i != existingId) {
            return i;
        }
        ++i;
    }

    return i;
}

QList<int> ScreenPool::knownIds() const
{
    return m_connectorForId.keys();
}

bool ScreenPool::noRealOutputsConnected() const
{
    if (qApp->screens().count() > 1) {
        return false;
    }

    return isOutputFake(m_primaryWatcher->primaryScreen());
}

bool ScreenPool::isOutputFake(QScreen *screen) const
{
    // On X11 the output named :0.0 is fake (the geometry is usually valid and whatever the geometry
    // of the last connected screen was), on wayland the fake output has no name and no geometry
    return screen->name() == QStringLiteral(":0.0") || screen->geometry().isEmpty() || screen->name().isEmpty();
}

bool ScreenPool::isOutputRedundant(QScreen *screen) const
{
    Q_ASSERT(screen);
    const QRect thisGeometry = screen->geometry();

    const int thisId = id(screen->name());

    // FIXME: QScreen doesn't have any idea of "this qscreen is clone of this other one
    // so this ultra inefficient heuristic has to stay until we have a slightly better api
    // logic is:
    // a screen is redundant if:
    //* its geometry is contained in another one
    //* if their resolutions are different, the "biggest" one wins
    //* if they have the same geometry, the one with the lowest id wins (arbitrary, but gives reproducible behavior and makes the primary screen win)
    const auto screens = qGuiApp->screens();
    for (QScreen *s : screens) {
        // don't compare with itself
        if (screen == s) {
            continue;
        }
        if (s->geometry().isNull()) {
            continue;
        }

        const QRect otherGeometry = s->geometry();

        const int otherId = id(s->name());

        if (otherGeometry.contains(thisGeometry, false)
            && ( // since at this point contains is true, if either
                 // measure of othergeometry is bigger, has a bigger area
                otherGeometry.width() > thisGeometry.width() || otherGeometry.height() > thisGeometry.height() ||
                // ids not -1 are considered in descending order of importance
                //-1 means that is a screen not known yet, just arrived and
                // not yet in screenpool: this happens for screens that
                // are hotplugged and weren't known. it does NOT happen
                // at first startup, as screenpool populates on load with all screens connected at the moment before the rest of the shell starts up
                (thisId == -1 && otherId != -1) || (thisId > otherId && otherId != -1))) {
            return true;
        }
    }

    return false;
}

void ScreenPool::reconsiderOutputs()
{
    const auto screens = qGuiApp->screens();
    for (QScreen *screen : screens) {
        if (m_redundantOutputs.contains(screen)) {
            if (!isOutputRedundant(screen)) {
                qDebug() << "not redundant anymore" << screen;
                m_redundantOutputs.remove(screen);
                Q_EMIT screenAdded(screen);
            }
        } else if (isOutputRedundant(screen)) {
            qDebug() << "new redundant screen" << screen << "with primary screen" << m_primaryWatcher->primaryScreen();

            m_redundantOutputs.insert(screen);
            Q_EMIT screenRemoved(screen);
        } else {
            qDebug() << "fine screen" << screen;
        }
    }

    // updateStruts();

    // CHECK_SCREEN_INVARIANTS
}

void ScreenPool::handleScreenAdded(QScreen *screen)
{
    qWarning() << "ADDED" << screen << "redundant" << isOutputRedundant(screen) << "fake" << isOutputFake(screen);

    connect(screen, &QScreen::geometryChanged, &m_reconsiderOutputsTimer, static_cast<void (QTimer::*)()>(&QTimer::start), Qt::UniqueConnection);

    if (isOutputRedundant(screen) || isOutputFake(screen)) {
        return;
    }

    emit screenAdded(screen);
}

void ScreenPool::handleScreenRemoved(QScreen *screen)
{
    qWarning() << "REMOVED" << screen;
    if (m_redundantOutputs.contains(screen)) {
        m_redundantOutputs.remove(screen);
    } else {
        emit screenRemoved(screen);
    }
}

void ScreenPool::primaryOutputNameChanged(const QString &oldOutputName, const QString &newOutputName)
{
    // when the appearance of a new primary screen *moves*
    // the position of the now secondary, the two screens will appear overlapped for an instant, and a spurious output redundant would happen here if checked
    // immediately
    m_reconsiderOutputsTimer.start();

    QScreen *oldPrimary = m_primaryWatcher->screenForName(oldOutputName);
    QScreen *newPrimary = m_primaryWatcher->primaryScreen();

    if (!newPrimary || newPrimary == oldPrimary || newPrimary->geometry().isNull()) {
        return;
    }

    const int oldIdOfPrimary = id(newPrimary->name());

    // On X11 we get fake screens as primary
    {
        // Special case: we are in "no connectors" mode, there is only a (recycled) QScreen instance which is not attached to any output. Treat this as a screen
        // removed This happens only on X, wayland doesn't seem to be getting fake screens
        if (noRealOutputsConnected()) {
            qWarning() << "EMITTING SCREEN REMOVED" << newPrimary;
            handleScreenRemoved(newPrimary);
            return;
            // On X11, the output named :0.0 is fake
        } else if (!oldPrimary || oldOutputName == ":0.0" || oldOutputName.isEmpty()) {
            // setPrimaryConnector(newPrimary->name());
            qWarning() << "EMITTING SCREEN ADDED" << newPrimary;
            handleScreenAdded(newPrimary);
            return;
        } else {
            qWarning() << "PRIMARY CHANGED" << oldPrimary << "-->" << newPrimary;
        }
    }
}

#include "moc_screenpool.cpp"
