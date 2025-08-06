import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

import qs.services
import qs

// ListView {
//     id: flick
//     anchors.fill: parent
//     property string searchText: ""

//     clip: true
//     orientation: ListView.Vertical

//     spacing: 10
//     focus: true

//     boundsBehavior: Flickable.StopAtBounds
//     snapMode: ListView.NoSnap

//     highlightFollowsCurrentItem: true
//     highlightRangeMode: ListView.NoHighlightRange

//     highlightMoveDuration: 250
//     highlightMoveVelocity: 400

//     preferredHighlightBegin: width / 2
//     preferredHighlightEnd: width / 2

//     model: ScriptModel {
//         values: {
//             const DesktopApplications = AppManager.desktopApp;

//             if (!searchText || searchText.trim() === "")
//                 return DesktopApplications;

//             const search = searchText.toLowerCase();

//             return DesktopApplications.filter(app => {
//                 const nameMatch = app.name?.toLowerCase().includes(search);
//                 const commentMatch = app.comment?.toLowerCase().includes(search);
//                 const categoriesMatch = (app.categories || []).join(" ").toLowerCase().includes(search);
//                 return nameMatch || commentMatch || categoriesMatch;
//             });
//         }
//     }

//     delegate: WrapperRectangle {
//         property bool isFocused: ListView.isCurrentItem
//         property real targetScale: isFocused || itemMouse.hovered ? 1.05 : 1.0
//         property color targetColor: isFocused || itemMouse.hovered ? Colors.color4 : Colors.background

//         width: flick.width
//         height: 48
//         color: targetColor

//         anchors.margins: 10

//         radius: 5
//         clip: true

//         RowLayout {

//             width: parent.width
//             Layout.alignment: Qt.AlignHCenter

//             Rectangle {
//                 width: 48
//                 height: 48
//                 color: 'transparent'

//                 IconImage {
//                     id: icon
//                     source: modelData.icon
//                     asynchronous: true
//                     width: 32
//                     height: 32
//                     mipmap: true
//                     anchors.centerIn: parent
//                 }
//             }

//             Rectangle {
//                 width: 48
//                 height: 48
//                 color: 'transparent'
//                 Layout.fillWidth: true
//                 Layout.alignment: Qt.AlignVCenter

//                 Column {
//                     anchors.left: parent.left
//                     Text {
//                         text: qsTr(modelData.name)
//                         font.pixelSize: 24
//                         color: Colors.color15
//                     }
//                     Text {
//                         text: qsTr(modelData.name)
//                         font.pixelSize: 8
//                         color: Colors.color14
//                     }
//                 }
//             }

//             MouseArea {
//                 id: itemMouse
//                 anchors.fill: parent
//                 hoverEnabled: true
//                 property bool hovered: containsMouse

//                 onClicked: {
//                     modelData.execFunc();
//                     GlobalState.toggleDrawer("appMenu");
//                 }

//                 onEntered: hovered = true
//                 onExited: hovered = false
//             }
//         }
//     }
// }

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
