/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.5
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore

Rectangle {
    id: root
    color: "black"
    
    property int stage

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true;
        }
    }

    Image {
        id: logo
        opacity: 0
        anchors.fill: parent

        source: "images/background.png"
        fillMode: Image.PreserveAspectCrop
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: logo
        from: 0
        to: 1
        duration: PlasmaCore.Units.veryLongDuration * 5
        easing.type: Easing.InOutQuad
    }
}
