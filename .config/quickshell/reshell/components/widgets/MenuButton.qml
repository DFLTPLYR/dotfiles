import QtQuick
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.core
import qs.components

Wrapper {
    id: wrap
    // properties
    objectName: "MenuButton"
    setHeight: 50
    setWidth: 50
    relativeX: 0
    relativeY: 0
    position: -1
    // properties

    color: "transparent"

    Button {
        id: button
        anchors.fill: parent
        onClicked: {
            load.active = true;
        }

        LazyLoader {
            id: load
            active: false
            component: PopupWindow {
                id: test
                color: Colors.color.background
                anchor {
                    item: button
                    edges: Edges.Bottom | Edges.Right
                    rect {
                        x: button.width - width / 2
                        y: button.height
                    }
                }
                implicitWidth: 500
                implicitHeight: 500
                visible: true
            }
        }
    }
}
