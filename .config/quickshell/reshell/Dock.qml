import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.core
import qs.modules

PanelWindow {
    id: panel
    color: "transparent"
    // color: Colors.setOpacity(Colors.color.background, 0.2)
    required property string name
    objectName: panel.name

    anchors {
        top: config.position === "top"
        bottom: config.position === "bottom"
        left: config.position === "left"
        right: config.position === "right"
    }

    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Auto
    exclusiveZone: config.side ? config.width : config.height

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: `Dock-${panel.name}`

    mask: Region {
        regions: []
    }

    // Rectangle {
    //     id: container
    //
    //     states: [
    //         State {
    //             name: "left"
    //             when: config.position === "left"
    //             PropertyChanges {
    //                 target: panel
    //                 x: 0
    //                 y: (parent.height - height) * (config.y / 100)
    //                 width: config.width
    //                 height: parent.height * (config.height / 100)
    //             }
    //         },
    //         State {
    //             name: "right"
    //             when: config.position === "right"
    //             PropertyChanges {
    //                 target: panel
    //                 explicit: true
    //                 x: parent.width - config.width
    //                 y: (parent.height - height) * (config.y / 100)
    //                 width: config.width
    //                 height: parent.height * (config.height / 100)
    //             }
    //         },
    //         State {
    //             name: "top"
    //             when: config.position === "top"
    //             PropertyChanges {
    //                 target: panel
    //                 y: 0
    //                 x: (parent.width - width) * (config.x / 100)
    //                 width: parent.width * (config.width / 100)
    //                 height: config.height
    //             }
    //         },
    //         State {
    //             name: "bottom"
    //             when: config.position === "bottom"
    //             PropertyChanges {
    //                 target: panel
    //                 y: parent.height - config.height
    //                 x: (parent.width - width) * (config.x / 100)
    //                 width: parent.width * (config.width / 100)
    //                 height: config.height
    //             }
    //         }
    //     ]
    //
    //     transitions: [
    //         Transition {
    //             from: "*"
    //             to: "*"
    //             NumberAnimation {
    //                 properties: "width,height"
    //                 duration: 100
    //                 easing.type: Easing.OutCubic
    //             }
    //             NumberAnimation {
    //                 properties: "x,y"
    //                 duration: 100
    //                 easing.type: Easing.InOutQuad
    //             }
    //         }
    //     ]
    // }

    FileView {
        path: Qt.resolvedUrl(`./core/data/${screen.name}+${panel.name}.json`)
        watchChanges: true
        preload: true
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                config.setText("{}");
                config.writeAdapter();
            }
        }
        adapter: JsonAdapter {
            id: config
            property int height: 40
            property int width: 100
            property int x: 0
            property int y: 0
            property string position: "top"
            readonly property bool side: position === "left" || position === "right"
        }

        onLoaded: {
            container.width = config.width;
            container.height = config.height;

            // container.state = config.position;
            // container.state = Qt.binding(() => {
            //     return config.position;
            // });
        }
    }
}
