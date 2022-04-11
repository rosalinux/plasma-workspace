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
    twinFormLayouts: parentLayout

    QtLoc.Plugin {
        id: mapPlugin
        // map data provider
        // available choices are: "esri", "osm" (free) and "here", "itemsoverlay", "mapbox", "mapboxgl" (paid)
        name: "esri"
    }

    Kirigami.ShadowedRectangle {
        implicitWidth: Kirigami.Units.gridUnit * 25
        implicitHeight: Kirigami.Units.gridUnit * 17
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
