pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings
import System

Page {
    id: page
    GroupContainer {
        id: group
        label: "Displays"

        Rectangle {
            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }

            border {
                width: 1
                color: Colors.theme.on_surface
            }

            height: 500
            width: parent.width
            radius: 5
            clip: true
            color: "transparent"

            Flickable {
                id: flick
                property real zoom: 0.1
                property int maxX: 0
                property int maxY: 0

                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                focus: true
                acceptedButtons: Qt.MiddleButton | Qt.LeftButton
                clip: true
                contentWidth: maxX + 2000
                contentHeight: maxY + 2000

                contentX: (contentWidth - width) / 2
                contentY: (contentHeight - height) / 2
                transformOrigin: Item.Center

                // background grid
                Canvas {
                    id: canvas
                    clip: false
                    // anchors.fill: parent
                    width: flick.contentWidth
                    height: flick.contentHeight
                    onPaint: {
                        var ctx = getContext("2d");
                        var gridSize = 10;

                        ctx.strokeStyle = Colors.setOpacity(Colors.theme.on_surface, 0.5);
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

                // Display
                Item {
                    id: content

                    scale: flick.zoom
                    anchors.centerIn: parent

                    Repeater {
                        id: displayRepeater
                        model: Quickshell.screens
                        delegate: Display {}
                    }

                    Repeater {
                        id: containers
                        model: Background.wallpaperArr
                        delegate: DelegateChooser {
                            role: "type"
                            DelegateChoice {
                                roleValue: "image/gif"
                                AnimatedImage {
                                    required property string path
                                    source: path
                                }
                            }
                            DelegateChoice {
                                roleValue: "image/jpeg"
                                ResizeableImage {}
                            }
                            DelegateChoice {
                                roleValue: "image/jpg"
                                ResizeableImage {}
                            }
                            DelegateChoice {
                                roleValue: "image/png"
                                ResizeableImage {}
                            }
                        }
                    }
                }

                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    target: null

                    onWheel: event => {
                        let isShiftWheel = event.modifiers & Qt.ShiftModifier;
                        if (isShiftWheel) {
                            let delta = event.angleDelta.y > 0 ? 0.1 : -0.1;
                            flick.zoom = Math.max(0.1, Math.min(5, flick.zoom + delta));
                        }
                    }
                }

                Component.onCompleted: {
                    for (const s of Quickshell.screens) {
                        maxX = Math.max(maxX, s.x + s.width);
                        maxY = Math.max(maxY, s.y + s.height) / 2;
                    }
                }
            }
        }

        RowLayout {
            spacing: 10
            layoutDirection: Qt.RightToLeft
            Button {
                text: "Add Image"
                onClicked: {
                    fm.open();
                }

                FileManager {
                    id: fm
                    onOutput: (path, type) => {
                        const img = Background.imageContainerFactory.createObject(page, {
                            path,
                            type,
                            width: 0,
                            height: 0,
                            scale: 1
                        });
                        Background.wallpaperArr = [...Background.wallpaperArr, img];
                    }
                }
            }

            Button {
                text: "Apply"
                onClicked: {
                    Background.generate();
                    Background.save();
                }
            }
        }
    }

    ColorSchemeSection {}

    FileManager {
        id: changefm
        property var target: null
        onOutput: (path, type) => {
            target.path = path;
            target.type = type;
            target = null;
        }
    }

    component Display: Rectangle {
        id: display
        required property ShellScreen modelData

        width: modelData.width
        height: modelData.height
        color: Colors.setOpacity(Colors.theme.surface, 0.2)
        x: modelData.x
        y: modelData.y
        z: 999

        // Outline
        Item {
            anchors.fill: parent
            property real zoom: flick.zoom
            focusPolicy: Qt.NoFocus
            focus: false
            // border
            Rectangle {
                anchors {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                }
                height: 2 / flick.zoom
                color: Colors.theme.primary
            }

            Rectangle {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    left: parent.left
                }
                height: 2 / flick.zoom
                color: Colors.theme.primary
                y: parent.height
            }

            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }
                width: 2 / flick.zoom
                color: Colors.theme.primary
            }
            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                width: 2 / flick.zoom
                color: Colors.theme.primary
                x: parent.width
            }
        }
    }

    component ResizeableImage: Image {
        id: rezImg
        required property int index
        required property var modelData
        source: modelData.path
        readonly property int handlerSize: 30
        property bool pointerVisible: true

        function setDimension() {
            modelData.x = x;
            modelData.y = y;
            modelData.width = width;
            modelData.height = height;
        }

        width: modelData.width ?? sourceSize.width
        height: modelData.height ?? sourceSize.height
        x: modelData.x ?? 0
        y: modelData.y ?? 0
        scale: modelData.scale

        Component.onCompleted: {
            if (modelData.width === 0)
                width = sourceSize.width;
            if (modelData.height === 0)
                height = sourceSize.height;
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            drag.target: rezImg
            onReleased: rezImg.setDimension()
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    options.x = mouse.x;
                    options.y = mouse.y;
                    options.opened ? options.close() : options.open();
                }
            }
        }

        WheelHandler {
            orientation: Qt.Vertical
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: {
                const scale = rezImg.modelData.scale;
                let delta = event.angleDelta.y > 0 ? 1 : -1;
                if (scale === 1 && delta === -1)
                    return;
                rezImg.modelData.scale = scale + delta;
            }
        }

        Menu {
            id: options

            Action {
                text: "Native Resolution"
                onTriggered: {
                    rezImg.scale = 1;
                    rezImg.width = sourceSize.width;
                    rezImg.height = sourceSize.height;
                }
            }

            Action {
                text: "Change Image"
                onTriggered: {
                    changefm.target = rezImg.modelData;
                    changefm.open();
                }
            }

            Action {
                text: "Remove"
                onTriggered: {
                    const w = Background.wallpaperArr.slice();
                    w.splice(rezImg.index, 1);
                    Background.wallpaperArr = w;
                }
            }
        }

        // Sides
        Rectangle {
            id: leftHandle

            width: rezImg.handlerSize
            height: rezImg.handlerSize
            radius: rezImg.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.verticalCenter
            opacity: rezImg.pointerVisible ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: leftHandleArea.containsMouse && !leftHandleArea.drag.active

                    PropertyChanges {
                        target: leftHandle
                        color: Colors.theme.secondary
                    }
                },
                State {
                    name: "dragging"
                    when: leftHandleArea.drag.active

                    PropertyChanges {
                        target: leftHandle
                        color: Colors.theme.tertiary
                    }
                }
            ]

            MouseArea {
                id: leftHandleArea

                anchors.fill: parent
                enabled: rezImg.pointerVisible
                hoverEnabled: true
                onMouseXChanged: {
                    if (drag.active) {
                        rezImg.width = rezImg.width - mouseX;
                        rezImg.x = rezImg.x + mouseX;
                        if (rezImg.width < 30)
                            rezImg.width = 30;
                    }
                }

                onReleased: mouse => {
                    rezImg.setDimension();
                }

                drag {
                    target: parent
                    axis: Drag.XAxis
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: rightHandle

            width: rezImg.handlerSize
            height: rezImg.handlerSize
            radius: rezImg.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.verticalCenter
            opacity: rezImg.pointerVisible ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: rightHandleArea.containsMouse && !rightHandleArea.drag.active

                    PropertyChanges {
                        target: rightHandle
                        color: Colors.theme.secondary
                    }
                },
                State {
                    name: "dragging"
                    when: rightHandleArea.drag.active

                    PropertyChanges {
                        target: rightHandle
                        color: Colors.theme.tertiary
                    }
                }
            ]

            MouseArea {
                id: rightHandleArea

                anchors.fill: parent
                enabled: rezImg.pointerVisible
                hoverEnabled: true
                onMouseXChanged: {
                    if (drag.active) {
                        rezImg.width = rezImg.width + mouseX;
                        if (rezImg.width < 50)
                            rezImg.width = 50;
                    }
                }

                onReleased: mouse => {
                    rezImg.setDimension();
                }

                drag {
                    target: parent
                    axis: Drag.XAxis
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: topHandle

            width: rezImg.handlerSize
            height: rezImg.handlerSize
            radius: rezImg.handlerSize
            x: parent.x / 2
            y: 0
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top
            opacity: rezImg.pointerVisible ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: topHandleArea.containsMouse && !topHandleArea.drag.active

                    PropertyChanges {
                        target: topHandle
                        color: Colors.theme.secondary
                    }
                },
                State {
                    name: "dragging"
                    when: topHandleArea.drag.active

                    PropertyChanges {
                        target: topHandle
                        color: Colors.theme.tertiary
                    }
                }
            ]

            MouseArea {
                id: topHandleArea

                anchors.fill: parent
                enabled: rezImg.pointerVisible
                hoverEnabled: true
                onMouseYChanged: {
                    if (drag.active) {
                        rezImg.height = rezImg.height - mouseY;
                        rezImg.y = rezImg.y + mouseY;
                        if (rezImg.height < 50)
                            rezImg.height = 50;
                    }
                }

                onReleased: mouse => {
                    rezImg.setDimension();
                }

                drag {
                    target: parent
                    axis: Drag.YAxis
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: bottomHandle

            width: rezImg.handlerSize
            height: rezImg.handlerSize
            radius: rezImg.handlerSize
            x: parent.x / 2
            y: parent.y
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom
            opacity: rezImg.pointerVisible ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: bottomHandleArea.containsMouse && !bottomHandleArea.drag.active

                    PropertyChanges {
                        target: bottomHandle
                        color: Colors.theme.secondary
                    }
                },
                State {
                    name: "dragging"
                    when: bottomHandleArea.drag.active

                    PropertyChanges {
                        target: bottomHandle
                        color: Colors.theme.tertiary
                    }
                }
            ]

            MouseArea {
                id: bottomHandleArea

                anchors.fill: parent
                enabled: rezImg.pointerVisible
                hoverEnabled: true
                onMouseYChanged: {
                    if (drag.active) {
                        rezImg.height = rezImg.height + mouseY;
                        if (rezImg.height < 50)
                            rezImg.height = 50;
                    }
                }

                onReleased: mouse => {
                    rezImg.setDimension();
                }

                drag {
                    target: parent
                    axis: Drag.YAxis
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Corners
        Rectangle {
            id: topRightHandle

            width: rezImg.handlerSize
            height: rezImg.handlerSize
            radius: rezImg.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.top

            opacity: rezImg.pointerVisible ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: topRightHandleArea.containsMouse && !topRightHandleArea.drag.active

                    PropertyChanges {
                        target: topRightHandle
                        color: Colors.theme.secondary
                    }
                },
                State {
                    name: "dragging"
                    when: topRightHandleArea.drag.active

                    PropertyChanges {
                        target: topRightHandle
                        color: Colors.theme.tertiary
                    }
                }
            ]

            MouseArea {
                id: topRightHandleArea

                anchors.fill: parent
                enabled: rezImg.pointerVisible
                hoverEnabled: true
                onMouseYChanged: {
                    if (drag.active) {
                        rezImg.height = rezImg.height - mouseY;
                        rezImg.y = rezImg.y + mouseY;
                        if (rezImg.height < 50)
                            rezImg.height = 50;

                        rezImg.width = rezImg.width + mouseX;
                        if (rezImg.width < 50)
                            rezImg.width = 50;
                    }
                }

                onReleased: mouse => {
                    rezImg.setDimension();
                }

                drag {
                    target: parent
                    axis: Drag.YAxis | Drag.XAxis
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: topLeftHandle

            width: rezImg.handlerSize
            height: rezImg.handlerSize
            radius: rezImg.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.top

            opacity: rezImg.pointerVisible ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: topLeftHandleArea.containsMouse && !topLeftHandleArea.drag.active

                    PropertyChanges {
                        target: topLeftHandle
                        color: Colors.theme.secondary
                    }
                },
                State {
                    name: "dragging"
                    when: topLeftHandleArea.drag.active

                    PropertyChanges {
                        target: topLeftHandle
                        color: Colors.theme.tertiary
                    }
                }
            ]

            MouseArea {
                id: topLeftHandleArea

                anchors.fill: parent
                enabled: rezImg.pointerVisible
                hoverEnabled: true
                onMouseYChanged: {
                    if (drag.active) {
                        rezImg.height = rezImg.height - mouseY;
                        rezImg.y = rezImg.y + mouseY;

                        rezImg.width = rezImg.width - mouseX;
                        rezImg.x = rezImg.x + mouseX;
                        if (rezImg.width < 50)
                            rezImg.width = 50;
                        if (rezImg.height < 50)
                            rezImg.height = 50;
                    }
                }

                onReleased: mouse => {
                    rezImg.setDimension();
                }

                drag {
                    target: parent
                    axis: Drag.YAxis | Drag.XAxis
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: bottomRightHandle

            width: rezImg.handlerSize
            height: rezImg.handlerSize
            radius: rezImg.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.bottom

            opacity: rezImg.pointerVisible ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: bottomRightHandleArea.containsMouse && !bottomRightHandleArea.drag.active

                    PropertyChanges {
                        target: bottomRightHandle
                        color: Colors.theme.secondary
                    }
                },
                State {
                    name: "dragging"
                    when: bottomRightHandleArea.drag.active

                    PropertyChanges {
                        target: bottomRightHandle
                        color: Colors.theme.tertiary
                    }
                }
            ]

            MouseArea {
                id: bottomRightHandleArea

                anchors.fill: parent
                enabled: rezImg.pointerVisible
                hoverEnabled: true
                onMouseYChanged: {
                    if (drag.active) {
                        rezImg.height = rezImg.height + mouseY;
                        rezImg.width = rezImg.width + mouseX;
                        if (rezImg.height < 50)
                            rezImg.height = 50;

                        if (rezImg.width < 50)
                            rezImg.width = 50;
                    }
                }

                onReleased: mouse => {
                    rezImg.setDimension();
                }

                drag {
                    target: parent
                    axis: Drag.YAxis | Drag.XAxis
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: bottomLeftHandle

            width: rezImg.handlerSize
            height: rezImg.handlerSize
            radius: rezImg.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.bottom

            opacity: rezImg.pointerVisible ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: bottomLeftHandleArea.containsMouse && !bottomLeftHandleArea.drag.active

                    PropertyChanges {
                        target: bottomLeftHandle
                        color: Colors.theme.secondary
                    }
                },
                State {
                    name: "dragging"
                    when: bottomLeftHandleArea.drag.active

                    PropertyChanges {
                        target: bottomLeftHandle
                        color: Colors.theme.tertiary
                    }
                }
            ]

            MouseArea {
                id: bottomLeftHandleArea

                anchors.fill: parent
                enabled: rezImg.pointerVisible
                hoverEnabled: true
                onMouseYChanged: {
                    if (drag.active) {
                        rezImg.height = rezImg.height + mouseY;
                        rezImg.width = rezImg.width - mouseX;
                        rezImg.x = rezImg.x + mouseX;
                        if (rezImg.height < 50)
                            rezImg.height = 50;
                        if (rezImg.width < 50)
                            rezImg.width = 50;
                    }
                }

                onReleased: mouse => {
                    rezImg.setDimension();
                }

                drag {
                    target: parent
                    axis: Drag.YAxis | Drag.XAxis
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    component ColorSchemeSection: GroupContainer {
        label: "Color Scheme"

        Toggle {
            id: darkmodeToggle
            text: "Dark mode"
            checkable: true
            checked: ColorGen.isDarkMode
            onCheckedChanged: {
                const colorscheme = Colors.themes.find(s => s.name === Global.general.theme);
                const text = colorscheme.file.text();
                ColorGen.isDarkMode = checked;
                ColorGen.changeTheme(text);
            }
        }

        ListView {
            clip: true
            spacing: 10

            anchors {
                left: parent.left
                right: parent.right
            }
            height: 150
            orientation: ListView.Horizontal
            boundsBehavior: ListView.StopAtBounds
            model: Colors.themes

            delegate: Item {
                id: theme
                required property var model
                property var dark: model.dark
                property var light: model.light
                readonly property bool current: Global.general.theme === model.name
                height: ListView.view.height
                width: height

                ColumnLayout {
                    anchors.fill: parent

                    Label {
                        id: label
                        Layout.fillWidth: true
                        text: theme.model.name
                        color: theme.current ? Colors.theme.primary : Colors.theme.on_surface

                        Behavior on color {
                            ColorAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Pane {
                            anchors.centerIn: parent
                            width: parent.height
                            height: parent.height
                            bg.color: theme.current ? Colors.theme.on_surface : Colors.theme.on_surface_variant
                            bg.radius: (ma.containsMouse || theme.current) ? 12 : 6

                            Behavior on bg.color {
                                ColorAnimation {
                                    duration: 300
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            Behavior on bg.radius {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            Grid {
                                id: grid
                                anchors.fill: parent
                                columns: 2
                                spacing: 0

                                Repeater {
                                    model: ["primary", "secondary", "tertiary", "surface"]
                                    delegate: Item {
                                        required property string modelData
                                        width: grid.width / 2
                                        height: grid.height / 2

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, parent.height) * 0.9
                                            height: width
                                            radius: (ma.containsMouse || theme.current) ? height * 1 : height * 0.1
                                            color: darkmodeToggle.checked ? theme.dark[modelData] : theme.light[modelData]

                                            Behavior on radius {
                                                NumberAnimation {
                                                    duration: 300
                                                    easing.type: Easing.InOutQuad
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    enabled: theme.current || !ColorGen.isRunning
                    hoverEnabled: true
                    onClicked: {
                        const colorscheme = Colors.themes.find(s => s.name === theme.model.name);
                        if (!colorscheme)
                            return;
                        Global.general.theme = theme.model.name;
                        if (!colorscheme.file)
                            return;
                        const text = colorscheme.file.text();
                        ColorGen.changeTheme(text);
                    }
                }
            }
        }

        ListView {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: 150
            orientation: ListView.Horizontal
            boundsBehavior: ListView.StopAtBounds
            model: ColorGen.variantTypes
            delegate: RadioDelegate {
                required property var modelData
                text: modelData
                checked: modelData === ColorGen.variant
                onCheckedChanged: {
                    if (!checked)
                        return;
                    ColorGen.variant = modelData;
                    if (Global.general.theme === "dynamic") {
                        const colorscheme = Colors.themes.find(s => s.name === "dynamic");
                        const text = colorscheme.file.text();
                        ColorGen.changeTheme(text);
                    }
                }
            }
        }
    }
}
