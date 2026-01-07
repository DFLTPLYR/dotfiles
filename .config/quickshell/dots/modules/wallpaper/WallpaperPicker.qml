import QtQuick
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

                    FolderListModel {
                        id: folderModel
                        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.bmp", "*.gif"]
                    }

                    StyledRect {
                        color: Qt.rgba(0, 0, 0, 0.5)
                        Layout.fillWidth: true
                        Layout.maximumWidth: parent.width / 10
                        Layout.fillHeight: true
                        clip: true

                        GridView {
                            anchors.fill: parent
                            model: ScriptModel {
                                values: {
                                    return Config.wallpaperDirs;
                                }
                            }
                            delegate: Rectangle {
                                required property var modelData
                                implicitWidth: parent ? parent.width : 0
                                height: 50
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

                        GridView {
                            id: fileGrid
                            anchors.fill: parent
                            property var cellSize: parent.width / 4
                            model: folderModel
                            cellWidth: cellSize
                            cellHeight: cellSize

                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool isFolder: folderModel.isFolder(modelData.index)
                                width: fileGrid.cellSize
                                height: width
                                color: isFolder ? Qt.rgba(Math.random(), Math.random(), Math.random(), 0.3) : "transparent"

                                Text {
                                    visible: isFolder
                                    anchors.centerIn: parent
                                    text: modelData.fileName
                                }

                                Image {
                                    anchors.fill: parent
                                    visible: !isFolder
                                    source: modelData.filePath
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: mouse => {
                                        if (isFolder) {
                                            if (Config.wallpaperDirs.find(m => m.path === modelData.filePath))
                                                return;
                                            Config.wallpaperDirs.push({
                                                name: modelData.fileName,
                                                path: modelData.filePath,
                                                removable: true
                                            });
                                            folderModel.folder = "file://" + modelData.path;
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
