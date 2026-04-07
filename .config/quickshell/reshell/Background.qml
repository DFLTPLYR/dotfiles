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
    property bool edit: false
    property bool fileExplorerOpen: false
    color: "transparent"
    signal dockUpdate(var data)

    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: {
        if (!Global.edit)
            return WlrLayer.Background;
        if ((wallpaperModal.opened || propertiesModal.opened) && !fileExplorerOpen)
            return WlrLayer.Top;
        return WlrLayer.Bottom;
    }
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: `Background-${screen.name}`

    mask: Region {
        item: mask
    }

    Item {
        id: layered
        width: parent.width
        height: parent.width

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

    Loader {
        id: mask
        anchors.fill: parent
        active: Global.edit
        sourceComponent: MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                switch (mouse.button) {
                case Qt.RightButton:
                    if (!contextMenu.opened) {
                        contextMenu.x = mouseX + contextMenu.width > screen.width ? mouseX - contextMenu.width : mouseX;
                        contextMenu.y = mouseY + contextMenu.height > screen.height ? mouseY - contextMenu.height : mouseY;
                    }
                    contextMenu.opened ? contextMenu.close() : contextMenu.open();
                    return;
                case Qt.LeftButton:
                    if (contextMenu.opened)
                        contextMenu.close();
                    return;
                default:
                    return;
                }
            }
        }
    }

    FilePicker {
        id: fileExplorer
        onOutput: data => {
            if (data) {
                var image = {
                    source: data.trim("%0A"),
                    name: Math.random().toString(36).substring(2, 10)
                };
                Wallpaper.config.layers.push(image);
                Wallpaper.save();
            }
            panel.fileExplorerOpen = false;
        }
    }

    // simple desktop popup
    ContextMenu {
        id: contextMenu
    }

    // Properties Modal
    PropertiesMenu {
        id: propertiesModal
    }

    // Wallpaper Modal
    WallpaperMenu {
        id: wallpaperModal
    }

    function onSaveCustomWallpaper() {
        layered.grabToImage(function (result) {
            result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);
            Qt.callLater(() => {
                Global.updateColor();
            });
        }, Qt.size(panel.screen.width, panel.screen.height));
    }

    component ContextMenu: PopupModal {
        id: modal
        width: popupContent.width + (modal.leftPadding + modal.rightPadding)
        height: popupContent.height + (modal.bottomPadding + modal.topPadding)

        ColumnLayout {
            id: popupContent
            spacing: 0

            Button {
                text: "Refresh"
                Layout.fillWidth: true
                onClicked: Quickshell.reload(true)
            }

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
                text: "Properties"
                Layout.fillWidth: true
                onClicked: {
                    propertiesModal.open();
                }
            }

            Button {
                text: "Change Wallpaper"
                Layout.fillWidth: true
                onClicked: {
                    wallpaperModal.open();
                }
            }
        }
    }

    component PropertiesMenu: PopupModal {
        id: propertiesModal
        x: screen.width / 2 - propertiesModal.width / 2
        y: screen.height / 2 - propertiesModal.height / 2

        Loader {
            active: propertiesModal.opened
            sourceComponent: Rectangle {
                color: Colors.color.background

                width: screen.width / 1.5
                height: screen.height / 1.5

                border {
                    width: 1
                    color: Colors.color.primary
                }

                Component.onCompleted: {
                    Global.bindRadii(this);
                    Global.properties = true;
                }
                Component.onDestruction: Global.properties = false
            }
        }
    }

    component WallpaperMenu: PopupModal {
        id: wallpaperModal
        x: screen.width / 2 - wallpaperModal.width / 2
        y: screen.height / 2 - wallpaperModal.height / 2

        Loader {
            active: wallpaperModal.opened
            sourceComponent: Rectangle {
                id: container
                color: "transparent"

                width: screen.width / 1.5
                height: screen.height / 1.5

                border {
                    width: 1
                    color: Colors.color.primary
                }

                clip: true

                // Nav
                TopLeftControl {}

                Flickable {
                    id: flick
                    property var selection: undefined
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

                function imageToScreenPosition() {
                    var images = content.children.filter(s => s instanceof PreviewImage);
                    var screens = content.children.filter(s => s instanceof Monitor);

                    for (var i in images) {
                        const target = images[i];
                        var props = {
                            source: target.image.source,
                            width: target.width,
                            height: target.height,
                            x: target.x,
                            y: target.y,
                            z: target.z,
                            name: target.objectName,
                            screens: []
                        };
                        for (var j in screens) {
                            const screen = screens[j];
                            var sx = screen.x;
                            var sy = screen.y;
                            var sw = screen.width;
                            var sh = screen.height;
                            var imgRight = props.x + props.width;
                            var imgBottom = props.y + props.height;
                            var screenRight = sx + sw;
                            var screenBottom = sy + sh;
                            if (props.x < screenRight && imgRight > sx && props.y < screenBottom && imgBottom > sy) {
                                var relative = {
                                    x: target.x - screen.x,
                                    y: target.y - screen.y,
                                    name: screen.objectName
                                };
                                props.screens.push(relative);
                            }
                        }

                        Wallpaper.config.layers = Wallpaper.config.layers.filter(s => s.name !== target.objectName);
                        Wallpaper.config.layers.push(props);
                    }

                    Wallpaper.save();
                }

                Component.onCompleted: {
                    Global.bindRadii(this);
                    Global.wallpaper = true;
                }
                Component.onDestruction: Global.wallpaper = false
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

    component PreviewImage: ResizeableRect {
        id: container

        required property var modelData
        property Image image: draggableImage
        property var found

        objectName: modelData.name

        width: (modelData.width || draggableImage.sourceSize.width)
        height: (modelData.height || draggableImage.sourceSize.height)

        x: (modelData.x || 0)
        y: (modelData.y || 0)

        // image
        Image {
            id: draggableImage
            property bool lock: (modelData.x && modelData.y) ? true : false
            width: container.width
            height: container.height
            source: Qt.resolvedUrl(modelData.source) || ""
            objectName: modelData.name
            z: -1

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

            DragHandler {
                id: dragHandler
                target: container
                enabled: !draggableImage.lock
            }
        }
    }

    component TopLeftControl: Row {
        id: controlContainer
        z: 2
        readonly property list<PreviewImage> imageList: content.children.filter(s => s instanceof PreviewImage)
        readonly property list<Monitor> screenList: content.children.filter(s => s instanceof Monitor)
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
                title: 'Layers'

                Button {
                    text: "Add file"
                    onClicked: {
                        panel.fileExplorerOpen = true;
                        fileExplorer.active();
                    }
                }

                Button {
                    text: "Check"
                    onClicked: container.imageToScreenPosition()
                }

                Button {
                    text: Global.docks ? "Hide Docks" : "Show Docks"
                    onClicked: Global.docks = !Global.docks
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
                    text: "Generate color"
                    onClicked: {
                        panel.onSaveCustomWallpaper();
                    }
                }
            }

            Menu {
                title: "Screens"
                Repeater {
                    model: [...controlContainer.screenList]
                    delegate: Button {
                        text: modelData.objectName
                    }
                }
            }
            Menu {
                title: "Images"
                Repeater {
                    model: [...controlContainer.imageList]
                    delegate: Button {
                        text: modelData.objectName
                    }
                }
            }
        }
    }

    component ResizeableRect: Rectangle {
        id: selComp
        property int rulersSize: 15 / flick.zoom

        border {
            width: 2
            color: Colors.color.tertiary
        }
        color: "transparent"

        Rectangle {
            width: rulersSize
            height: rulersSize
            radius: rulersSize
            color: Colors.color.primary
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.verticalCenter
            z: 10
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                drag {
                    target: parent
                    axis: Drag.XAxis
                }
                onMouseXChanged: {
                    if (drag.active) {
                        selComp.width = selComp.width - mouseX;
                        selComp.x = selComp.x + mouseX;
                        if (selComp.width < 30)
                            selComp.width = 30;
                    }
                }
            }
        }

        Rectangle {
            width: rulersSize
            height: rulersSize
            radius: rulersSize
            color: Colors.color.primary
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.verticalCenter
            z: 10

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                drag {
                    target: parent
                    axis: Drag.XAxis
                }
                onMouseXChanged: {
                    if (drag.active) {
                        selComp.width = selComp.width + mouseX;
                        if (selComp.width < 50)
                            selComp.width = 50;
                    }
                }
            }
        }

        Rectangle {
            width: rulersSize
            height: rulersSize
            radius: rulersSize
            x: parent.x / 2
            y: 0
            color: Colors.color.primary
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top
            z: 10

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                drag {
                    target: parent
                    axis: Drag.YAxis
                }

                onMouseYChanged: {
                    if (drag.active) {
                        selComp.height = selComp.height - mouseY;
                        selComp.y = selComp.y + mouseY;
                        if (selComp.height < 50)
                            selComp.height = 50;
                    }
                }
            }
        }

        Rectangle {
            width: rulersSize
            height: rulersSize
            radius: rulersSize
            x: parent.x / 2
            y: parent.y
            color: Colors.color.primary
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom
            z: 10

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                drag {
                    target: parent
                    axis: Drag.YAxis
                }
                onMouseYChanged: {
                    if (drag.active) {
                        selComp.height = selComp.height + mouseY;
                        if (selComp.height < 50)
                            selComp.height = 50;
                    }
                }
            }
        }
    }
}
