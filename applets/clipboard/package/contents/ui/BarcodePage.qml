/*
    SPDX-FileCopyrightText: 2015 Martin Gräßlin <mgraesslin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // For ContextMenu
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.clipboard 0.1 as Backend
import org.kde.prison 1.0 as Prison

ColumnLayout {
    id: barcodeView

    property alias text: barcodeItem.content

    Keys.onPressed: {
        if (event.key == Qt.Key_Escape) {
            stack.pop()
            event.accepted = true;
        }
    }

    property var header: PlasmaExtras.PlasmoidHeading {
        RowLayout {
            anchors.fill: parent
            PlasmaComponents3.Button {
                Layout.fillWidth: true
                icon.name: "go-previous-view"
                text: i18n("Return to Clipboard")
                onClicked: stack.pop()
            }

            Component {
                id: menuItemComponent
                PlasmaComponents.MenuItem { }
            }

            PlasmaComponents.ContextMenu {
                id: menu
                visualParent: configureButton
                placement: PlasmaCore.Types.BottomPosedLeftAlignedPopup
                onStatusChanged: {
                    if (status == PlasmaComponents.DialogStatus.Closed) {
                        configureButton.checked = false;
                    }
                }

                Component.onCompleted: {
                    [
                        {text: i18n("QR Code"), type: Prison.Barcode.QRCode},
                        {text: i18n("Data Matrix"), type: Prison.Barcode.DataMatrix},
                        {text: i18nc("Aztec barcode", "Aztec"), type: Prison.Barcode.Aztec},
                        {text: i18n("Code 39"), type: Prison.Barcode.Code39},
                        {text: i18n("Code 93"), type: Prison.Barcode.Code93},
                        {text: i18n("Code 128"), type: Prison.Barcode.Code128}
                    ].forEach((item) => {
                        let menuItem = menuItemComponent.createObject(menu, {
                            text: item.text,
                            checkable: true,
                            checked: Qt.binding(() => {
                                return barcodeItem.barcodeType === item.type;
                            })
                        });
                        menuItem.clicked.connect(() => {
                            barcodeItem.barcodeType = item.type;
                            Plasmoid.configuration.barcodeType = item.type;
                        });
                        menu.addMenuItem(menuItem);
                    });
                }
            }
            PlasmaComponents3.ToolButton {
                id: configureButton
                checkable: true
                icon.name: "configure"
                onClicked: menu.openRelative()

                PlasmaComponents3.ToolTip {
                    text: i18n("Change the QR code type")
                }
            }
        }
    }

    Backend.DragHelper {
        id: dragHelper
    }

    Item {
        Layout.fillWidth: parent
        Layout.fillHeight: parent
        Layout.topMargin: PlasmaCore.Units.smallSpacing

        Prison.Barcode {
            id: barcodeItem
            readonly property bool valid: implicitWidth > 0 && implicitHeight > 0 && implicitWidth <= width && implicitHeight <= height
            anchors.fill: parent
            barcodeType: Plasmoid.configuration.barcodeType
            // Cannot set visible to false as we need it to re-render when changing its size
            opacity: valid ? 1 : 0

            MouseArea {
                anchors.fill: parent

                property int _pressX: -1
                property int _pressY: -1

                acceptedButtons: Qt.LeftButton
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                enabled: barcodeItem.valid

                onPressed: {
                    if (mouse.button === Qt.LeftButton) {
                        _pressX = mouse.x;
                        _pressY = mouse.y;
                    }
                }
                onPositionChanged: {
                    if (_pressX !== -1 && _pressY !== -1 && dragHelper.isDrag(_pressX, _pressY, mouse.x, mouse.y)) {
                        dragHelper.startDrag(barcodeItem);
                        _pressX = -1;
                        _pressY = -1;
                    }
                }
                onReleased: {
                    _pressX = -1;
                    _pressY = -1;
                }
                onContainsMouseChanged: {
                    if (!containsMouse) {
                        _pressX = -1;
                        _pressY = -1;
                    }
                }
            }
        }

        PlasmaComponents3.Label {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: i18n("Creating QR code failed")
            wrapMode: Text.WordWrap
            visible: barcodeItem.implicitWidth === 0 && barcodeItem.implicitHeight === 0
        }

        PlasmaComponents3.Label {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: i18n("The QR code is too large to be displayed")
            wrapMode: Text.WordWrap
            visible: barcodeItem.implicitWidth > barcodeItem.width || barcodeItem.implicitHeight > barcodeItem.height
        }
    }
}
