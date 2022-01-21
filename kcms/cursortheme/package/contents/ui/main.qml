/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-only
*/

import QtQuick 2.7
import QtQuick.Window 2.2 // for Screen
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Dialogs 1.1 as QtDialogs
import org.kde.kirigami 2.5 as Kirigami
import org.kde.newstuff 1.81 as NewStuff
import org.kde.kcm 1.3 as KCM

import org.kde.private.kcm_cursortheme 1.0

KCM.GridViewKCM {
    id: root
    KCM.ConfigModule.quickHelp: i18n("This module lets you choose the mouse cursor theme.")

    view.model: kcm.cursorsModel
    view.delegate: Delegate {}
    view.currentIndex: kcm.cursorThemeIndex(kcm.cursorThemeSettings.cursorTheme);

    view.onCurrentIndexChanged: {
        kcm.cursorThemeSettings.cursorTheme = kcm.cursorThemeFromIndex(view.currentIndex)
        view.positionViewAtIndex(view.currentIndex, view.GridView.Beginning);
    }

    Component.onCompleted: {
        view.positionViewAtIndex(view.currentIndex, GridView.Beginning);
    }

    KCM.SettingStateBinding {
        configObject: kcm.cursorThemeSettings
        settingName: "cursorTheme"
        extraEnabledConditions: !kcm.downloadingFile
    }

    DropArea {
        anchors.fill: parent
        onEntered: {
            if (!drag.hasUrls) {
                drag.accepted = false;
            }
        }
        onDropped: kcm.installThemeFromFile(drop.urls[0])
    }

    actions.main: Kirigami.Action {
        id: sizeAction
        readonly property int currentIndex: kcm.cursorSizeIndex(kcm.cursorThemeSettings.cursorSize)
        text: i18n("Icon size: %1", kcm.sizesModel.data(kcm.sizesModel.index(sizeAction.currentIndex, 0)))

        property KCM.SettingStateBinding _stateBinding: KCM.SettingStateBinding {
            configObject: kcm.cursorThemeSettings
            settingName: "cursorSize"
            extraEnabledConditions: kcm.canResize
        }

        property Instantiator _instantiator: Instantiator {
            model: kcm.sizesModel
            delegate: Kirigami.Action {
                id: sizeComboDelegate

                readonly property int size: parseInt(model.display)
                property int index

                displayComponent: QtControls.MenuItem {
                    text: model.display
    height: visible ? sizeComboDelegate.size / Screen.devicePixelRatio + topPadding + leftPadding + Kirigami.Units.largeSpacing : 0

                    contentItem: RowLayout {
                        Kirigami.Icon {
                            source: model.decoration
                            smooth: true
                            Layout.preferredWidth: sizeComboDelegate.size / Screen.devicePixelRatio
                            Layout.minimumHeight: sizeComboDelegate.size / Screen.devicePixelRatio
                            visible: valid && sizeComboDelegate.size > 0
                        }

                        QtControls.Label {
                            Layout.fillWidth: true
                            color: sizeComboDelegate.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            text: model.display
                            elide: Text.ElideRight
                        }
                    }
                    onClicked: {
                        kcm.cursorThemeSettings.cursorSize = kcm.cursorSizeFromIndex(sizeComboDelegate.index);
                        kcm.preferredSize = kcm.cursorSizeFromIndex(sizeComboDelegate.index);
                    }
                }
            }
            onObjectAdded: {
                object.index = index;
                sizeAction.children.push(object)
            }
        }
    }

    actions.right: NewStuff.Action {
        text: i18nc("@action:button", "&Get New…")
        configFile: "xcursor.knsrc"
        onEntryEvent: function (entry, event) {
            if (event == 1) { // StatusChangedEvent
                kcm.ghnsEntryChanged(entry);
            }
        }
    }

    actions.left: Kirigami.Action {
        text: i18n("&Install from File…")
        icon.name: "document-import"
        onTriggered: fileDialogLoader.active = true
        enabled: kcm.canInstall
    }

    footer: ColumnLayout {
        id: footerLayout

        Kirigami.InlineMessage {
            id: infoLabel
            Layout.fillWidth: true

            showCloseButton: true

            Connections {
                target: kcm
                function onShowSuccessMessage(message) {
                    infoLabel.type = Kirigami.MessageType.Positive;
                    infoLabel.text = message;
                    infoLabel.visible = true;
                }
                function onShowInfoMessage(message) {
                    infoLabel.type = Kirigami.MessageType.Information;
                    infoLabel.text = message;
                    infoLabel.visible = true;
                }
                function onShowErrorMessage(message) {
                    infoLabel.type = Kirigami.MessageType.Error;
                    infoLabel.text = message;
                    infoLabel.visible = true;
                }
            }
        }
    }

    Loader {
        id: fileDialogLoader
        active: false
        sourceComponent: QtDialogs.FileDialog {
            title: i18n("Open Theme")
            folder: shortcuts.home
            nameFilters: [ i18n("Cursor Theme Files (*.tar.gz *.tar.bz2)") ]
            Component.onCompleted: open()
            onAccepted: {
                kcm.installThemeFromFile(fileUrls[0])
                fileDialogLoader.active = false
            }
            onRejected: {
                fileDialogLoader.active = false
            }
        }
    }
}

