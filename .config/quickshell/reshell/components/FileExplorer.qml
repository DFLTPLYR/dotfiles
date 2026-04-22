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
        nameFilters: ["*"]
    }

    title: "Reshell"
    color: Colors.setOpacity(Colors.color.background, 0.5)

    minimumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)
    maximumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)

    ColumnLayout {
        anchors.fill: parent
        // Header
        Header {}
        // Content
        Content {}
    }

    component Header: Row {
        Button {
            text: "Up"
            enabled: fileExplorer.folder.folder !== "file:///"
            onClicked: {
                fileExplorer.folder.folder = fileExplorer.folder.parentFolder;
            }
        }
        Text {
            text: folderModel.folder
            elide: Text.ElideMiddle
        }
    }

    component Content: RowLayout {
        // Sidebar
        Sidebar {}

        // Files
        Rectangle {

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
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
}
