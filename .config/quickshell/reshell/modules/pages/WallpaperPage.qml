import QtQuick
import QtQuick.Layouts

import qs.core

import QtCore
import QtQuick.Dialogs

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    MouseArea {
        anchors.fill: parent
        onClicked: fileDialog.open()
    }

    FileDialog {
        id: fileDialog
        title: "FilePicker"
        fileMode: FileDialog.OpenFile
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp)"]

        onAccepted: {
            Wallpaper.config.source.push({
                monitor: screen.name,
                timestamp: Date.now(),
                path: selectedFile
            });
            Wallpaper.save();
        }
    }
}
