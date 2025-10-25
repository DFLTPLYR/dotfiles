import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: settingPanelService

    property bool darkMode: false
    property string theme: "neumorphic"

    FileView {
        id: settingsWatcher
        path: Qt.resolvedUrl("../../settings.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
            root.style = settings.theme || "neumorphic";
            console.log("Settings loaded: ", settingsWatcher.text());
        }
        onLoadFailed: {
            console.log("Failed to load settings");
        }
    }
}
