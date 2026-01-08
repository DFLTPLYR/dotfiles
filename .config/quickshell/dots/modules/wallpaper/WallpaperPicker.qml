import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import Qt.labs.folderlistmodel

import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import qs.config
import qs.components

Scope {
    id: root

    LazyLoader {
        id: panelLoader
        property bool shouldBeVisible: false
        component: PanelWrapper {
            id: sidebarRoot
            color: "transparent"
            shouldBeVisible: panelLoader.shouldBeVisible

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.5)
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            anchors {
                top: true
                bottom: true
                right: true
                left: true
            }

            Item {
                anchors.centerIn: parent
                width: sidebarRoot.isPortrait ? (parent.width / 1.2) * sidebarRoot.animProgress : (parent.width / 1.5) * sidebarRoot.animProgress
                height: (parent.height * 0.5) * sidebarRoot.animProgress

                RowLayout {
                    id: layout
                    anchors.fill: parent
                    spacing: 6
                    opacity: 1 * sidebarRoot.animProgress

                    StyledRect {
                        color: Qt.rgba(0, 0, 0, 0.5)
                        Layout.fillWidth: true
                        Layout.maximumWidth: parent.width / 10
                        Layout.fillHeight: true
                        clip: true

                        GridView {
                            id: gridDirList
                            height: parent.height
                            width: parent.width
                            readonly property int itemHeight: 50
                            cellHeight: itemHeight
                            model: ScriptModel {
                                values: {
                                    return Config.wallpaperDirs;
                                }
                            }
                            delegate: Rectangle {
                                required property var modelData
                                implicitWidth: parent ? parent.width : 0
                                height: gridDirList.itemHeight
                                color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.2)

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                        easing.type: Easing.InOutQuad
                                    }
                                }

                                Text {
                                    id: label
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.name
                                    color: "white"
                                    width: parent.width
                                    elide: Text.ElideRight
                                    wrapMode: Text.Wrap
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    clip: true
                                }

                                MouseArea {
                                    id: ma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.AllButtons
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.LeftButton) {
                                            folderModel.folder = "file://" + modelData.path;
                                        } else if (mouse.button === Qt.RightButton) {
                                            if (modelData.removable) {
                                                var index = Config.wallpaperDirs.findIndex(d => d.path === modelData.path);
                                                if (index !== -1)
                                                    Config.wallpaperDirs.splice(index, 1);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        color: Qt.rgba(0, 0, 0, 0.5)
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        Flickable {
                            id: flickable
                            anchors.fill: parent
                            contentWidth: width
                            contentHeight: flexLayout.height
                            clip: true
                            ScrollBar.vertical: ScrollBar {
                                width: 20
                                policy: ScrollBar.AlwaysOn
                            }

                            FlexboxLayout {
                                id: flexLayout
                                wrap: FlexboxLayout.Wrap
                                width: flickable.width
                                implicitHeight: 10
                                direction: FlexboxLayout.Row
                                justifyContent: FlexboxLayout.JustifyStart
                                Repeater {
                                    id: contentRepeater
                                    model: folderModel
                                    delegate: Loader {
                                        active: true
                                        sourceComponent: folderModel.isFolder(model.index) ? folderDescriptionComponent : imagePreviewComponent
                                        onLoaded: {
                                            if (item) {
                                                item.model = model;
                                                if (folderModel.isFolder(model.index)) {
                                                    item.text = model.fileName ? model.fileName : "";
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            onHidden: {
                panelLoader.active = false;
            }

            // set up
            Component.onCompleted: {
                if (this.WlrLayershell) {
                    this.WlrLayershell.layer = WlrLayer.Overlay;
                    this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
                    this.exclusionMode = ExclusionMode.Ignore;
                }
            }
        }
    }

    Component {
        id: imagePreviewComponent
        Item {
            id: imageFrame
            property var model
            width: 150
            height: 150
            Image {
                id: imagePreview
                source: (model && model.filePath) ? model.filePath : ""
                anchors.fill: parent
                cache: true
                asynchronous: true
                smooth: true
                Text {
                    visible: imagePreview.status === Image.Loading
                    anchors.centerIn: parent
                    text: "Loading..."
                    color: "white"
                }
            }
        }
    }
    Component {
        id: folderDescriptionComponent
        Rectangle {
            property var model
            property alias text: label.text
            color: Qt.rgba(0, 0, 0, 0.5)
            width: 150
            height: 50
            Text {
                id: label
                anchors.centerIn: parent
                text: ""
                color: "white"
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width - 4
            }
            MouseArea {
                anchors.fill: parent
                onClicked: mouse => {
                    if (Config.wallpaperDirs.find(m => m.path === model.filePath))
                        return;
                    Config.wallpaperDirs.push({
                        name: model.fileName,
                        path: model.filePath,
                        removable: true
                    });
                    Qt.callLater(() => {
                        folderModel.folder = "file://" + model.filePath;
                    });
                }
            }
        }
    }

    FolderListModel {
        id: folderModel
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.bmp", "*.gif"]
    }
    Connections {
        target: Config
        function onOpenWallpaperPickerChanged() {
            if (!panelLoader.active) {
                panelLoader.active = true;
                panelLoader.shouldBeVisible = !panelLoader.shouldBeVisible;
            } else {
                panelLoader.shouldBeVisible = !panelLoader.shouldBeVisible;
            }
        }
    }
}
