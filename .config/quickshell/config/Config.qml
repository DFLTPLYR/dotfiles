pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.config

Singleton {
    property alias navbar: adapter.navbarConfig

    FileView {
        id: fileView
        path: "./config.json"
        watchChanges: true
        onLoaded: {
            try {
                JSON.parse(text());
                console.log(Quickshell.workingDirectory);
            } catch (e) {
                fileView.setText("{}");
                fileView.writeAdapter();
            }
        }
        onFileChanged: {
            reload();
        }
        onLoadFailed: {
            setText("{}");
            fileView.writeAdapter();
        }
        onAdapterUpdated: writeAdapter()
        JsonAdapter {
            id: adapter
            property NavbarConfig navbarConfig: NavbarConfig {}
        }
    }
}
