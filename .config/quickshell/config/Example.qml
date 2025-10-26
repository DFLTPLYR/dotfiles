pragma Singleton
import QtQuick

import Quickshell.Io

Item {
    id: root
    property QtObject mainRect: QtObject {
        property int rounding: 0
        property int padding: 0
    }

    property QtObject backingRect: QtObject {
        property bool enabled: true
        property string color: "background"
        property int x: 0
        property int y: 0
        property real opacity: 1
    }

    property QtObject intersection: QtObject {
        property bool enabled: true
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
            root.backingRect.enabled = settings.backingRect?.enabled || root.backingRect.enabled;
            root.backingRect.color = settings.backingRect?.color || root.backingRect.color;
            root.backingRect.x = settings.backingRect?.x || root.backingRect.x;
            root.backingRect.y = settings.backingRect?.y || root.backingRect.y;
            root.backingRect.opacity = settings.backingRect?.opacity || root.backingRect.opacity;

            // Assign intersection properties
            root.intersection.enabled = settings.intersection?.enabled || root.intersection.enabled;
            root.intersection.opacity = settings.intersection?.opacity || root.intersection.opacity;
            root.intersection.color = settings.intersection?.color || root.intersection.color;
            root.intersection.border.color = settings.intersection?.border?.color || root.intersection.border.color;
            root.intersection.border.width = settings.intersection?.border?.width || root.intersection.border.width;
        }
        onLoadFailed: root.saveSettings()
    }

    function saveSettings() {
        const settings = {
            rounding: root.mainRect.rounding,
            padding: root.mainRect.padding,
            backingRect: {
                enabled: root.backingRect.enabled,
                color: root.backingRect.color,
                x: root.backingRect.x,
                y: root.backingRect.y,
                opacity: root.backingRect.opacity
            },
            intersection: {
                enabled: root.intersection.enabled,
                opacity: root.intersection.opacity,
                color: root.intersection.color,
                border: {
                    color: root.intersection.border.color,
                    width: root.intersection.border.width
                }
            }
        };
        settingsWatcher.setText(JSON.stringify(settings, null, 2));
    }
}
