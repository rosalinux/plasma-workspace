/*
    SPDX-FileCopyrightText: 2022 Kai Uwe Broulik <kde@broulik.de>
    SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include "draghelper.h"

#include <QBuffer>
#include <QDrag>
#include <QGuiApplication>
#include <QMimeData>
#include <QPixmap>
#include <QQuickItem>
#include <QQuickWindow>
#include <QStyleHints>

DragHelper::DragHelper(QObject *parent)
    : QObject(parent)
{
}

bool DragHelper::isDrag(int oldX, int oldY, int newX, int newY) const
{
    return ((QPoint(oldX, oldY) - QPoint(newX, newY)).manhattanLength() >= qApp->styleHints()->startDragDistance());
}

void DragHelper::startDrag(QQuickItem *item)
{
    if (item && item->window() && item->window()->mouseGrabberItem()) {
        item->window()->mouseGrabberItem()->ungrabMouse();
    }

    m_grabResult = item->grabToImage();
    connect(m_grabResult.get(), &QQuickItemGrabResult::ready, this, &DragHelper::doDrag);
}

void DragHelper::doDrag()
{
    const QImage image = m_grabResult->image();

    // Copy image to memory
    QByteArray data;
    QBuffer buffer(&data);
    buffer.open(QIODevice::WriteOnly);
    image.save(&buffer, "PNG");
    buffer.close();

    QMimeData *mimeData = new QMimeData();
    mimeData->setData(QStringLiteral("image/png"), data);

    QDrag *drag = new QDrag(this);
    drag->setMimeData(mimeData);
    drag->setPixmap(QPixmap::fromImage(image));

    drag->exec(Qt::CopyAction);
}
