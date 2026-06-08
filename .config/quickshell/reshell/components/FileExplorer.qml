import Qt.labs.folderlistmodel
import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.core

FloatingWindow {
    id: fileExplorer

    property FolderListModel folder
    property FolderListModel contents

    signal selected(var file)

    title: "Reshell"
    color: Colors.setOpacity(Colors.theme.surface, 0.5)
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

    folder: FolderListModel {
        id: folderModel

        folder: "file://" + StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        showDirsFirst: true
        showFiles: false
        nameFilters: ["*"]
    }

    contents: FolderListModel {
        folder: fileExplorer.folder.folder
        showFiles: true
        showDirs: false
    }

    component Header: RowLayout {
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Colors.theme.primary
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
                onClicked: {
                    if (isDir)
                        folderModel.folder = model.fileUrl;
                }

                background: Rectangle {
                    anchors.fill: parent
                    color: dir.hovered ? Colors.setOpacity(Colors.theme.surface, 0.5) : Colors.setOpacity(Colors.theme.surface, 0.9)

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
                    color: Colors.theme.primary
                    elide: Text.ElideMiddle
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
            onClicked: {}

            // Decor
            background: Rectangle {
                anchors.fill: parent
                color: file.hovered ? Colors.setOpacity(Colors.theme.surface, 0.5) : Colors.setOpacity(Colors.theme.surface, 0.9)

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
                color: Colors.theme.primary
                elide: Text.ElideMiddle
            }
        }
    }
}
