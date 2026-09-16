pragma Singleton
pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Io
import QtQml.Models

import qs.core
import qs.components
import qs.types

Singleton {
    id: config

    property QtObject polkit: QtObject {
        property int width: 300
        property int height: 200
    }

    // Canvas selection for the polkit editor page.
    property var polkitSelectedItem: null

    property ObjectModel polkitElements: ObjectModel {
        Rectangle {
            id: titleRoot
            property string label: "Title"
            property int rowHeight: 32
            x: 12
            y: 52
            width: 200
            height: rowHeight
            visible: true
            clip: true
            color: "transparent"
            z: titleBg.drag.active ? 10 : 0

            MouseArea {
                id: titleBg
                anchors.fill: parent
                preventStealing: true
                drag.target: titleRoot
                drag.axis: Drag.XAndYAxis
                onClicked: Components.polkitSelectedItem = titleRoot
                onReleased: Utils.clampToParent(titleRoot)
            }

            Text {
                width: parent.width
                height: titleRoot.rowHeight
                verticalAlignment: Text.AlignVCenter
                text: "Title"
                wrapMode: Text.Wrap
            }
        }
        Rectangle {
            id: descRoot
            property string label: "Description"
            property int rowHeight: 32
            x: 12
            y: 12
            width: 200
            height: rowHeight
            visible: true
            clip: true
            color: "transparent"
            z: descBg.drag.active ? 10 : 0

            MouseArea {
                id: descBg
                anchors.fill: parent
                preventStealing: true
                drag.target: descRoot
                drag.axis: Drag.XAndYAxis
                onClicked: Components.polkitSelectedItem = descRoot
                onReleased: Utils.clampToParent(descRoot)
            }

            Text {
                width: parent.width
                height: descRoot.rowHeight
                verticalAlignment: Text.AlignVCenter
                text: "Description"
                wrapMode: Text.Wrap
            }
        }
        Rectangle {
            id: inputRoot
            property string label: "Input"
            property int rowHeight: 40
            x: 12
            y: 92
            width: 180
            height: rowHeight
            visible: true
            clip: true
            color: "transparent"
            z: inputBg.drag.active ? 10 : 0

            MouseArea {
                id: inputBg
                anchors.fill: parent
                preventStealing: true
                drag.target: inputRoot
                drag.axis: Drag.XAndYAxis
                onClicked: Components.polkitSelectedItem = inputRoot
                onReleased: Utils.clampToParent(inputRoot)
            }

            TextField {
                z: -1
                width: parent.width
                height: inputRoot.rowHeight - 4
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Rectangle {
            id: okRoot
            property string label: "OK"
            property int rowHeight: 40
            x: 12
            y: 140
            width: 130
            height: rowHeight
            visible: true
            clip: true
            color: "transparent"
            z: okBg.drag.active ? 10 : 0

            MouseArea {
                id: okBg
                anchors.fill: parent
                preventStealing: true
                drag.target: okRoot
                drag.axis: Drag.XAndYAxis
                onClicked: Components.polkitSelectedItem = okRoot
                onReleased: Utils.clampToParent(okRoot)
            }

            Button {
                z: -1
                width: parent.width
                height: okRoot.rowHeight - 4
                anchors.verticalCenter: parent.verticalCenter
                text: "OK"
            }
        }
        Rectangle {
            id: cancelRoot
            property string label: "Cancel"
            property int rowHeight: 40
            x: 150
            y: 140
            width: 130
            height: rowHeight
            visible: true
            clip: true
            color: "transparent"
            z: cancelBg.drag.active ? 10 : 0

            MouseArea {
                id: cancelBg
                anchors.fill: parent
                preventStealing: true
                drag.target: cancelRoot
                drag.axis: Drag.XAndYAxis
                onClicked: Components.polkitSelectedItem = cancelRoot
                onReleased: Utils.clampToParent(cancelRoot)
            }

            Button {
                z: -1
                width: parent.width
                height: cancelRoot.rowHeight - 4
                anchors.verticalCenter: parent.verticalCenter
                text: "Cancel"
            }
        }
    }

    // Region
    Component {
        id: region
        Region {}
    }

    // Image
    Component {
        id: staticImage
        Image {
            anchors.fill: parent
            mipmap: true
            smooth: true
        }
    }

    Component {
        id: animatedImage
        AnimatedImage {
            anchors.fill: parent
            playing: Compositor.animate
        }
    }

    function createImage(source, type, parent = null) {
        switch (type) {
        case "animated":
            return animatedImage.createObject(parent, {
                source: source
            });
        case "static":
            return staticImage.createObject(parent, {
                source: source
            });
        }
    }

    function createRegion() {
        const reg = region.createObject(null, {});
        return reg;
    }

    property alias config: adapter
    property alias icon: customIconFont.font

    FontLoader {
        id: customIconFont
        source: Qt.resolvedUrl("./icon.otf")
    }

    FileView {
        id: fileView
        path: Qt.resolvedUrl("data/components.json")
        watchChanges: true
        preload: true

        onFileChanged: {
            reload();
        }

        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                fileView.setText("{}");
                fileView.writeAdapter();
            }
        }

        onSaveFailed: error => console.log(error)

        adapter: JsonAdapter {
            id: adapter

            property BorderJson border: BorderJson {}
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}
            property real opacity: 0.5
        }
    }

    function update() {
        fileView.writeAdapter();
    }
}
