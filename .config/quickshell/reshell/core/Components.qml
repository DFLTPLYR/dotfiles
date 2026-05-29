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
            onParentChanged: {
                anchors.fill = parent;
            }
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

            function updateColors() {
                button.content.down = Colors.color.primary;
                button.content.up = Colors.color.primary;
                button.background.down = Qt.darker(Colors.color.background, 1.2);
                button.background.up = Qt.darker(Colors.color.primary, 1);

                spinbox.color = Colors.color.background;
                spinbox.text = Colors.color.on_background;
                spinbox.hover.color = Colors.color.primary;
                spinbox.unhover.color = Colors.setOpacity(Colors.color.primary, 0.7);

                label.text = Colors.color.primary;
                label.background.color = Colors.color.background;

                fileView.writeAdapter();
            }

            property BorderJson border: BorderJson {}
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}

            // set it to 0.0 hehe haha moment
            property real opacity: 0.5
            property Notification notification: Notification {}
            property ButtonJson button: ButtonJson {}
            property SpinBoxJson spinbox: SpinBoxJson {}
            property Label label: Label {}
        }
    }

    component Notification: JsonObject {
        property int duration: 5000
        property int width: 300
        property int height: 100
        property JsonObject style: JsonObject {
            property color color: Colors.setOpacity(Colors.color.background, 0.5)
            property DirectionJson padding: DirectionJson {}
            property DirectionJson inset: DirectionJson {}
            property JsonObject background: JsonObject {
                property CornerJson rounding: CornerJson {}
                property DirectionJson margins: DirectionJson {}
            }
        }
    }

    component ButtonJson: JsonObject {
        property JsonObject content: JsonObject {
            property color color: Colors.color.primary
        }
        property RectangleJson background: RectangleJson {
            color: Colors.color.background
        }
    }

    component SpinBoxJson: JsonObject {
        property color color: Colors.color.background
        property color text: Colors.color.on_background
        property BorderJson border: BorderJson {}
        property DirectionJson margin: DirectionJson {}
        property CornerJson rounding: CornerJson {}
        property JsonObject hover: JsonObject {
            property color color: Colors.setOpacity(Colors.color.primary, 1)
            property BorderJson border: BorderJson {}
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}
        }
        property JsonObject unhover: JsonObject {
            property real opacity: 0.5
            property color color: Colors.setOpacity(Colors.color.primary, 0.7)
            property BorderJson border: BorderJson {}
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}
        }
    }

    component SwitchJson: JsonObject {
        property JsonObject content: JsonObject {
            property color color: Colors.color.primary
            property int radius: 13
        }
        property JsonObject indicator: JsonObject {
            property color down: Colors.color.surface_dim
            property color up: Colors.color.surface_bright
            property int radius: 13
            property int width: 48
            property int height: 26
            property JsonObject inner: JsonObject {
                property color down: Colors.color.primary
                property color up: Colors.color.secondary
                property int radius: 13
                property int width: 26
                property int height: 26
            }
        }
    }

    component Label: JsonObject {
        property color text: Colors.color.primary
        property RectangleJson background: RectangleJson {}
    }
}
