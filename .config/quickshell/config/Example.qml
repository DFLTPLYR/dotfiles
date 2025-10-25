pragma Singleton
import QtQuick

import Quickshell.Io

Item {
    id: root
    property QtObject mainRect: QtObject {
        property int rounding: 20
        property int padding: 10
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

    FileView {
        id: settingsWatcher
        path: Qt.resolvedUrl("./testing.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
            console.log("Loaded settings:", settings);
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
        onLoadFailed: console.log("Failed to load settings")
    }

    function saveSettings() {
        const settings = {
            rounding: root.mainRect.rounding,
            padding: root.mainRect.padding,
            backingRect: {
                color: root.mainRect.backingRect.color,
                x: root.mainRect.backingRect.x,
                y: root.mainRect.backingRect.y,
                opacity: root.mainRect.backingRect.opacity
            },
            intersection: {
                opacity: root.mainRect.intersection.opacity,
                color: root.mainRect.intersection.color,
                border: {
                    color: root.mainRect.intersection.border.color,
                    width: root.mainRect.intersection.border.width
                }
            }
        };
        settingsWatcher.setText(JSON.stringify(settings, null, 2));
    }
}
