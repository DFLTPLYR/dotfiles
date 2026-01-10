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
            readonly property bool isPortrait: screen.height > screen.width
            readonly property size panelSize: isPortrait ? Qt.size(screen.width * 0.6, screen.height * 0.4) : Qt.size(screen.width * 0.4, screen.height * 0.6)
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
                        model: ["general", "navbar", "wallpaper"]
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
                            id: testDialog
                            property Item targetItem
                            currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
                            onAccepted: {
                                if (targetItem) {
                                    targetItem.source = selectedFile;
                                    testPanel.source = selectedFile;
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            Column {
                                Layout.fillWidth: true

                                Label {
                                    text: qsTr("Panel:")
                                }

                                BorderImage {
                                    id: testPanel
                                    width: parent.width
                                    height: 300

                                    Rectangle {
                                        anchors {
                                            fill: parent
                                            leftMargin: testPanel.border.left
                                            rightMargin: testPanel.border.right
                                            bottomMargin: testPanel.border.bottom
                                            topMargin: testPanel.border.top
                                        }
                                        color: Qt.rgba(1, 1, 1, 0.1)
                                    }
                                }
                            }

                            Column {
                                Layout.fillWidth: true

                                Label {
                                    text: qsTr("Buttons:")
                                }
                                Button {
                                    width: 150
                                    height: 50
                                    text: "Basic Button"
                                }
                            }
                            Switch {
                                text: qsTr("Show Preset Creator Grid")
                                onClicked: presetGrid.visible = !presetGrid.visible
                            }
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
                                        testDialog.targetItem = acceptButtonBg;
                                        testDialog.open();
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
                    width: 80
                    height: 50

                    background: StyledRect {
                        usePanel: true
                        panelSource: Qt.resolvedUrl("file:///home/dfltplyr/Downloads/kenney_fantasy-ui-borders/PNG/Default/Border/panel-border-003.png")
                    }

                    onClicked: {
                        Config.openSettingsPanel = false;
                    }
                }

                Button {
                    id: saveButton
                    text: "Save"
                    width: 80
                    height: 50

                    background: StyledRect {
                        usePanel: true
                        panelSource: Qt.resolvedUrl("file:///home/dfltplyr/Downloads/kenney_fantasy-ui-borders/PNG/Default/Border/panel-border-003.png")
                    }

                    onClicked: {
                        Config.saveSettings();
                    }
                }

                Button {
                    text: "Save and Exit"
                    width: 150
                    height: 50

                    background: StyledRect {
                        usePanel: true
                        panelSource: Qt.resolvedUrl("file:///home/dfltplyr/Downloads/kenney_fantasy-ui-borders/PNG/Default/Border/panel-border-003.png")
                    }

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
