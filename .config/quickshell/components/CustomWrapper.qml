import QtQuick
import Quickshell
import QtQuick.Layouts

Scope {
    id: root

    property alias screenModel: screensModel
    property Component screenComponent

    Variants {
        id: screensModel
        model: Quickshell.screens

        delegate: Item {
            required property var modelData

            Loader {
                anchors.fill: parent
                active: true
                sourceComponent: root.screenComponent ? root.screenComponent : defaultComponent
                onLoaded: {
                    if (item && item.hasOwnProperty("modelData")) {
                        item.modelData = modelData;
                    }
                }
            }
        }
    }

    Component {
        id: defaultComponent
        PanelWindow {
            required property var modelData
            screen: modelData
            color: "transparent"
        }
    }
}
