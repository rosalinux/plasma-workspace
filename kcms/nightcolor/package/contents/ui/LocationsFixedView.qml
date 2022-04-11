/*
    SPDX-FileCopyrightText: 2017 Roman Gilg <subdiff@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kcm 1.5 as KCM

import QtLocation 5.14
import QtPositioning 5.14

Kirigami.FormLayout {
    twinFormLayouts: parentLayout
    implicitHeight: 300

    Plugin {
        id: mapPlugin
        name: "esri" // "esri", "here", "itemsoverlay", "mapbox", "mapboxgl",  "osm"
    }

    Map {
        id: map
        Layout.minimumWidth: 450
        Layout.maximumWidth: 450
        height: 300
        implicitHeight: 300
        plugin: mapPlugin
        activeMapType: supportedMapTypes[0]
        zoomLevel: 4
        bearing: 0
        tilt: 0
        copyrightsVisible: true
        fieldOfView: 0
        gesture.enabled: true

        Component.onCompleted: {
            center = QtPositioning.coordinate(
                kcm.nightColorSettings.latitudeFixed,
                kcm.nightColorSettings.longitudeFixed)
        }

        MapQuickItem {
            id: marker
            anchorPoint.x: image.width/2
            anchorPoint.y: image.height - 4
            coordinate: QtPositioning.coordinate(
                kcm.nightColorSettings.latitudeFixed,
                kcm.nightColorSettings.longitudeFixed)

            sourceItem: Kirigami.Icon {
                id: image
                width: 32
                height: 32
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
        }
    }
}
