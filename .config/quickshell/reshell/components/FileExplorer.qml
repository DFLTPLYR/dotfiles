import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt.labs.folderlistmodel
import QtCore

import qs.core

FloatingWindow {
    id: fileExplorer

    signal selected(var file)

    property FolderListModel folder: FolderListModel {
        id: folderModel
        folder: "file://" + StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        showDirsFirst: true
        showFiles: false
        nameFilters: ["*"]
    }

    property FolderListModel contents: FolderListModel {
        folder: fileExplorer.folder.folder
        showFiles: true
        showDirs: false
    }

    title: "Reshell"
    color: Colors.setOpacity(Colors.color.background, 0.5)

    minimumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)
    maximumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)

    ColumnLayout {
        anchors.fill: parent
        // Header
        Header {
            Layout.fillWidth: true
        }
        // Content
        Content {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    component Header: RowLayout {
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Colors.color.primary
            text: folderModel.folder
            elide: Text.ElideMiddle
        }
    }

    component Content: RowLayout {
        // Sidebar
        Sidebar {}

        // Files
        Files {}
    }

    component Sidebar: ColumnLayout {
        Layout.preferredWidth: 100
        Layout.fillHeight: true

        Button {
            Layout.preferredWidth: 100
            text: "Up"
            enabled: fileExplorer.folder.folder !== "file:///"
            onClicked: {
                fileExplorer.folder.folder = fileExplorer.folder.parentFolder;
            }
        }

        ListView {
            Layout.preferredWidth: 100
            Layout.fillHeight: true
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            model: fileExplorer.folder

            delegate: ItemDelegate {
                id: dir
                readonly property bool isDir: folderModel.isFolder(index)

                width: ListView.view.width
                hoverEnabled: true

                background: Rectangle {
                    anchors.fill: parent
                    color: dir.hovered ? Colors.setOpacity(Colors.color.background, 0.5) : Colors.setOpacity(Colors.color.background, 0.9)

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                contentItem: Text {
                    text: model.fileName

                    verticalAlignment: Text.AlignVCenter
                    color: Colors.color.primary
                    elide: Text.ElideMiddle
                }

                onClicked: {
                    if (isDir) {
                        folderModel.folder = model.fileUrl;
                    }
                }
            }
        }
    }
    component Files: ListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        clip: true
        model: fileExplorer.contents
        delegate: ItemDelegate {
            id: file

            width: ListView.view.width
            hoverEnabled: true

            // Decor
            background: Rectangle {
                anchors.fill: parent
                color: file.hovered ? Colors.setOpacity(Colors.color.background, 0.5) : Colors.setOpacity(Colors.color.background, 0.9)

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            // Text
            contentItem: Text {
                text: model.fileName

                verticalAlignment: Text.AlignVCenter
                color: Colors.color.primary
                elide: Text.ElideMiddle
            }
            onClicked: {}
        }
    }
}
