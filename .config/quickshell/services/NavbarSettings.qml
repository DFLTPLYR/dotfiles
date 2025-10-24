import Quickshell.Io
import QtQuick

Singleton {
    id: navbarSettings
    property string style: "neumorphic"
    property int rounding: 0

    FileView {
        id: settingsWatcher
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
            console.log("Navbar settings loaded: ", settingsWatcher.text().navbar);
        }
        onLoadFailed: {
            console.log("Failed to load navbar settings");
        }
    }
}
