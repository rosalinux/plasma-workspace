/*
    SPDX-FileCopyrightText: 2017 Roman Gilg <subdiff@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kcm 1.5 as KCM

import QtLocation 5.15 as QtLoc
import QtPositioning 5.15 as QtPos

Kirigami.FormLayout {
    twinFormLayouts: parentLayout

    QtLoc.Plugin {
        id: mapPlugin
        // map data provider
        // available choices are: "esri", "osm" (free) and "here", "itemsoverlay", "mapbox", "mapboxgl" (paid)
        name: "esri"
    }

    QtLoc.Map {
        id: map
        Layout.preferredWidth: Kirigami.Units.gridUnit * 25
        Layout.preferredHeight: Kirigami.Units.gridUnit * 17
        implicitHeight: Kirigami.Units.gridUnit * 17  // needs to be set so Map gets correct size
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

        MouseArea {
            acceptedButtons: Qt.LeftButton
            anchors.fill: map
            hoverEnabled: true
            property var coordinate: map.toCoordinate(Qt.point(mouseX, mouseY))

            onClicked: {
                marker.coordinate = coordinate
                kcm.nightColorSettings.latitudeFixed = coordinate.latitude
                kcm.nightColorSettings.longitudeFixed = coordinate.longitude
            }

            onWheel: {
                var clicks = wheel.angleDelta.y / 120;
                console.log(clicks);
                if (map.zoomLevel > 1 || clicks > 0) {
                    map.zoomLevel += clicks;
                }
                else {
                    map.zoomLevel = 1;
                }
                console.log(map.zoomLevel);
            }
        }
    }
}
