/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "view.h"

#include <QAction>
#include <QClipboard>
#include <QDebug>
#include <QGuiApplication>
#include <QPlatformSurfaceEvent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickItem>
#include <QScreen>

#include <KAuthorized>
#include <KCrash>
#include <KIO/CommandLauncherJob>
#include <KLocalizedString>
#include <KService>
#include <KWindowEffects>
#include <KWindowSystem>
#include <LayerShellQt/Window>

#include <kdeclarative/qmlobject.h>

#include <KPackage/Package>
#include <KPackage/PackageLoader>


#include "appadaptor.h"

View::View(QWindow *)
    : PlasmaQuick::Dialog()
    , m_offset(.5)
    , m_floating(false)
{
    setClearBeforeRendering(true);
    setColor(QColor(Qt::transparent));
    setFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);

    KCrash::initialize();

    // used only by screen readers
    setTitle(i18n("KRunner"));

    m_config = KConfigGroup(KSharedConfig::openConfig(), "General");
    m_stateData = KSharedConfig::openConfig(QStringLiteral("krunnerstaterc"), //
                                            KConfig::NoGlobals,
                                            QStandardPaths::GenericDataLocation)
                      ->group("General");
    m_configWatcher = KConfigWatcher::create(KSharedConfig::openConfig());
    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) {
        Q_UNUSED(names);
        if (group.name() == QLatin1String("General")) {
            loadConfig();
        }
    });

    loadConfig();

    new AppAdaptor(this);
    QDBusConnection::sessionBus().registerObject(QStringLiteral("/App"), this);

    m_qmlObj = new KDeclarative::QmlObject(this);
    m_qmlObj->setInitializationDelayed(true);
    connect(m_qmlObj, &KDeclarative::QmlObject::finished, this, &View::objectIncubated);

    KPackage::Package package = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("Plasma/LookAndFeel"));
    KConfigGroup cg(KSharedConfig::openConfig(), "KDE");
    const QString packageName = cg.readEntry("LookAndFeelPackage", QString());
    if (!packageName.isEmpty()) {
        package.setPath(packageName);
    }

    m_qmlObj->engine()->rootContext()->setContextProperty(QStringLiteral("runnerWindow"), this);
    m_qmlObj->setSource(package.fileUrl("runcommandmainscript"));
    m_qmlObj->completeInitialization();

    auto screenRemoved = [this](QScreen *screen) {
        if (screen == this->screen()) {
            setScreen(qGuiApp->primaryScreen());
            hide();
        }
    };

    auto screenAdded = [this](const QScreen *screen) {
        connect(screen, &QScreen::geometryChanged, this, &View::screenGeometryChanged);
        screenGeometryChanged();
    };

    const auto screens = QGuiApplication::screens();
    for (QScreen *s : screens) {
        screenAdded(s);
    }
    connect(qGuiApp, &QGuiApplication::screenAdded, this, screenAdded);
    connect(qGuiApp, &QGuiApplication::screenRemoved, this, screenRemoved);

    connect(KWindowSystem::self(), &KWindowSystem::workAreaChanged, this, &View::resetScreenPos);

    connect(qGuiApp, &QGuiApplication::focusWindowChanged, this, &View::slotFocusWindowChanged);
}

View::~View()
{
}

void View::objectIncubated()
{
    auto mainItem = qobject_cast<QQuickItem *>(m_qmlObj->rootObject());
    connect(mainItem, &QQuickItem::widthChanged, this, &View::resetScreenPos);
    setMainItem(mainItem);
}

void View::slotFocusWindowChanged()
{
    if (!QGuiApplication::focusWindow() && !m_pinned) {
        setVisible(false);
    }
}

bool View::freeFloating() const
{
    return m_floating;
}

void View::setFreeFloating(bool floating)
{
    if (m_floating == floating) {
        return;
    }

    m_floating = floating;
    if (m_floating) {
        setLocation(Plasma::Types::Floating);
    } else {
        setLocation(Plasma::Types::TopEdge);
    }

    positionOnScreen();
}

void View::loadConfig()
{
    setFreeFloating(m_config.readEntry("FreeFloating", false));
    setPinned(m_stateData.readEntry("Pinned", false));
}

bool View::event(QEvent *event)
{
    // Bypass Dialog so we don't create a plasmashell surface
    if (event->type() == QEvent::Expose || event->type() == QEvent::PlatformSurface) {
        return QQuickWindow::event(event);
    }
    return Dialog::event(event);
}

void View::resizeEvent(QResizeEvent *event)
{
    if (event->oldSize().width() != event->size().width()) {
        positionOnScreen();
    }
}

void View::showEvent(QShowEvent *event)
{
    KWindowSystem::setOnAllDesktops(winId(), true);
    positionOnScreen();
    requestActivate();
}

void View::screenGeometryChanged()
{
    if (isVisible()) {
        positionOnScreen();
    }
}

void View::resetScreenPos()
{
    if (isVisible() && !m_floating) {
        positionOnScreen();
    }
}

