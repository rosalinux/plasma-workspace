/*
 * SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami 2.12 as Kirigami

AbstractButton {
    id: controlRoot

    property bool menuIsOpen: false

    signal activated()

    // QMenu opens on press, so we'll replicate that here
    hoverEnabled: true

    // This will trigger even if hoverEnabled has just became true and the
    // mouse cursor is already hovering.
    //
    // In practice, this never works, at least on X11: when menuIsOpen the
    // hover event would not be delivered. Instead we rely on
    // plasmoid.nativeInterface.requestActivateIndex signal to filter
    // QEvent::MouseMove events and tell us when to change the index.
    onHoveredChanged: if (hovered && menuIsOpen) { activated(); }

    // You don't actually have to "close" the menu via click/pressed handlers.
    // Instead, the menu will be closed automatically, as by any
    // other "outside of the menu" click event.
    onPressed: activated()

    enum MenuState {
        Rest,
        Hover,
        Down
    }

    property /*MenuDelegate.MenuState*/int menuState: {
        if (down) {
            return MenuDelegate.MenuState.Down;
        } else if (hovered) {
            return MenuDelegate.MenuState.Hover;
        }
        return MenuDelegate.MenuState.Rest;
    }

    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.SecondaryControl
    Kirigami.MnemonicData.label: controlRoot.text

    leftPadding: rest.margins.left
    topPadding: rest.margins.top
    rightPadding: rest.margins.right
    bottomPadding: rest.margins.bottom

    background: Item {
        id: background

        PlasmaCore.FrameSvgItem {
            id: rest
            anchors.fill: parent
            imagePath: "widgets/menubaritem"
            prefix: switch (controlRoot.menuState) {
                case MenuDelegate.MenuState.Down: return "pressed";
                case MenuDelegate.MenuState.Hover: return "hover";
                case MenuDelegate.MenuState.Rest: return "normal";
            }
        }
    }

    contentItem: PC3.Label {
        text: controlRoot.Kirigami.MnemonicData.richTextLabel
        textFormat: PC3.Label.RichText
    }
}
