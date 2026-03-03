import QtQuick
import QtQuick.Layouts

import qs.core

Rectangle {
    id: floatingWindow

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    width: screen.width / 2
    height: screen.height / 2

    color: Qt.rgba(0, 0, 0, 0.2)
    opacity: Global.enableSetting ? 1 : 0

    border {
        width: 1
        color: "white"
    }

    Drag.active: ma.drag.active

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        drag.target: floatingWindow
        onReleased: {
            floatingWindow.Drag.drop();
        }
    }
    GridLayout {
        columns: 2
        anchors.fill: parent

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 50

            Rectangle {
                width: 40
                height: 40
            }
            // Rectangle {
            //     id: floatingWindow2
            //
            //     width: 20
            //     height: 20
            //     color: Qt.rgba(0, 0, 0, 0.2)
            //
            //     border {
            //         width: 1
            //         color: "white"
            //     }
            //
            //     states: State {
            //         when: ma2.drag.active
            //         ParentChange {
            //             parent: null
            //         }
            //     }
            //     Drag.active: ma2.drag.active
            //
            //     MouseArea {
            //         id: ma2
            //         anchors.fill: parent
            //         drag.target: floatingWindow2
            //         onReleased: {
            //             const target = floatingWindow2.Drag.target;
            //             floatingWindow2.Drag.drop();
            //             if (target) {
            //                 console.log("has");
            //             } else {
            //                 floatingWindow2.x = floatingWindow.x;
            //                 floatingWindow2.y = floatingWindow.y;
            //             }
            //         }
            //     }
            // }
        }

        StackLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
