/*
    SPDX-FileCopyrightText: 2022 Kai Uwe Broulik <kde@broulik.de>
    SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#pragma once

#include <QObject>
#include <QQuickItemGrabResult>

class QQuickItem;

class DragHelper : public QObject
{
    Q_OBJECT

public:
    explicit DragHelper(QObject *parent = nullptr);

    Q_INVOKABLE bool isDrag(int oldX, int oldY, int newX, int newY) const;
    Q_INVOKABLE void startDrag(QQuickItem *item);

private Q_SLOTS:
    void doDrag();

private:
    QSharedPointer<QQuickItemGrabResult> m_grabResult;
};