void View::positionOnScreen()
{
    if (!m_requestedVisible) {
        return;
    }

    QScreen *shownOnScreen = QGuiApplication::primaryScreen();

    const auto screens = QGuiApplication::screens();
    for (QScreen *screen : screens) {
        if (screen->geometry().contains(QCursor::pos(screen))) {
            shownOnScreen = screen;
            break;
        }
    }
    setScreen(shownOnScreen);
    const QRect r = shownOnScreen->availableGeometry();

    if (KWindowSystem::isPlatformWayland()) {
        auto layerWindow = LayerShellQt::Window::get(this);
        layerWindow->setAnchors(LayerShellQt::Window::AnchorTop);
        layerWindow->setLayer(LayerShellQt::Window::LayerTop);
        if (m_floating) {
            layerWindow->setMargins({0, r.height() / 3, 0, 0});
        } else {
            // Workaround so Dialog gets the borders correct
            auto geom = geometry();
            geom.moveCenter({r.center().x(), 0});
            setGeometry(geom);
        }
    } else {
        if (m_floating && !m_customPos.isNull()) {
            int x = qBound(r.left(), m_customPos.x(), r.right() - width());
            int y = qBound(r.top(), m_customPos.y(), r.bottom() - height());
            setPosition(x, y);
            return;
        }

        const int w = width();
        int x = r.left() + (r.width() * m_offset) - (w / 2);

        int y = r.top();
        if (m_floating) {
            y += r.height() / 3;
        }
        x = qBound(r.left(), x, r.right() - width());
        y = qBound(r.top(), y, r.bottom() - height());

        setPosition(x, y);
        KWindowSystem::setState(winId(), NET::SkipTaskbar | NET::SkipPager);
    }


    if (m_floating) {
        KWindowSystem::setOnDesktop(winId(), KWindowSystem::currentDesktop());
        // Turn the sliding effect off
        setLocation(Plasma::Types::Floating);
    } else {
        KWindowSystem::setOnAllDesktops(winId(), true);
        setLocation(Plasma::Types::TopEdge);
    }

    PlasmaQuick::Dialog::setVisible(true);
    KWindowSystem::forceActiveWindow(winId());
}

void View::toggleDisplay()
{
    if (isVisible() && !QGuiApplication::focusWindow()) {
        KWindowSystem::forceActiveWindow(winId());
        return;
    }
    setVisible(!isVisible());
}

void View::display()
{
    setVisible(true);
}

void View::displaySingleRunner(const QString &runnerName)
{
    setVisible(true);

    m_qmlObj->rootObject()->setProperty("runner", runnerName);
    m_qmlObj->rootObject()->setProperty("query", QString());
}

void View::displayWithClipboardContents()
{
    setVisible(true);

    m_qmlObj->rootObject()->setProperty("runner", QString());
    m_qmlObj->rootObject()->setProperty("query", QGuiApplication::clipboard()->text(QClipboard::Selection));
}

void View::query(const QString &term)
{
    setVisible(true);

    m_qmlObj->rootObject()->setProperty("runner", QString());
    m_qmlObj->rootObject()->setProperty("query", term);
}

void View::querySingleRunner(const QString &runnerName, const QString &term)
{
    setVisible(true);

    m_qmlObj->rootObject()->setProperty("runner", runnerName);
    m_qmlObj->rootObject()->setProperty("query", term);
}

void View::switchUser()
{
    QDBusConnection::sessionBus().asyncCall(QDBusMessage::createMethodCall(QStringLiteral("org.kde.ksmserver"),
                                                                           QStringLiteral("/KSMServer"),
                                                                           QStringLiteral("org.kde.KSMServerInterface"),
                                                                           QStringLiteral("openSwitchUserDialog")));
}

void View::displayConfiguration()
{
    const QString systemSettings = QStringLiteral("systemsettings");
    const QStringList kcmToOpen = QStringList(QStringLiteral("kcm_plasmasearch"));
    KIO::CommandLauncherJob *job = nullptr;

    if (KService::serviceByDesktopName(systemSettings)) {
        job = new KIO::CommandLauncherJob(QStringLiteral("systemsettings5"), kcmToOpen);
        job->setDesktopName(systemSettings);
    } else {
        job = new KIO::CommandLauncherJob(QStringLiteral("kcmshell5"), kcmToOpen);
    }

    job->start();
}

bool View::canConfigure() const
{
    return KAuthorized::authorizeControlModule(QStringLiteral("kcm_plasmasearch.desktop"));
}

void View::setVisible(bool visible)
{
    m_requestedVisible = visible;

    if (visible && !m_floating) {
        positionOnScreen();
    } else {
        PlasmaQuick::Dialog::setVisible(visible);
    }
}

bool View::pinned() const
{
    return m_pinned;
}

void View::setPinned(bool pinned)
{
    if (m_pinned != pinned) {
        m_pinned = pinned;
        m_stateData.writeEntry("Pinned", pinned);
        Q_EMIT pinnedChanged();
    }
}

void View::removeFromHistory(int index)
{
    if (m_manager) {
        m_manager->removeFromHistory(index);
        Q_EMIT historyChanged();
    }
}

QStringList View::history() const
{
    return m_manager ? m_manager->history() : QStringList();
}
