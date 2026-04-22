import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt.labs.folderlistmodel
import QtCore

import qs.core

FloatingWindow {
    id: fileExplorer
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
        Button {
            text: "Up"
            enabled: fileExplorer.folder.folder !== "file:///"
            onClicked: {
                fileExplorer.folder.folder = fileExplorer.folder.parentFolder;
            }
        }
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

    component Sidebar: ListView {
        Layout.preferredWidth: 100
        Layout.fillHeight: true
        clip: true
        model: fileExplorer.folder
        delegate: ItemDelegate {
            readonly property bool isDir: folderModel.isFolder(index)
            width: ListView.view.width
            text: model.fileName
            onClicked: {
                if (isDir) {
                    folderModel.folder = model.fileUrl;
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
            readonly property bool isDir: folderModel.isFolder(index)
            width: ListView.view.width
            text: model.fileName
            onClicked: {
                if (isDir) {
                    folderModel.folder = model.fileUrl;
                }
            }
        }
    }
}
