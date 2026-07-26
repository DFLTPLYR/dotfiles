pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.types

Singleton {
    id: config
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

            // set it to 0.0 hehe haha moment
            property real opacity: 0.5
        }
    }

    function update() {
        fileView.writeAdapter();
    }
}
