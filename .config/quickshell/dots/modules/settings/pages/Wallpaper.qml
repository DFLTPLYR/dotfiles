import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import QtCore

import Quickshell
import Quickshell.Io

import qs.utils
import qs.config
import qs.components

PageWrapper {
    id: wallpaper
    property list<string> wallpaperPathList: []
    property list<var> coordinates: []
    property ShellScreen selectedScreen: Quickshell.screens[0]
    signal updateLocation
    signal saveCustomWallpaper

    PageHeader {
        title: "Wallpaper"
    }

    Spacer {}

    FileDialog {
        id: fileDialog
        property Item targetItem
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        onAccepted: {
            if (wallpaper.selectedScreen && !Config.general.useCustomWallpaper) {
                const targetMonitor = Config.general.previewWallpaper.findIndex(w => w && w.monitor === wallpaper.selectedScreen.name);
                if (targetMonitor != -1) {
                    Config.general.previewWallpaper[targetMonitor].path = selectedFile.path;
                } else {
                    const monitor = {
                        monitor: wallpaper.selectedScreen.name,
                        path: selectedFile,
                        isGif: selectedFile.toString().toLowerCase().endsWith(".gif")
                    };
                    Config.general.previewWallpaper.push(monitor);
                }
            } else {
                wallpaper.wallpaperPathList.push(selectedFile);
            }
            Config.general.recentWallpapers.push({
                monitor: wallpaper.selectedScreen.name,
                timestamp: Date.now(),
                path: selectedFile
            });
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Label {
            text: qsTr("Panels:")
            font.pixelSize: 32
            color: Colors.color.on_surface
        }

        StyledSwitch {
            label: "Custom Wallpaper"
            onClicked: {
                Config.general.useCustomWallpaper = !Config.general.useCustomWallpaper;
            }
        }

        // panel
        Rectangle {
            id: panelContent
            visible: Config.general.useCustomWallpaper
            Layout.fillWidth: true
            Layout.preferredHeight: screen.height / 2
            clip: true
            color: "transparent"
            border.color: Colors.color.secondary

            Column {
                z: 2
                anchors {
                    margins: 10
                    top: parent.top
                    right: parent.right
                }

                StyledButton {
                    width: 40
                    height: 40
                    hoverEnabled: true
                    bgColor: hovered ? Scripts.setOpacity(Colors.color.background, 0.9) : Scripts.setOpacity(Colors.color.background, 0.2)
                    borderWidth: 1
                    borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

                    FontIcon {
                        anchors.centerIn: parent
                        text: "check"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }

                    onClicked: {
                        wallpaper.updateLocation();
                        if (wallpaper.coordinates) {
                            let monitors = [];
                            wallpaper.coordinates.forEach(item => {
                                monitors.push(item);
                            });
                            Config.saveSettings();
                        }
                    }
                }

                StyledButton {
                    width: 40
                    height: 40
                    hoverEnabled: true
                    bgColor: hovered ? Scripts.setOpacity(Colors.color.background, 0.9) : Scripts.setOpacity(Colors.color.background, 0.2)

                    borderWidth: 1
                    borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

                    FontIcon {
                        anchors.centerIn: parent
                        text: "image-square-check"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }

                    onClicked: {
                        wallpaper.saveCustomWallpaper();
                    }
                }

                StyledButton {
                    width: 40
                    height: 40
                    hoverEnabled: true
                    bgColor: hovered ? Scripts.setOpacity(Colors.color.background, 0.9) : Scripts.setOpacity(Colors.color.background, 0.2)
                    borderWidth: 1
                    borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

                    FontIcon {
                        anchors.centerIn: parent
                        text: "circle-minus"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }

                    onClicked: {
                        Config.general.zoom = Math.min(10, Config.general.zoom + 1);
                        Config.saveSettings();
                    }
                }

                StyledButton {
                    width: 40
                    height: 40
                    hoverEnabled: true
                    bgColor: hovered ? Scripts.setOpacity(Colors.color.background, 0.9) : Scripts.setOpacity(Colors.color.background, 0.2)
                    borderWidth: 1
                    borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)
                    FontIcon {
                        anchors.centerIn: parent
                        text: "circle-plus"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }

                    onClicked: {
                        Config.general.zoom = Math.max(1, Config.general.zoom - 1);
                        Config.saveSettings();
                    }
                }
            }

            Rectangle {
                id: offScreenCapture
                width: parent.width
                height: parent.height
                color: "transparent"
                z: -1

                Repeater {
                    id: ghostPreviewRepeater
                    model: wallpaper.coordinates

                    function reset() {
                        const tempModel = model;
                        model = undefined;
                        model = tempModel;
                    }

                    delegate: Rectangle {
                        id: ghostPreview
                        required property var modelData
                        width: modelData.width
                        height: modelData.height
                        x: modelData.previewX
                        y: modelData.previewY
                        clip: true

                        Instantiator {
                            model: modelData.images
                            delegate: Image {
                                id: tempImage
                                parent: ghostPreview
                                required property var modelData
                                source: modelData.path
                                width: modelData.width
                                height: modelData.height
                                smooth: true
                                mipmap: true
                                antialiasing: true
                                x: modelData.x - ghostPreview.x
                                y: modelData.y - ghostPreview.y
                            }
                        }

                        Connections {
                            target: wallpaper
                            function onSaveCustomWallpaper() {
                                ghostPreview.grabToImage(function (result) {
                                    result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${modelData.name}.jpg`);
                                    ghostPreview.setWallpaper();
                                }, Qt.size(width * Config.general.zoom, height * Config.general.zoom));
                            }
                        }

                        function setWallpaper() {
                            const image = {
                                path: `${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${modelData.name}.jpg`,
                                monitor: modelData.name
                            };
                            const target = Config.general.customWallpaper.findIndex(i => i && i.monitor === modelData.name);

                            if (target != -1) {
                                Config.general.customWallpaper[target].path = image.path;
                            } else {
                                Config.general.customWallpaper.push(image);
                            }
                            Qt.callLater(() => {
                                Config.reload();
                                Config.saveSettings();
                                cmdGenerateColor.running = true;
                            });
                        }
                    }
                }
            }

            // Draggable Area
            Item {
                id: imagePreviewContainer
                width: parent.width
                height: parent.height

                Repeater {
                    model: Quickshell.screens
                    delegate: Rectangle {
                        id: screenPreview
                        required property ShellScreen modelData
                        readonly property var monitorData: Config.general.monitorPosition.find(s => s.name === modelData.name)
                        property bool lock: true
                        property bool hoveredState: screenDragArea.containsMouse || screenLockPosition.hovered
                        z: 2
                        width: modelData.width / Config.general.zoom
                        height: modelData.height / Config.general.zoom
                        color: Scripts.setOpacity(Colors.color.background, 0.5)
                        border.color: Colors.color.secondary
                        border.width: 1
                        Drag.active: !screenPreview.lock ? screenDragArea.drag.active : false
                        Drag.hotSpot.x: 10
                        Drag.hotSpot.y: 10

                        Row {
                            z: 2
                            opacity: screenPreview.hoveredState ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }

                            StyledButton {
                                id: screenLockPosition
                                width: 40
                                height: 40
                                bgColor: Scripts.setOpacity(Colors.color.background, 0.9)
                                borderWidth: 1
                                borderColor: Scripts.setOpacity(Colors.color.secondary, 0.9)

                                FontIcon {
                                    anchors.centerIn: parent
                                    text: screenPreview.lock ? "lock" : "lock-slash"
                                    font.pixelSize: parent.width / 2
                                    color: Colors.color.secondary
                                }

                                onClicked: {
                                    screenPreview.lock = !screenPreview.lock;
                                    const index = Config.general.monitorPosition.findIndex(s => s.name === modelData.name);
                                    const monitor = {
                                        name: modelData.name,
                                        x: screenPreview.x,
                                        y: screenPreview.y
                                    };
                                    if (index === -1) {
                                        Config.general.monitorPosition.push(monitor);
                                    } else {
                                        const target = Config.general.monitorPosition[index];
                                        target.x = screenPreview.x;
                                        target.y = screenPreview.y;
                                    }

                                    Config.saveSettings();
                                }
                            }
                        }

                        MouseArea {
                            id: screenDragArea
                            hoverEnabled: true
                            anchors.fill: parent
                            drag.target: !screenPreview.lock ? parent : undefined
                        }

                        function updateWallpaper() {
                            let wallpapers = previewImageInstantiator.imagecomps;
                            if (wallpapers.lenght > 0)
                                return;
                            let images = [];
                            for (let i in wallpapers) {
                                let wallpaper = wallpapers[i];
                                const relativeX = wallpaper.image.x;
                                const relativeY = wallpaper.image.y;

                                images.push({
                                    path: wallpaper.modelData,
                                    width: wallpaper.image.width,
                                    height: wallpaper.image.height,
                                    x: relativeX,
                                    y: relativeY
                                });
                            }
                            const target = wallpaper.coordinates.findIndex(w => w && w.monitor === modelData.name);
                            if (target !== -1) {
                                wallpaper.coordinates[target].previewY = screenPreview.y;
                                wallpaper.coordinates[target].previewX = screenPreview.x;
                                wallpaper.coordinates[target].images = images;
                            } else {
                                wallpaper.coordinates.push({
                                    name: modelData.name,
                                    width,
                                    height,
                                    previewX: x,
                                    previewY: y,
                                    images: images
                                });
                            }
                        }

                        Connections {
                            target: wallpaper
                            function onUpdateLocation() {
                                screenPreview.updateWallpaper();
                            }
                        }
                        Component.onCompleted: {
                            x = monitorData ? monitorData.x : 0;
                            y = monitorData ? monitorData.y : 0;
                        }
                    }
                }

                Instantiator {
                    id: previewImageInstantiator
                    property list<Item> imagecomps: []
                    model: ScriptModel {
                        values: {
                            return wallpaper.wallpaperPathList;
                        }
                    }
                    delegate: Rectangle {
                        id: container
                        parent: imagePreviewContainer

                        required property var modelData
                        property Item image: draggableImage

                        Image {
                            id: draggableImage
                            property bool lock
                            width: sourceSize.width / Config.general.zoom
                            height: sourceSize.height / Config.general.zoom
                            source: modelData
                            Drag.active: imageMa.drag.active
                            Drag.hotSpot.x: 10
                            Drag.hotSpot.y: 10

                            MouseArea {
                                id: imageMa
                                anchors.fill: parent
                                drag.target: parent
                                hoverEnabled: true
                                enabled: !draggableImage.lock
                            }

                            Row {
                                z: 2
                                opacity: 1

                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    horizontalCenter: parent.horizontalCenter
                                }

                                StyledButton {
                                    width: 40
                                    height: 40
                                    bgColor: Scripts.setOpacity(Colors.color.background, 0.9)
                                    borderWidth: 1
                                    borderColor: Scripts.setOpacity(Colors.color.secondary, 0.9)
                                    FontIcon {
                                        anchors.centerIn: parent
                                        text: draggableImage.lock ? "lock" : "lock-slash"
                                        font.pixelSize: parent.width / 2
                                        color: Colors.color.secondary
                                    }
                                    onClicked: {
                                        draggableImage.lock = !draggableImage.lock;
                                    }
                                }
                            }
                        }

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
                                z: 10
                                height: 10
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

                    onObjectAdded: (idx, item) => {
                        imagecomps.push(item);
                    }
                    onObjectRemoved: (idx, item) => {
                        imagecomps.splice(idx, 1);
                    }
                }
            }
        }

        // per monitor
        Item {
            visible: !Config.general.useCustomWallpaper
            Layout.fillWidth: true
            Layout.preferredHeight: monitorRow.height

            RowLayout {
                id: monitorRow
                anchors.centerIn: parent
                Repeater {
                    model: Quickshell.screens
                    delegate: Rectangle {
                        required property ShellScreen modelData
                        readonly property string filePath: Config.general.wallpapers.find(wallpaperItem => wallpaperItem && wallpaperItem.monitor === modelData.name)?.path || ""
                        readonly property string tempPath: Config.general.previewWallpaper.find(wallpaperItem => wallpaperItem && wallpaperItem.monitor === modelData.name)?.path || ""
                        readonly property string imagePath: tempPath || filePath

                        color: "transparent"
                        border.color: wallpaper.selectedScreen.name === modelData.name ? Colors.color.inverse_primary : Colors.color.primary

                        Layout.preferredHeight: modelData.height / 4
                        Layout.preferredWidth: modelData.width / 4

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Text {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }
                            text: modelData.name
                            color: Colors.color.on_surface
                            z: 10
                        }

                        Image {
                            id: monitorBg
                            anchors.fill: parent
                            anchors.margins: wallpaper.selectedScreen.name === modelData.name ? 2 : 1

                            Behavior on anchors.margins {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            fillMode: Image.PreserveAspectCrop
                            source: imagePath
                            onSourceChanged: {
                                let wallpaperIndex = Config.general.recentWallpapers.findIndex(w => String(w.path).trim().toLowerCase() === String(source).trim().toLowerCase() && w.monitor === modelData.name);
                                if (wallpaperIndex !== -1) {
                                    Config.general.recentWallpapers[wallpaperIndex].timestamp = Date.now();
                                }
                            }
                        }

                        MouseArea {
                            id: monitorArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                wallpaper.selectedScreen = modelData;
                            }
                        }
                    }
                }
            }
        }

        StyledButton {
            text: "Change Wallpaper " + wallpaper.selectedScreen.name
            onClicked: {
                fileDialog.open();
            }
        }

        ListView {
            id: recentWallpapersList
            visible: model.length > 0
            readonly property string currentWallpaper: Config.general.wallpapers.find(wallpaper => wallpaper?.monitor === wallpaper.selectedScreen.name)?.path || ""
            readonly property bool isPortrait: wallpaper.selectedScreen.height > selectedScreen.width
            readonly property int itemHeight: wallpaper.selectedScreen.height / 4
            readonly property int itemWidth: wallpaper.selectedScreen.width / 4
            Layout.fillWidth: true
            Layout.preferredHeight: itemHeight
            orientation: recentWallpapersList.isPortrait ? ListView.Vertical : ListView.Horizontal
            layoutDirection: Qt.LeftToRight
            spacing: 5
            model: Config.general.recentWallpapers.filter(item => item.monitor === wallpaper.selectedScreen.name).sort((a, b) => b.timestamp - a.timestamp)
            delegate: Rectangle {
                id: recItem
                property bool isSetCurrent: recentWallpapersList.currentWallpaper === modelData.path
                color: "transparent"
                border.width: recentWallMa.containsMouse ? 2 : 1
                border.color: recentWallpapersList.currentWallpaper === modelData.path ? Colors.color.tertiary : recentWallMa.containsMouse ? Colors.color.inverse_primary : Colors.color.primary
                height: recentWallpapersList.itemHeight
                width: recentWallpapersList.itemWidth

                Image {
                    anchors {
                        fill: parent
                        margins: 2
                    }
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    source: Qt.resolvedUrl(modelData.path)
                    onStatusChanged: {
                        if (status === Image.Error) {
                            const pathToRemove = modelData.path;
                            Config.general.recentWallpapers = Config.general.recentWallpapers.filter(item => item.path !== pathToRemove);
                            Config.saveSettings();
                        }
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 350
                        easing.type: Easing.InOutQuad
                    }
                }

                Row {
                    z: 1
                    visible: !recItem.isSetCurrent || Config.general.useCustomWallpaper
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        margins: 5
                    }
                    spacing: 5

                    Rectangle {
                        width: 40
                        height: 40
                        radius: height / 2
                        color: Colors.color.background

                        Text {
                            font.family: Config.iconFont.family
                            font.weight: Config.iconFont.weight
                            font.styleName: Config.iconFont.styleName
                            font.pixelSize: Math.min(parent.height, parent.width) / 2
                            color: !recItem.isSetCurrent ? Colors.color.primary : Colors.color.tertiary

                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }
                            text: "eye"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (Config.general.useCustomWallpaper) {
                                    wallpaper.wallpaperPathList.push(modelData.path);
                                    return;
                                }
                                const targetMonitor = Config.general.previewWallpaper.findIndex(w => w && w.monitor === wallpaper.selectedScreen.name);
                                if (targetMonitor != -1) {
                                    Config.general.previewWallpaper[targetMonitor].path = modelData.path;
                                } else {
                                    const monitor = {
                                        monitor: wallpaper.selectedScreen.name,
                                        path: modelData.path,
                                        isGif: modelData.path.toString().toLowerCase().endsWith(".gif")
                                    };
                                    Config.general.previewWallpaper.push(monitor);
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 40
                        radius: height / 2
                        color: Colors.color.background

                        Text {
                            font.family: Config.iconFont.family
                            font.weight: Config.iconFont.weight
                            font.styleName: Config.iconFont.styleName
                            font.pixelSize: Math.min(parent.height, parent.width) / 2
                            color: !recItem.isSetCurrent ? Colors.color.primary : Colors.color.tertiary

                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }
                            text: "circle-check"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (Config.general.useCustomWallpaper) {
                                    wallpaper.wallpaperPathList.push(modelData.path);
                                    return;
                                }
                                const targetMonitor = Config.general.wallpapers.findIndex(w => w && w.monitor === wallpaper.selectedScreen.name);
                                if (targetMonitor != -1) {
                                    Config.general.wallpapers[targetMonitor].path = modelData.path;
                                } else {
                                    const monitor = {
                                        monitor: wallpaper.selectedScreen.name,
                                        path: modelData.path,
                                        isGif: modelData.path.toString().toLowerCase().endsWith(".gif")
                                    };
                                    Config.general.wallpapers.push(monitor);
                                }
                                Config.general.previewWallpaper = [];
                                Config.saveSettings();
                            }
                        }
                    }
                }
                MouseArea {
                    id: recentWallMa
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }

    Spacer {}

    ColumnLayout {
        Layout.fillWidth: true

        Text {
            Layout.fillWidth: true
            text: qsTr("Generate Color:")
            color: Colors.color.secondary
            font.pixelSize: 32
        }

        ListView {
            id: schemeList
            property int selectedScheme: 0
            readonly property list<string> schemes: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot", "scheme-vibrant"]
            readonly property bool isPortrait: wallpaper.selectedScreen.height > wallpaper.selectedScreen.width
            orientation: isPortrait ? ListView.Vertical : ListView.Horizontal
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            model: schemes
            spacing: 5
            delegate: Rectangle {
                width: 200
                height: 40
                radius: width / 2
                color: schemeList.selectedScheme === model.index ? Colors.color.primary : Colors.color.background

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
                Text {
                    text: modelData
                    anchors {
                        centerIn: parent
                    }
                    color: schemeList.selectedScheme === model.index ? Colors.color.on_primary : Colors.color.on_background
                }

                MouseArea {
                    id: schemeItemMouseArea
                    anchors.fill: parent
                    onClicked: {
                        schemeList.selectedScheme = model.index;
                    }
                }
            }
        }

        StyledButton {
            text: "Generate Colors"
            enabled: !cmdGenerateColor.running
            bgColor: cmdGenerateColor.running ? Colors.palette.primary60 : Colors.palette.primary10
            onClicked: {
                cmdGenerateColor.running = true;
            }
        }

        Process {
            id: cmdGenerateColor
            command: ["pcli", "generate-palette", "--type", schemeList.schemes[schemeList.selectedScheme], ...(Config.general.useCustomWallpaper ? Config.general.customWallpaper.map(item => item.path) : Config.general.wallpapers.map(item => item.path))]
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("Generated Color:")
            color: Colors.color.secondary
            font.pixelSize: 32
        }

        StyledSwitch {
            label: checked ? "Hide Color names" : "Show Color names"
            onClicked: colorGrid.showName = !colorGrid.showName
        }

        GridView {
            id: colorGrid
            property bool showName: false
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            cellHeight: width / 15
            cellWidth: width / 15
            model: Colors.colors
            delegate: Rectangle {
                width: colorGrid.cellWidth
                height: colorGrid.cellHeight
                color: Colors.color[modelData]
                Text {
                    opacity: colorGrid.showName ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                    anchors {
                        fill: parent
                        centerIn: parent
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: Math.min(parent.width, parent.height) / 5
                    wrapMode: Text.WrapAnywhere
                    text: modelData
                    color: {
                        let bg = Colors.color[modelData];
                        let brightness = bg.r * 0.299 + bg.g * 0.587 + bg.b * 0.114;
                        return brightness > 0.5 ? "black" : "white";
                    }
                }
            }
        }

        Label {
            text: qsTr("Generated Palette:")
            font.pixelSize: 32
            color: Colors.color.secondary
        }

        StyledSwitch {
            label: "Show Palette names"
            onClicked: paletteGrid.showName = !paletteGrid.showName
        }

        GridView {
            id: paletteGrid
            property bool showName: false
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            cellHeight: width / 18
            cellWidth: width / 18
            model: Colors.palettes
            delegate: Rectangle {
                width: paletteGrid.cellWidth
                height: paletteGrid.cellHeight
                color: Colors.palette[modelData]
                Text {
                    opacity: paletteGrid.showName ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                    anchors {
                        fill: parent
                        centerIn: parent
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: Math.min(parent.width, parent.height) / 5
                    wrapMode: Text.WrapAnywhere
                    text: modelData
                    color: {
                        let bg = Colors.palette[modelData];
                        let brightness = bg.r * 0.299 + bg.g * 0.587 + bg.b * 0.114;
                        return brightness > 0.5 ? "black" : "white";
                    }
                }
            }
        }
    }

    Spacer {}

    PageFooter {
        onSave: {
            if (Config.general.previewWallpaper && Config.general.previewWallpaper.length > 0) {
                Config.general.previewWallpaper.forEach(preview => {
                    const found = Config.general.wallpapers.find(item => item.monitor === preview.monitor);

                    if (found) {
                        found.path = preview.path;
                    }
                });
            }
            Config.general.previewWallpaper = [];
            Config.saveSettings();
        }
        onSaveAndExit: {
            if (Config.general.previewWallpaper && Config.general.previewWallpaper.length > 0) {
                Config.general.previewWallpaper.forEach(preview => {
                    const found = Config.general.wallpapers.find(item => item.monitor === preview.monitor);

                    if (found) {
                        found.path = preview.path;
                    }
                });
            }
            Config.general.previewWallpaper = [];

            Config.saveSettings();
            Qt.callLater(() => {
                Config.openSettingsPanel = false;
            });
        }
        onExit: {
            Config.general.previewWallpaper = [];
            Qt.callLater(() => {
                Config.openSettingsPanel = false;
            });
        }
    }
}
