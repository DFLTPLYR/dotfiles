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
        path: Qt.resolvedUrl("./navbar.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
            root.mainrect.rounding = settings.rounding || root.mainrect.rounding;
            root.mainrect.padding = settings.padding || root.mainrect.padding;
            // Assign backingrect properties
            root.backingrect.color = settings.backingrect?.color || root.backingrect.color;
            root.backingrect.x = settings.backingrect?.x || root.backingrect.x;
            root.backingrect.y = settings.backingrect?.y || root.backingrect.y;
            root.backingrect.opacity = settings.backingrect?.opacity || root.backingrect.opacity;
            // Assign intersection properties
            root.intersection.opacity = settings.intersection?.opacity || root.intersection.opacity;
            root.intersection.color = settings.intersection?.color || root.intersection.color;
            root.intersection.border.color = settings.intersection?.border?.color || root.intersection.border.color;
            root.intersection.border.width = settings.intersection?.border?.width || root.intersection.border.width;
            console.log(root.mainconf);
        }
        onLoadFailed: console.log("Failed to load settings")
    }

    function saveSettings() {
        const settings = {
            rounding: root.mainrect.rounding || 0,
            padding: root.mainrect.padding || 0,
            backingrect: {
                color: root.backingrect.color || ColorPalette.background,
                x: root.backingrect.x || 0,
                y: root.backingrect.y || 0,
                opacity: root.backingrect.opacity || 0
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
}
