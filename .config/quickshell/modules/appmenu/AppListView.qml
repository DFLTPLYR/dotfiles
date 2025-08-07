import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

import qs.services
import qs

GridView {
    id: grid
    anchors.fill: parent

    property string searchText: ""

    clip: true
    cellWidth: Math.floor(parent.width / 6)
    cellHeight: Math.floor(parent.width / 6)

    focus: true
    keyNavigationWraps: true
    boundsBehavior: Flickable.StopAtBounds
    snapMode: GridView.NoSnap

    model: ScriptModel {
        values: {
            const DesktopApplications = AppManager.desktopApp;

            if (!searchText || searchText.trim() === "")
                return DesktopApplications;

            const search = searchText.toLowerCase();

            return DesktopApplications.filter(app => {
                const nameMatch = app.name?.toLowerCase().includes(search);
                const commentMatch = app.comment?.toLowerCase().includes(search);
                const categoriesMatch = (app.categories || []).join(" ").toLowerCase().includes(search);
                return nameMatch || commentMatch || categoriesMatch;
            });
        }
    }

    delegate: ClippingRectangle {
        width: grid.cellWidth
        height: grid.cellHeight
        color: "transparent"

        property bool isHovered: false

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: isHovered = true
            onExited: isHovered = false
            onClicked: {
                modelData.execFunc();
                GlobalState.toggleDrawer("appMenu");
            }
        }

        ClippingRectangle {
            anchors.centerIn: parent

            width: Math.floor(grid.cellWidth * 0.9)
            height: Math.floor(grid.cellHeight * 0.9)

            radius: 5
            color: isHovered ? Colors.backgroundAlt : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Column {
                anchors.fill: parent
                spacing: 0

                Item {
                    width: Math.floor(parent.width)
                    height: Math.floor(parent.height * 0.6)

                    IconImage {
                        anchors.centerIn: parent
                        source: modelData.icon
                        width: 48
                        height: 48
                        mipmap: false
                    }
                }

                Item {
                    width: Math.floor(parent.width)
                    height: Math.floor(parent.height * 0.4)

                    Text {
                        anchors.centerIn: parent
                        width: parent.width
                        text: modelData.name
                        font.pixelSize: 10
                        font.family: "Ubuntu"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        color: Colors.color15
                        smooth: false
                        layer.enabled: true
                    }
                }
            }
        }
    }
}
