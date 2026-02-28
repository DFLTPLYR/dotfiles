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
    property ShellScreen selectedScreen: null
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
            property Navbar navbar: Navbar {}
            property ExtendedBar extendedbar: ExtendedBar {}
        }
    }

    component Navbar: JsonObject {
        property int width: 50
        property int height: 50
        property int spacing: 0
        property string position: "top" // top, bottom, left, right
        property bool side: position === "left" || position === "right"
        property list<var> layouts: []
        property list<var> widgets: []
        property color background: Colors.color.background
        property PopupProps popup: PopupProps {}
        property Style style: Style {}
    }

    component PopupProps: JsonObject {
        property int width: 40
        property int height: 40
        property color color: "black"
        property int x: 50
        property int y: 0
    }

    component Style: JsonObject {
        property bool usePanel: false
        property string panelSource: ""
        property int borderWidth: 0
        property color borderColor: "transparent"
        property color color: Colors.color.primary
        property JsonObject margin: JsonObject {
            property int left: 0
            property int right: 0
            property int top: 0
            property int bottom: 0
        }
        property JsonObject rounding: JsonObject {
            property int left: 0
            property int right: 0
            property int top: 0
            property int bottom: 0
        }
    }

    component ExtendedBar: JsonObject {
        property int width: 500
        property JsonObject padding: JsonObject {
            property int left: 0
            property int right: 0
            property int top: 0
            property int bottom: 0
        }
        property JsonObject margin: JsonObject {
            property int left: 0
            property int right: 0
            property int top: 0
            property int bottom: 0
        }
        property int height: 500
        property real axisRatio: 1.0
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
                    position: null,
                    margin: {
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0
                    },
                    padding: {
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0
                    },
                    width: 0,
                    height: 0
                };
                var regex = /property\s+(\w+)\s+(\w+)(?:\s*:\s*(.+?))?$/gm;
                var match;
                while ((match = regex.exec(content)) !== null) {
                    var value = match[3];
                    switch (match[1]) {
                    case "Spacing":
                        properties[match[2]] = {
                            left: 0,
                            right: 0,
                            bottom: 0,
                            top: 0
                        };
                        break;
                    default:
                        value = value.replace(/^["']|["']$/g, '');

                        if (match[2].includes("widgetWidth")) {
                            properties.width = value;
                        } else if (match[2].includes("widgetHeight")) {
                            properties.height = value;
                        } else {
                            properties[match[2]] = value;
                        }
                    }
                }
                return properties;
            }
            onPathChanged: {
                this.reload();
            }
            onLoaded: {
                var props = getProperties(text());
                navbar.config.widgets.push(props);
                // navbar.saveSettings();
                // later do a write here stop obsessing with DEADLOCK and LOCKIN TWINN
                this.destroy();
            }
        }
    }

    function saveSettings() {
        fileView.writeAdapter();
    }
}
