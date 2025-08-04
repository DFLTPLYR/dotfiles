import QtQuick
import Quickshell
import QtQuick.Shapes
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Hyprland

import qs.services
import qs

ListView {
    id: flick
    anchors.fill: parent
    clip: true
    orientation: ListView.Vertical
    spacing: 2
    focus: true

    populate: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: 1000
        }
    }

    boundsBehavior: Flickable.StopAtBounds
    snapMode: ListView.NoSnap // optional unless you need snapping

    highlightFollowsCurrentItem: false
    highlightRangeMode: ListView.NoHighlightRange // disable loose padding

    highlightMoveDuration: 250
    highlightMoveVelocity: 400

    preferredHighlightBegin: width / 2
    preferredHighlightEnd: width / 2

    model: ScriptModel {
        values: {
            return AppManager.desktopApp;
        }
    }

    delegate: Item {
        width: flick.width
        height: flick.height / 5

        Rectangle {
            anchors.fill: parent
            color: Colors.color0

            Item {
                width: 64
                height: 64

                IconImage {
                    id: icon

                    source: modelData.icon
                    implicitSize: parent.height * 0.8

                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.centerIn: parent
                text: modelData.name
            }
        }
    }
}
