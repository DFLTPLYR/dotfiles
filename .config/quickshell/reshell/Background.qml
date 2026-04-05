import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import QtCore

import qs.core
import qs.components

PanelWindow {
    id: panel
    property var file
    readonly property var path: Wallpaper.config.source.filter(s => s && s.monitor === screen.name) || []
    color: "transparent"
    signal dockUpdate(var data)

    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: Global.edit ? WlrLayer.Bottom : WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: `Background-${screen.name}`

    mask: Region {
        item: mask
    }

    Item {
        id: layered
        width: parent.width
        height: parent.width

        Connections {
            target: Wallpaper
            function onGeneratecolor() {
                layered.onSaveCustomWallpaper();
            }
        }

        function onSaveCustomWallpaper() {
            layered.grabToImage(function (result) {
                result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);
                Qt.callLater(() => {
                    Global.updateColor();
                });
            }, Qt.size(panel.screen.width, panel.screen.height));
        }

        Instantiator {
            model: ScriptModel {
                values: [...Wallpaper.config.layers].filter(item => item && item.screens && item.screens.some(s => s && s.name === panel.screen.name))
            }
            delegate: Image {
                id: wallpaperImage
                required property var modelData
                property var relative: modelData.screens.find(s => s && s.name === panel.screen.name)
                parent: layered

                width: modelData.width
                height: modelData.height
                x: relative.x
                y: relative.y

                source: modelData.source
                opacity: 0

                states: State {
                    name: "visible"
                    PropertyChanges {
                        target: wallpaperImage
                        opacity: 1
                    }
                }

                transitions: [
                    Transition {
                        from: "*"
                        to: "*"
                        NumberAnimation {
                            properties: "opacity,scale"
                            duration: 300
                            easing.type: Easing.InOutSine
                        }
                    }
                ]
            }
            onObjectAdded: (idx, obj) => obj.state = "visible"
        }
    }

    Item {
        id: mask
        width: parent.width
        height: parent.width

        Loader {
            anchors.fill: parent
            active: true
            sourceComponent: MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    switch (mouse.button) {
                    case Qt.RightButton:
                        if (!modal.opened) {
                            modal.x = mouseX + modal.width > screen.width ? mouseX - modal.width : mouseX;
                            modal.y = mouseY + modal.height > screen.height ? mouseY - modal.height : mouseY;
                        }
                        modal.opened ? modal.close() : modal.open();
                        return;
                    case Qt.LeftButton:
                        if (modal.opened)
                            modal.close();
                        return;
                    default:
                        return;
                    }
                }
            }
        }
    }

    PopupModal {
        id: modal
        property bool wallpaper: false
        width: popupContent.width + (modal.leftPadding + modal.rightPadding)
        height: popupContent.height + (modal.bottomPadding + modal.topPadding)

        FilePicker {
            id: file
            onOutput: data => {
                if (data) {
                    var image = {
                        source: data.trim("%0A"),
                        name: Math.random().toString(36).substring(2, 10)
                    };
                    Wallpaper.config.layers.push(image);
                    Wallpaper.save();
                }
            }
        }

        ColumnLayout {
            id: popupContent
            spacing: 0

            Button {
                text: "Add Dock"
                Layout.fillWidth: true
                onClicked: mouse => {
                    var globalPos = mapToItem(null, modal.x, modal.y);
                    var l = globalPos.x;
                    var r = screen.width - globalPos.x;
                    var t = globalPos.y;
                    var b = screen.height - globalPos.y;

                    var min = Math.min(l, r, t, b);
                    var direction = min === l ? "left" : min === r ? "right" : min === t ? "top" : "bottom";

                    var name = Math.random().toString(36).substring(2, 10);
                    panel.file.adapter.docks.push(name);

                    panel.dockUpdate({
                        name,
                        direction
                    });
                }
            }

            Button {
                text: "Change Wallpaper"
                onClicked: modal.wallpaper = !modal.wallpaper
            }

            Loader {
                active: modal.wallpaper
                sourceComponent: Rectangle {
                    id: container
                    color: "transparent"
                    clip: true
                    width: screen.width / 1.5
                    height: screen.height / 1.5
                    TopLeftControl {}

                    border {
                        width: 1
                        color: Colors.color.primary
                    }

                    Flickable {
                        id: flick
                        property real zoom: 1
                        property int maxX: 0
                        property int maxY: 0
                        anchors.fill: parent

                        contentWidth: maxX + 2000
                        contentHeight: maxY + 2000
                        transformOrigin: Item.Center

                        // background grid
                        Canvas {
                            id: canvas
                            clip: false
                            width: flick.contentWidth
                            height: flick.contentHeight
                            onPaint: {
                                var ctx = getContext("2d");
                                var gridSize = 10;

                                ctx.strokeStyle = Colors.setOpacity(Colors.color.tertiary, 0.5);
                                ctx.lineWidth = 1;

                                for (var x = 0; x <= width; x += gridSize) {
                                    ctx.beginPath();
                                    ctx.moveTo(x, 0);
                                    ctx.lineTo(x, height);
                                    ctx.stroke();
                                }

                                for (var y = 0; y <= height; y += gridSize) {
                                    ctx.beginPath();
                                    ctx.moveTo(0, y);
                                    ctx.lineTo(width, y);
                                    ctx.stroke();
                                }
                            }
                        }

                        // overview
                        Item {
                            id: overview
                            width: flick.contentWidth
                            height: flick.contentHeight

                            Item {
                                id: content
                                scale: flick.zoom
                                transformOrigin: Item.TopLeft
                                anchors.centerIn: parent

                                // screens/monitors
                                Instantiator {
                                    model: Quickshell.screens
                                    delegate: Monitor {
                                        parent: content
                                    }
                                    onObjectAdded: (idx, obj) => {
                                        obj.parent = content;
                                        var m = obj.modelData;
                                        if (m.x + m.width > flick.maxX)
                                            flick.maxX = m.x + m.width;
                                        if (m.y + m.height > flick.maxY)
                                            flick.maxY = m.y + m.height;
                                    }
                                }

                                // Images
                                Instantiator {
                                    model: ScriptModel {
                                        values: [...Wallpaper.config.layers]
                                    }
                                    delegate: PreviewImage {
                                        parent: content
                                    }
                                }
                            }
                        }

                        // zoom in/out
                        WheelHandler {
                            id: wheelHandler
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            target: null

                            onWheel: event => {
                                var delta = event.angleDelta.y > 0 ? 0.1 : -0.1;
                                flick.zoom = Math.max(0.1, Math.min(5, flick.zoom + delta));
                            }
                        }
                    }

                    Component.onCompleted: {
                        Global.bindRadii(container);
                    }
                }
            }
        }
    }
    component Monitor: Rectangle {
        id: monitor
        required property ShellScreen modelData
        property var dock: Global.getConfigManager(`${modelData.name}-dock`)
        width: modelData.width
        height: modelData.height
        color: Colors.setOpacity(Colors.color.background, 0.2)
        objectName: modelData.name
        border {
            width: 1 * flick.zoom
            color: Colors.color.primary
        }
        x: modelData.x
        y: modelData.y
    }

    component PreviewImage: Item {
        id: container

        required property var modelData
        property Image image: draggableImage
        property var found
        // image
        Image {
            id: draggableImage
            property bool lock: (modelData.x && modelData.y) ? true : false

            width: (modelData.width || sourceSize.width)
            height: (modelData.height || sourceSize.height)
            source: Qt.resolvedUrl(modelData.source) || ""
            x: (modelData.x || 0)
            y: (modelData.y || 0)
            Drag.active: drag.active
            Drag.hotSpot.x: 10
            Drag.hotSpot.y: 10
            objectName: modelData.name

            DragHandler {
                id: drag
                target: draggableImage
                enabled: !draggableImage.lock
            }
            Row {
                z: 2
                opacity: 1

                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                Button {
                    width: 40 / flick.zoom
                    height: 40 / flick.zoom
                    Icon {
                        anchors.centerIn: parent
                        text: draggableImage.lock ? "lock" : "lock-slash"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }
                    onClicked: {
                        draggableImage.lock = !draggableImage.lock;
                    }
                }
                Button {
                    width: 40 / flick.zoom
                    height: 40 / flick.zoom
                    Icon {
                        anchors.centerIn: parent
                        text: "trash"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }
                    onClicked: {
                        var layers = Wallpaper.config.layers;
                        var idx = layers.findIndex(s => s.name === container.modelData.name);
                        if (idx >= 0) {
                            var newLayers = [...layers];
                            newLayers.splice(idx, 1);
                            Wallpaper.config.layers = newLayers;
                        }
                    }
                }
            }
        }

        // corner handler for resizing
        Repeater {
            model: [
                {
                    anchors: ["left", "top"]
                },
                {
                    anchors: ["right", "top"]
                },
                {
                    anchors: ["left", "bottom"]
                },
                {
                    anchors: ["right", "bottom"]
                },
            ]
            delegate: Rectangle {
                id: cornerHandle
                z: 2
                height: 20 / flick.zoom
                width: height
                radius: height / 2
                color: "green"
                opacity: !draggableImage.lock ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }

                anchors {
                    horizontalCenter: modelData.anchors.includes("left") ? draggableImage.left : modelData.anchors.includes("right") ? draggableImage.right : undefined
                    verticalCenter: modelData.anchors.includes("top") ? draggableImage.top : modelData.anchors.includes("bottom") ? draggableImage.bottom : undefined
                }

                MouseArea {
                    id: cornerPoint
                    anchors.fill: parent
                    drag.target: parent
                    enabled: !draggableImage.lock
                    onPositionChanged: mouse => {
                        if (drag.active) {
                            var anchors = modelData.anchors;
                            if (anchors.includes("right")) {
                                draggableImage.width = Math.max(50, parent.x - draggableImage.x);
                            }
                            if (anchors.includes("left")) {
                                var newWidth = draggableImage.width + (draggableImage.x - parent.x);
                                draggableImage.x = parent.x;
                                draggableImage.width = Math.max(50, newWidth);
                            }
                            if (anchors.includes("bottom")) {
                                draggableImage.height = Math.max(50, parent.y - draggableImage.y);
                            }
                            if (anchors.includes("top")) {
                                var newHeight = draggableImage.height + (draggableImage.y - parent.y);
                                draggableImage.y = parent.y;
                                draggableImage.height = Math.max(50, newHeight);
                            }
                        }
                    }
                }

                states: State {
                    when: cornerPoint.drag.active
                    AnchorChanges {
                        target: cornerHandle
                        anchors {
                            horizontalCenter: undefined
                            verticalCenter: undefined
                        }
                    }
                }
            }
        }
    }

    component TopLeftControl: Row {
        z: 2

        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 5
            topMargin: 5
        }

        MenuBar {
            Menu {
                leftPadding: 2
                rightPadding: 2

                width: 150
                title: 'Files'

                Button {
                    text: "add file"
                    onClicked: file.active()
                }

                Button {
                    text: "Save preset"
                    onClicked: {
                        var preset = {
                            source: Wallpaper.config.layers,
                            name: Math.random().toString(36).substring(2, 10)
                        };
                        Wallpaper.config.preset.push(preset);
                        Wallpaper.config.layers = [];
                    }
                }

                Button {
                    text: "Generate"
                    onClicked: Wallpaper.generatecolor()
                }

                MenuBar {
                    width: parent.width
                    Menu {
                        title: "Load preset"
                        width: parent.width
                        leftPadding: 2
                        rightPadding: 2
                    }
                }
            }

            Menu {
                leftPadding: 2
                rightPadding: 2

                width: 150
                title: 'Layers'

                Button {
                    text: "add file"
                    onClicked: file.active()
                }

                Button {
                    text: "check"
                    onClicked: wallpaperpage.imageToScreenPosition()
                }
                Button {
                    text: "save preset"
                    onClicked: {
                        var preset = {
                            source: Wallpaper.config.layers,
                            name: Math.random().toString(36).substring(2, 10)
                        };
                        Wallpaper.config.preset.push(preset);
                        Wallpaper.config.layers = [];
                    }
                }

                Button {
                    text: "generate color"
                    onClicked: Wallpaper.generatecolor()
                }
            }
        }
    }
}
