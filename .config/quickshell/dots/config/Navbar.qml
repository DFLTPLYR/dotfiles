pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.folderlistmodel

import Quickshell
import Quickshell.Io

import qs.config

Singleton {
    id: navbar
    property alias config: adapter.navbar
    property alias extended: adapter.extendedbar

    property bool extendedOpen: false

    FileView {
        id: fileView
        path: Qt.resolvedUrl("./navbar.json")
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
        JsonAdapter {
            id: adapter
            property NavbarConfig navbar: NavbarConfig {}
            property ExtendedBarConfig extendedbar: ExtendedBarConfig {}
        }
    }

    FolderListModel {
        id: folderModel
        folder: Qt.resolvedUrl("../components/widgets")
        nameFilters: ["*.qml"]
        showDirs: false

        onCountChanged: {
            for (let i = 0; i < count; i++) {
                const fileName = get(i, "fileName");
                if (fileName !== "Wrapper.qml") {
                    const widgetName = fileName;
                    const exists = navbar.config.widgets.find(s => s.name === widgetName);
                    if (!exists) {
                        const target = Quickshell.shellPath(`components/widgets/${widgetName}`);
                        propertyCheckerComponent.createObject(navbar, {
                            path: target,
                            widget: widgetName
                        });
                        // navbar.config.widgets.push({
                        //     name: fileName,
                        //     width: 50,
                        //     height: 50,
                        //
                        //     icon: "clock-nine",
                        //     layout: "",
                        //     position: 0
                        // });
                        // navbar.saveSettings();
                    }
                }
            }
        }
    }

    Component {
        id: propertyCheckerComponent
        FileView {
            property string widget: ""
            function getProperties(content) {
                var properties = {
                    name: widget,
                    enableActions: true,
                    layout: "",
                    position: null
                };
                var regex = /property\s+(var|string|int|real|bool|color|url|list|component)\s+(\w+)(?:\s*:\s*(.+?))?$/gm;
                var match;
                while ((match = regex.exec(content)) !== null) {
                    var value = match[3];
                    if (value) {
                        value = value.replace(/^["']|["']$/g, '');
                    }
                    properties[match[2]] = value;
                }
                navbar.config.widgets.push(properties);
                return properties;
            }
            onPathChanged: {
                this.reload();
            }
            onLoaded: {
                var props = getProperties(text());
                // later do a write here stop obsessing with DEADLOCK and LOCKIN TWINN
                this.destroy();
            }
        }
    }

    function saveSettings() {
        fileView.writeAdapter();
    }
}
