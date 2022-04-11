/*
    SPDX-FileCopyrightText: 2017 Roman Gilg <subdiff@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.15 as Kirigami
import org.kde.kcm 1.5 as KCM

import QtLocation 5.15 as QtLoc
import QtPositioning 5.15 as QtPos

Kirigami.FormLayout {
    QtLoc.Plugin {
        id: mapPlugin
        // map data provider, we use OpenStreetMaps
        name: "osm"
    }

    Kirigami.Label {
        anchors.bottom: mapRect.top
        anchors.bottomMargin: Kirigami.Units.smallSpacing
        anchors.horizontalCenter: mapRect.horizontalCenter
        text: i18n("Tap to pick your location on the map.")
        font: Kirigami.Theme.smallFont
    }

    Kirigami.ShadowedRectangle {
        id: mapRect
        implicitWidth: Kirigami.Units.gridUnit * 28
        implicitHeight: Kirigami.Units.gridUnit * 15
        radius: Kirigami.Units.smallSpacing
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
        shadow.xOffset: 0
        shadow.yOffset: 2
        shadow.size: 10
        shadow.color: Qt.rgba(0, 0, 0, 0.3)
        QtLoc.Map {
            id: map
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            plugin: mapPlugin
            activeMapType: supportedMapTypes[0]
            zoomLevel: 4
            bearing: 0
            tilt: 0
            copyrightsVisible: true
            fieldOfView: 0
            gesture.enabled: true

            Component.onCompleted: {
                center = QtPos.QtPositioning.coordinate(
                    kcm.nightColorSettings.latitudeFixed,
                    kcm.nightColorSettings.longitudeFixed)
            }

            onCopyrightLinkActivated: (link) => Qt.openUrlExternally(link)

            RowLayout {
                anchors {
                    right: parent.right
                    rightMargin: Kirigami.Units.smallSpacing
                    bottom: parent.bottom
                    bottomMargin: Kirigami.Units.smallSpacing
                }

                // Always show above thumbnail content
                z: 9999

                QQC2.Button {
                    // HACK: using list-add and list-remove for more obvious/standard zoom icons till we change the Breeze ones
                    icon.name: "list-add"
                    activeFocusOnTab: false
                    onClicked: {
                        map.zoomLevel++;
                    }
                    //NOTE: there aren't any global settings where to take "official" tooltip timeouts
                    QQC2.ToolTip.delay: 1000
                    QQC2.ToolTip.timeout: 5000
                    QQC2.ToolTip.visible: Kirigami.Settings.isMobile ? pressed : hovered
                    QQC2.ToolTip.text: i18n("Zoom in")
                }

                QQC2.Button {
                    // HACK: using list-add and list-remove for more obvious/standard zoom icons till we change the Breeze ones
                    icon.name: "list-remove"
                    activeFocusOnTab: false
                    onClicked: {
                        if (map.zoomLevel > 1) {
                            // we're not disabling the button for map.zoomLevel <= 1 even if it won't do anything
                            // since otherwise it won't eat click events and the last click will place the marker there
                            map.zoomLevel--;
                        }
                    }
                    //NOTE: there aren't any global settings where to take "official" tooltip timeouts
                    QQC2.ToolTip.delay: 1000
                    QQC2.ToolTip.timeout: 5000
                    QQC2.ToolTip.visible: Kirigami.Settings.isMobile ? pressed : hovered
                    QQC2.ToolTip.text: i18n("Zoom out")
                }
            }

            QtLoc.MapQuickItem {
                id: marker
                autoFadeIn: false
                anchorPoint.x: image.width/2
                anchorPoint.y: image.height - 4
                coordinate: QtPos.QtPositioning.coordinate(
                    kcm.nightColorSettings.latitudeFixed,
                    kcm.nightColorSettings.longitudeFixed)

                sourceItem: Kirigami.Icon {
                    id: image
                    width: Kirigami.Units.iconSizes.medium
                    height: Kirigami.Units.iconSizes.medium
                    source: "mark-location"
                }
            }

            Connections {
                target: kcm.nightColorSettings
                function onLatitudeFixedChanged() {
                    marker.coordinate.latitude = kcm.nightColorSettings.latitudeFixed;
                }
                function onLongitudeFixedChanged() {
                    marker.coordinate.longitude = kcm.nightColorSettings.longitudeFixed;
                }
            }

            TapHandler {
                onTapped: {
                    var coordinate = map.toCoordinate(map.mapFromItem(root, eventPoint.scenePosition))
                    marker.coordinate = coordinate
                    kcm.nightColorSettings.latitudeFixed = coordinate.latitude
                    kcm.nightColorSettings.longitudeFixed = coordinate.longitude
                }
            }

            WheelHandler {
                onWheel: {
                    let clicks = event.angleDelta.y / 120;
                    if (map.zoomLevel > 1 || clicks > 0) {
                        map.zoomLevel += clicks;
                    }
                    else {
                        map.zoomLevel = 1;
                    }
                }
            }
        }
    }
}
