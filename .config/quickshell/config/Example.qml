pragma Singleton
import QtQuick

import Quickshell.Io

Item {
    id: root
    property QtObject mainrect: QtObject {
        property int rounding: 0
        property int padding: 0
    }

    property QtObject backingrect: QtObject {
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
            root.mainrect.rounding = settings.rounding || root.mainrect.rounding;
            root.mainrect.padding = settings.padding || root.mainrect.padding;

            // Assign backingrect properties
            root.backingrect.enabled = settings.backingrect?.enabled || root.backingrect.enabled;
            root.backingrect.color = settings.backingrect?.color || root.backingrect.color;
            root.backingrect.x = settings.backingrect?.x || root.backingrect.x;
            root.backingrect.y = settings.backingrect?.y || root.backingrect.y;
            root.backingrect.opacity = settings.backingrect?.opacity || root.backingrect.opacity;

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
            rounding: root.mainrect.rounding,
            padding: root.mainrect.padding,
            backingrect: {
                enabled: root.backingrect.enabled,
                color: root.backingrect.color,
                x: root.backingrect.x,
                y: root.backingrect.y,
                opacity: root.backingrect.opacity
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
