import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import QtCore

import Quickshell

import qs.config
import qs.components

Scope {
    Connections {
        target: Config
        function onOpenSettingsPanelChanged() {
            settingsLoader.active = !settingsLoader.active;
        }
    }

    function getIcon(name) {
        switch (name) {
        case "general":
            return "gear-icon";
        case "navbar":
            return `navbar-${Config.navbar.position}`;
        case "wallpaper":
            return "hexagon-image";
        default:
            return "?";
        }
    }

    LazyLoader {
        id: settingsLoader
        component: FloatingWindow {
            id: root
            title: "SettingsPanel"
            property int page: 0
            property ShellScreen selectedScreen: Quickshell.screens[0]
            readonly property bool isPortrait: screen.height > screen.width
            readonly property size panelSize: isPortrait ? Qt.size(screen.width * 0.8, screen.height * 0.6) : Qt.size(screen.width * 0.6, screen.height * 0.8)
            minimumSize: panelSize
            maximumSize: panelSize
            color: Qt.rgba(0, 0, 0, 0.8)

            GridLayout {
                columns: 2
                anchors.fill: parent

                // sidebar
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 40

                    ListView {
                        anchors.fill: parent
                        spacing: 1
                        model: ["general", "navbar"]
                        delegate: Item {
                            width: 40
                            height: 40
                            Rectangle {
                                anchors.fill: parent
                                color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
                                radius: ma.containsMouse ? 8 : 0

                                FontIcon {
                                    anchors.centerIn: parent
                                    text: getIcon(modelData)
                                    font.pixelSize: parent.height
                                    color: ma.containsMouse || root.page === index ? "white" : Qt.rgba(1, 1, 1, 0.6)

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 350
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }

                                Behavior on radius {
                                    NumberAnimation {
                                        duration: 350
                                        easing.type: Easing.InOutQuad
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 350
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }

                            MouseArea {
                                id: ma
                                hoverEnabled: true
                                anchors.fill: parent
                                onClicked: {
                                    page = index;
                                }
                            }
                        }
                    }
                }

                // content
                StackLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    currentIndex: root.page
                    Layout.rightMargin: 20

                    PageWrapper {
                        PageHeader {
                            title: "General"
                        }

                        FileDialog {
                            id: fileDialog
                            property Item targetItem
                            currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
                            onAccepted: {
                                if (targetItem) {
                                    targetItem.source = selectedFile;
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            Label {
                                text: qsTr("Panels:")
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: monitorRow.height
                                RowLayout {
                                    id: monitorRow
                                    anchors.centerIn: parent
                                    Repeater {
                                        model: Quickshell.screens
                                        delegate: Rectangle {
                                            required property ShellScreen modelData
                                            readonly property string filePath: Config.general.wallpapers.find(wallpaperItem => wallpaperItem.monitor === modelData.name)?.path || ""
                                            color: "transparent"
                                            border.color: selectedScreen.name === modelData.name ? "green" : "gray"
                                            Layout.preferredHeight: modelData.height / 6
                                            Layout.preferredWidth: modelData.width / 6

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
                                                color: "white"
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
                                                source: filePath
                                                onSourceChanged: {
                                                    let monitor = Config.general.wallpapers.find(w => w.monitor === modelData.name);

                                                    if (monitor) {
                                                        monitor.path = source;
                                                        monitor.isGif = source.toString().toLowerCase().endsWith(".gif");
                                                    } else {
                                                        Config.general.wallpapers.push({
                                                            monitor: modelData.name,
                                                            path: source,
                                                            isGif: source.toString().toLowerCase().endsWith(".gif")
                                                        });
                                                    }
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
                                                    fileDialog.targetItem = monitorBg;
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            StyledButton {
                                text: "Change Wallpaper" + selectedScreen.name
                                onClicked: {
                                    fileDialog.open();
                                }
                            }

                            ListView {
                                id: recentWallpapersList
                                readonly property bool isPortrait: selectedScreen.height > selectedScreen.width
                                orientation: ListView.Horizontal
                                layoutDirection: Qt.LeftToRight
                                Layout.fillWidth: true
                                Layout.minimumHeight: isPortrait ? 150 : 100
                                model: Config.general.recentWallpapers.filter(item => item.monitor === selectedScreen.name).sort((a, b) => b.timestamp - a.timestamp)
                                delegate: Item {
                                    width: recentWallpapersList.isPortrait ? 80 : 150
                                    height: recentWallpapersList.isPortrait ? 150 : 80
                                    Image {
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        source: modelData.path
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.AllButtons
                                        onClicked: mouse => {
                                            if (mouse.button === Qt.LeftButton) {
                                                // set the wallpaper
                                                // selectedScreen = Quickshell.screens.find(screen => screen.name === modelData.monitor);
                                            } else if (mouse.button === Qt.RightButton) {
                                                const index = Config.general.recentWallpapers.findIndex(wallpaperItem => wallpaperItem.monitor === modelData.monitor && wallpaperItem.path === modelData.path);
                                                if (index !== -1) {
                                                    Config.general.recentWallpapers.splice(index, 1);
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Switch {
                            //     text: qsTr("Show Preset Creator Grid")
                            //     onClicked: presetGrid.visible = !presetGrid.visible
                            // }
                        }

                        GridLayout {
                            id: presetGrid
                            visible: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            columns: 3

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Column {
                                    anchors {
                                        bottom: parent.bottom
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SpinBox {
                                        from: 0
                                        onValueChanged: {
                                            acceptButtonBg.border.top = value;
                                            testPanel.border.top = value;
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Column {
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SpinBox {
                                        from: 0
                                        onValueChanged: {
                                            acceptButtonBg.border.left = value;
                                            testPanel.border.left = value;
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                border.color: "gray"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Button {
                                    id: testAcceptButton
                                    text: "change panel"
                                    anchors {
                                        horizontalCenter: parent.horizontalCenter
                                        verticalCenter: parent.verticalCenter
                                    }
                                    width: 150
                                    height: 50
                                    background: BorderImage {
                                        id: acceptButtonBg
                                        anchors {
                                            fill: parent
                                            margins: 1
                                        }
                                        border {
                                            left: 1
                                            top: 1
                                            right: 1
                                            bottom: 1
                                        }
                                        horizontalTileMode: BorderImage.Stretch
                                        verticalTileMode: BorderImage.Stretch
                                    }
                                    onClicked: {
                                        fileDialog.targetItem = acceptButtonBg;
                                        fileDialog.open();
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Column {
                                    anchors {
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                    }

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SpinBox {
                                        from: 0
                                        onValueChanged: {
                                            acceptButtonBg.border.right = value;
                                            testPanel.border.right = value;
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                Column {
                                    anchors {
                                        top: parent.top
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SpinBox {
                                        from: 0
                                        onValueChanged: {
                                            acceptButtonBg.border.bottom = value;
                                            testPanel.border.bottom = value;
                                        }
                                    }
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Column {
                                    Rectangle {
                                        width: 150
                                        height: 20
                                        color: Qt.rgba(1, 1, 1, 0.1)
                                        clip: true
                                        TextInput {
                                            id: inputField
                                            anchors.fill: parent
                                            color: "white"
                                            font.pixelSize: parent.height
                                        }
                                    }
                                    Button {
                                        text: "save"
                                        enabled: inputField.text.length > 0
                                        onClicked: {
                                            const preset = {};
                                            preset.name = inputField.text;
                                            preset.border = {
                                                left: acceptButtonBg.border.left,
                                                top: acceptButtonBg.border.top,
                                                right: acceptButtonBg.border.right,
                                                bottom: acceptButtonBg.border.bottom
                                            };
                                            preset.source = acceptButtonBg.source;
                                            Config.general.presets.push(preset);
                                            Config.saveSettings();
                                        }
                                    }
                                }
                            }
                        }

                        PageFooter {}
                    }

                    PageWrapper {
                        PageHeader {
                            title: "Navbar"
                        }

                        PageFooter {}
                    }
                    PageWrapper {
                        PageHeader {
                            title: "Wallpaper"
                        }
                        PageFooter {}
                    }
                }
            }
        }
    }
    component PageWrapper: ScrollView {
        default property alias contentLayout: contentLayout.data
        Layout.fillHeight: true
        Layout.fillWidth: true
        contentWidth: width
        clip: true
        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
        }
    }

    component PageHeader: Item {
        property alias title: titleText.text
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Text {
            id: titleText
            anchors.centerIn: parent
            color: "white"
        }
    }

    component Spacer: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 2
    }

    component PageFooter: Item {
        property alias footerLayout: footerLayout.data
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.bottomMargin: 40
        RowLayout {
            id: footerLayout
            width: parent.width

            Text {
                Layout.fillWidth: true
                text: "Save Settings"
                color: "white"
            }

            Row {
                spacing: 10

                Button {
                    id: cancelButton
                    text: "Cancel"

                    leftPadding: 10
                    rightPadding: 10

                    onClicked: {
                        Config.openSettingsPanel = false;
                    }
                }

                Button {
                    id: saveButton
                    text: "Save"
                    leftPadding: 10
                    rightPadding: 10

                    onClicked: {
                        Config.saveSettings();
                    }
                }

                Button {
                    text: "Save and Exit"
                    leftPadding: 10
                    rightPadding: 10
                    onClicked: {
                        Config.saveSettings();
                        Qt.callLater(() => {
                            Config.openSettingsPanel = false;
                        });
                    }
                }
            }
        }
    }
}
