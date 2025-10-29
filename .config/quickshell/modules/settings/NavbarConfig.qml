import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.components

Item {
    id: root

    property QtObject mainRect: QtObject {
        property int rounding: 0
        property int padding: 0
    }

    property QtObject backingRect: QtObject {
        property string color: "background"
        property int x: 0
        property int y: 0
        property real opacity: 1
    }

    property QtObject intersection: QtObject {
        property real opacity: 1
        property string color: "background"
        property QtObject border: QtObject {
            property string color: "background"
            property int width: 2
        }
    }

    component PreviewNavbar: StyledRectangle {
        anchors.fill: parent
        transparency: 1
        rounding: mainRect.rounding
        padding: mainRect.anchors.margins

        backingVisible: backgroundRect.visible
        backingRectX: backgroundRect.x
        backingRectY: backgroundRect.y
        backingRectOpacity: backgroundRect.opacity

        intersectionVisible: intersectionRect.visible
        intersectionPadding: intersectionRect.anchors.margins
    }

    property Component previewComponent: PreviewNavbar {}

    FileView {
        id: settingsWatcher
        path: Qt.resolvedUrl("./config/navbar.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
            root.mainRect.rounding = settings.rounding || root.mainRect.rounding;
            root.mainRect.padding = settings.padding || root.mainRect.padding;
            // Assign backingRect properties
            root.backingRect.color = settings.backingRect?.color || root.backingRect.color;
            root.backingRect.x = settings.backingRect?.x || root.backingRect.x;
            root.backingRect.y = settings.backingRect?.y || root.backingRect.y;
            root.backingRect.opacity = settings.backingRect?.opacity || root.backingRect.opacity;
            // Assign intersection properties
            root.intersection.opacity = settings.intersection?.opacity || root.intersection.opacity;
            root.intersection.color = settings.intersection?.color || root.intersection.color;
            root.intersection.border.color = settings.intersection?.border?.color || root.intersection.border.color;
            root.intersection.border.width = settings.intersection?.border?.width || root.intersection.border.width;
        }
        onLoadFailed: root.saveSettings()
    }

    function saveSettings() {
        const settings = {
            rounding: root.mainRect.rounding || 0,
            padding: root.mainRect.padding || 0,
            backingRect: {
                color: root.backingRect.color || ColorPalette.background,
                x: root.backingRect.x || 0,
                y: root.backingRect.y || 0,
                opacity: root.backingRect.opacity || 0
            },
            intersection: {
                opacity: root.intersection.opacity || 0,
                color: root.intersection.color,
                border: {
                    color: root.intersection.border.color,
                    width: root.intersection.border.width
                }
            }
        };
        settingsWatcher.setText(JSON.stringify(settings, null, 2));
    }

    RowLayout {
        width: parent.width

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10

        Text {
            text: qsTr("Navbar Settings")
        }
    }
}
