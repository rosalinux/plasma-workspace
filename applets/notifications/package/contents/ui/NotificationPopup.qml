/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.notificationmanager 1.0 as NotificationManager

import ".."

PlasmaCore.Dialog {
    id: notificationPopup

    property int popupWidth

    property alias notificationType: notificationItem.notificationType

    property alias applicationName: notificationItem.applicationName
    property alias applicationIconSource: notificationItem.applicationIconSource
    property alias originName: notificationItem.originName

    property alias time: notificationItem.time

    property alias summary: notificationItem.summary
    property alias body: notificationItem.body
    property alias icon: notificationItem.icon
    property alias urls: notificationItem.urls

    property int urgency
    property int timeout
    property int dismissTimeout

    property alias jobState: notificationItem.jobState
    property alias percentage: notificationItem.percentage
    property alias jobError: notificationItem.jobError
    property alias suspendable: notificationItem.suspendable
    property alias killable: notificationItem.killable
    property alias jobDetails: notificationItem.jobDetails

    property alias configureActionLabel: notificationItem.configureActionLabel
    property alias configurable: notificationItem.configurable
    property alias dismissable: notificationItem.dismissable
    property alias closable: notificationItem.closable

    property bool hasDefaultAction
    property var defaultActionFallbackWindowIdx
    property alias actionNames: notificationItem.actionNames
    property alias actionLabels: notificationItem.actionLabels
    property alias useActionIcons: notificationItem.useActionIcons

    property alias hasReplyAction: notificationItem.hasReplyAction
    property alias replyActionLabel: notificationItem.replyActionLabel
    property alias replyPlaceholderText: notificationItem.replyPlaceholderText
    property alias replySubmitButtonText: notificationItem.replySubmitButtonText
    property alias replySubmitButtonIconName: notificationItem.replySubmitButtonIconName

    signal configureClicked
    signal dismissClicked
    signal closeClicked

    signal defaultActionInvoked
    signal actionInvoked(string actionName)
    signal replied(string text)
    signal openUrl(string url)
    signal fileActionInvoked(QtObject action)

    signal expired
    signal hoverEntered
    signal hoverExited

    signal suspendJobClicked
    signal resumeJobClicked
    signal killJobClicked

    property int defaultTimeout: 5000
    readonly property int effectiveTimeout: {
        if (timeout === -1) {
            return defaultTimeout;
        }
        if (dismissTimeout) {
            return dismissTimeout;
        }
        return timeout;
    }

    location: PlasmaCore.Types.Floating
    // On wayland we need focus to copy to the clipboard, we change on mouse interaction until the cursor leaves 
    flags: notificationItem.replying || focusListener.wantsFocus ? 0 : Qt.WindowDoesNotAcceptFocus

    visible: false

    // When notification is updated, restart hide timer
    onTimeChanged: {
        if (timer.running) {
            timer.restart();
        }
    }

    mainItem: KQuickAddons.MouseEventListener {
        id: focusListener
        property bool wantsFocus: false

        width: notificationPopup.popupWidth
        height: notificationItem.height + notificationItem.y

        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        onPressed: wantsFocus = true
        onContainsMouseChanged: wantsFocus = wantsFocus && containsMouse

        // Visual flourish for critical notifications to make them stand out more
        Rectangle {
            id: criticalNotificationLine

            anchors {
                top: parent.top
                // Subtract bottom margin that header sets which is not a part of
                // its height, and also the PlasmoidHeading's bottom line
                topMargin: notificationItem.headerHeight - notificationItem.spacing - PlasmaCore.Units.devicePixelRatio
                bottom: parent.bottom
                bottomMargin: -notificationPopup.margins.bottom
                left: parent.left
                leftMargin: -notificationPopup.margins.left
            }
            implicitWidth: Math.round(4 * PlasmaCore.Units.devicePixelRatio)

            visible: notificationPopup.urgency === NotificationManager.Notifications.CriticalUrgency

            color: PlasmaCore.Theme.neutralTextColor
        }

        DraggableDelegate {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            draggable: notificationItem.notificationType != NotificationManager.Notifications.JobType
            onDismissRequested: popupNotificationsModel.close(popupNotificationsModel.index(index, 0))

            cursorShape: hasDefaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
            acceptedButtons: hasDefaultAction || draggable ? Qt.LeftButton : Qt.NoButton

            onClicked: {
                if (hasDefaultAction) {
                    notificationPopup.defaultActionInvoked();
                }
            }
            onEntered: notificationPopup.hoverEntered()
            onExited: notificationPopup.hoverExited()

            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
            LayoutMirroring.childrenInherit: true

            Timer {
                id: timer
                interval: notificationPopup.effectiveTimeout
                running: {
                    if (!notificationPopup.visible) {
                        return false;
                    }
                    if (area.containsMouse) {
                        return false;
                    }
                    if (interval <= 0) {
                        return false;
                    }
                    if (notificationItem.dragging || notificationItem.menuOpen) {
                        return false;
                    }
                    if (notificationItem.replying
                            && (notificationPopup.active || notificationItem.hasPendingReply)) {
                        return false;
                    }
                    return true;
                }
                onTriggered: {
                    if (notificationPopup.dismissTimeout) {
                        notificationPopup.dismissClicked();
                    } else {
                        notificationPopup.expired();
                    }
                }
            }

            NumberAnimation {
                target: notificationItem
                property: "remainingTime"
                from: timer.interval
                to: 0
                duration: timer.interval
                running: timer.running && PlasmaCore.Units.longDuration > 1
            }

            NotificationItem {
                id: notificationItem
                // let the item bleed into the dialog margins so the close button margins cancel out
                y: closable || dismissable || configurable ? -notificationPopup.margins.top : 0
                headingRightPadding: -notificationPopup.margins.right
                width: parent.width
                hovered: area.containsMouse
                maximumLineCount: 8
                bodyCursorShape: notificationPopup.hasDefaultAction ? Qt.PointingHandCursor : 0

                thumbnailLeftPadding: -notificationPopup.margins.left
                thumbnailRightPadding: -notificationPopup.margins.right
                thumbnailTopPadding: -notificationPopup.margins.top
                thumbnailBottomPadding: -notificationPopup.margins.bottom

                extraSpaceForCriticalNotificationLine: criticalNotificationLine.visible ? criticalNotificationLine.implicitWidth : 0

                timeout: timer.running ? timer.interval : 0

                closable: true

                onBodyClicked: {
                    if (area.acceptedButtons & Qt.LeftButton) {
                        area.clicked(null /*mouse*/);
                    }
                }
                onCloseClicked: notificationPopup.closeClicked()
                onDismissClicked: notificationPopup.dismissClicked()
                onConfigureClicked: notificationPopup.configureClicked()
                onActionInvoked: notificationPopup.actionInvoked(actionName)
                onReplied: notificationPopup.replied(text)
                onOpenUrl: notificationPopup.openUrl(url)
                onFileActionInvoked: notificationPopup.fileActionInvoked(action)

                onSuspendJobClicked: notificationPopup.suspendJobClicked()
                onResumeJobClicked: notificationPopup.resumeJobClicked()
                onKillJobClicked: notificationPopup.killJobClicked()
            }
        }
    }
}
