/*
    SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "clipboardplugin.h"
#include "draghelper/draghelper.h"

void ClipboardPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QByteArray("org.kde.plasma.private.clipboard"));

    qmlRegisterType<DragHelper>(uri, 0, 1, "DragHelper");
}
