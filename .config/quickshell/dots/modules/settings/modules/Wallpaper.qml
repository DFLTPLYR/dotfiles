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
    property bool customWallpaper: false
    property list<var> coordinates: []
    signal updateLocation
    function getIntersection(rect, image) {
        var x = Math.max(rect.x, image.x);
        var y = Math.max(rect.y, image.y);
        var right = Math.min(rect.x + rect.width, image.x + image.width);
        var bottom = Math.min(rect.y + rect.height, image.y + image.height);
        if (right < x || bottom < y) {
            return Qt.rect(0, 0, 0, 0);
        }
        return Qt.rect(x, y, right - x, bottom - y);
    }

    PageHeader {
        title: "Wallpaper"
    }
    Spacer {}

    FileDialog {
        id: fileDialog
        property Item targetItem
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        onAccepted: {
            if (selectedScreen && !wallpaper.customWallpaper) {
                const targetMonitor = Config.general.previewWallpaper.findIndex(w => w && w.monitor === selectedScreen.name);
                if (targetMonitor != -1) {
                    Config.general.previewWallpaper[targetMonitor].path = selectedFile.path;
                } else {
                    const monitor = {
                        monitor: selectedScreen.name,
                        path: selectedFile,
                        isGif: selectedFile.toString().toLowerCase().endsWith(".gif")
                    };
                    Config.general.previewWallpaper.push(monitor);
                }
            } else {
                customWallpaperImage.source = selectedFile;
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true

        Label {
            text: qsTr("Panels:")
            font.pixelSize: 32
            color: Colors.color.on_surface
        }
        StyledButton {
            text: "Custom Wallpaper"
            onClicked: {
                wallpaper.customWallpaper = !wallpaper.customWallpaper;
            }
        }

        Item {
            id: panelContent
            visible: wallpaper.customWallpaper
            Layout.fillWidth: true
            Layout.preferredHeight: screen.height / 2
            property double zoom: 1.0
            clip: true

            Row {
                z: 2
                anchors.top: parent.top
                anchors.right: parent.right

                Rectangle {
                    FontIcon {
                        anchors.centerIn: parent
                        text: "check"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }
                    width: 40
                    height: 40
                    color: Scripts.setOpacity(Colors.color.background, 0.5)
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            wallpaper.updateLocation();
                            if (wallpaper.coordinates) {
                                let preset = [];
                                wallpaper.coordinates.forEach(item => {
                                    preset.push(item);
                                    console.log(JSON.stringify(item));
                                });
                                const path = {
                                    x: customWallpaperImage.x,
                                    y: customWallpaperImage.y,
                                    width: customWallpaperImage.width,
                                    height: customWallpaperImage.height
                                };
                            }
                        }
                    }
                }

                Rectangle {
                    FontIcon {
                        anchors.centerIn: parent
                        text: "circle-minus"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }
                    width: 40
                    height: 40
                    color: Scripts.setOpacity(Colors.color.background, 0.5)
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            panelContent.zoom = panelContent.zoom - 0.1;
                        }
                    }
                }

                Rectangle {
                    FontIcon {
                        anchors.centerIn: parent
                        text: "circle-plus"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }
                    width: 40
                    height: 40
                    color: Scripts.setOpacity(Colors.color.background, 0.5)
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            panelContent.zoom = panelContent.zoom + 0.1;
                            console.log(panelContent.zoom);
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: parent.height

                Repeater {
                    model: Quickshell.screens
                    delegate: Rectangle {
                        z: 2
                        scale: panelContent.zoom
                        required property ShellScreen modelData
                        width: modelData.width / 4
                        height: modelData.height / 4
                        color: Scripts.setOpacity(Colors.color.background, 0.5)
                        border.color: Colors.color.secondary
                        border.width: 1 * panelContent.zoom
                        Drag.active: screenDragArea.drag.active
                        Drag.hotSpot.x: 10
                        Drag.hotSpot.y: 10

                        function updateWallpaper() {
                            if (customWallpaperImage.source === "")
                                return;

                            const relativeX = customWallpaperImage.x - x;
                            const relativeY = customWallpaperImage.y - y;
                            const target = wallpaper.coordinates.findIndex(w => w && w.monitor === modelData.name);
                            if (target !== -1) {
                                wallpaper.coordinates[target].x = relativeX;
                                wallpaper.coordinates[target].y = relativeY;
                            } else {
                                wallpaper.coordinates.push({
                                    name: modelData.name,
                                    x: relativeX,
                                    y: relativeY
                                });
                            }
                        }

                        Connections {
                            target: wallpaper
                            function onUpdateLocation() {
                                updateWallpaper();
                            }
                        }
                        MouseArea {
                            id: screenDragArea
                            anchors.fill: parent
                            drag.target: parent
                        }
                    }
                }
                Image {
                    id: customWallpaperImage
                    z: 1
                    visible: source
                    fillMode: Image.PreserveAspectFit
                    width: sourceSize.width / 4
                    height: sourceSize.height / 4
                    Drag.active: wallpaperDragArea.drag.active
                    Drag.hotSpot.x: 10
                    Drag.hotSpot.y: 10

                    MouseArea {
                        id: wallpaperDragArea
                        anchors.fill: parent

                        drag.target: parent
                    }
                }
            }
        }

        Item {
            visible: !wallpaper.customWallpaper
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
                        border.color: selectedScreen.name === modelData.name ? Colors.color.inverse_primary : Colors.color.primary

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
                            anchors.margins: selectedScreen.name === modelData.name ? 2 : 1

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
                                } else {
                                    Config.general.recentWallpapers.push({
                                        monitor: modelData.name,
                                        timestamp: Date.now(),
                                        path: source
                                    });
                                }
                            }
                        }

                        MouseArea {
                            id: monitorArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                selectedScreen = modelData;
                            }
                        }
                    }
                }
            }
        }

        StyledButton {
            text: "Change Wallpaper " + selectedScreen.name
            onClicked: {
                fileDialog.open();
            }
        }

        ListView {
            id: recentWallpapersList
            readonly property string currentWallpaper: Config.general.wallpapers.find(wallpaper => wallpaper?.monitor === selectedScreen.name)?.path
            readonly property bool isPortrait: selectedScreen.height > selectedScreen.width
            readonly property int itemHeight: selectedScreen.height / 4
            readonly property int itemWidth: selectedScreen.width / 4
            Layout.fillWidth: true
            Layout.preferredHeight: itemHeight
            orientation: ListView.Horizontal
            layoutDirection: Qt.LeftToRight
            spacing: 5
            model: Config.general.recentWallpapers.filter(item => item.monitor === selectedScreen.name).sort((a, b) => b.timestamp - a.timestamp)
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
                    fillMode: Image.PreserveAspectCrop
                    source: modelData.path
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 350
                        easing.type: Easing.InOutQuad
                    }
                }

                Row {
                    z: 1
                    visible: !recItem.isSetCurrent
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
                            enabled: !recItem.isSetCurrent
                            anchors.fill: parent
                            onClicked: {
                                if (wallpaper.customWallpaper) {
                                    return customWallpaperImage.source = modelData.path;
                                }
                                const targetMonitor = Config.general.previewWallpaper.findIndex(w => w && w.monitor === selectedScreen.name);
                                if (targetMonitor != -1) {
                                    Config.general.previewWallpaper[targetMonitor].path = modelData.path;
                                } else {
                                    const monitor = {
                                        monitor: selectedScreen.name,
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
                            enabled: !recItem.isSetCurrent
                            anchors.fill: parent
                            onClicked: {
                                if (wallpaper.customWallpaper) {
                                    return customWallpaperImage.source = modelData.path;
                                }
                                const targetMonitor = Config.general.wallpapers.findIndex(w => w && w.monitor === selectedScreen.name);
                                if (targetMonitor != -1) {
                                    Config.general.wallpapers[targetMonitor].path = modelData.path;
                                } else {
                                    const monitor = {
                                        monitor: selectedScreen.name,
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
            orientation: ListView.Horizontal
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
            colorBackground: cmdGenerateColor.running ? Colors.palette.primary60 : Colors.palette.primary10
            onClicked: {
                cmdGenerateColor.running = true;
            }
        }

        Process {
            id: cmdGenerateColor
            running: false
            command: ["pcli", "generate-palette", "--type", schemeList.schemes[schemeList.selectedScheme], ...Config.general.wallpapers.map(item => item.path)]
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
