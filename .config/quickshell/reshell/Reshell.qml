pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: reshell
        required property ShellScreen modelData

        property FileModel dock: FileModel {
            onSaved: list => {
                adapter.docks = list.map(item => item.name);
                fileview.save();
            }
        }

        implicitWidth: screen.width
        implicitHeight: screen.height

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: `Reshell-${screen.name}`

        screen: modelData
        color: "transparent"

        mask: Region {
            regions: [
                Region {
                    item: content.item
                }
            ]
        }

        // config
        FileView {
            id: fileview
            path: Qt.resolvedUrl(`./core/data/${screen.name}.json`)
            watchChanges: true
            preload: true
            onLoaded: {
                Global.configs.push({
                    "screen": reshell.screen.name,
                    "config": fileview
                });
                content.active = true;
                const source = adapter.docks.map(value => ({
                            name: value
                        }));
                reshell.dock.sources = source;
            }
            property list<var> docklist: []
            property list<var> updateQueue: []

            onDocklistChanged: {
                for (let i = 0; i < docklist.length; i++) {
                    const panelObj = docklist[i].panel;
                    if (panelObj && panelObj.objectName !== null) {
                        const matched = updateQueue.find(obj => obj.name === panelObj.objectName);
                        if (matched) {
                            const config = docklist[i].config;
                            const direction = matched.direction;
                            config.setUp(direction);
                            const idx = updateQueue.indexOf(matched);
                            if (idx !== -1)
                                updateQueue.splice(idx, 1);
                        }
                    }
                }
            }

            onFileChanged: {
                reload();
            }

            onLoadFailed: error => {
                if (error === FileViewError.FileNotFound) {
                    fileview.setText("{}");
                    fileview.writeAdapter();
                    Quickshell.reload(true);
                }
            }

            adapter: JsonAdapter {
                id: adapter
                property list<var> docks: []
                property JsonObject notification: JsonObject {
                    property bool local: false
                    property int duration: 5000
                    property int width: 100
                }
            }

            function save() {
                fileview.writeAdapter();
            }
        }

        // Wayland Layers
        LazyLoader {
            id: content
            component: Item {
                id: display

                // overlay
                Overlay {
                    screen: reshell.screen
                }

                // docks
                Instantiator {
                    id: dockInstantiator
                    model: reshell.dock
                    delegate: Dock {
                        screen: reshell.screen
                        onAddDock: item => fileview.docklist = fileview.docklist.concat([item])
                        onRemoveDock: idx => {
                            const model = reshell.dock;
                            const screen = reshell.screen.name;
                            const obj = model.get(idx);
                            const fileUrl = Qt.resolvedUrl(`./core/data/docks/${screen}+${obj.name}.json`);
                            const filePath = fileUrl.toString().replace('file://', '');
                            Quickshell.execDetached(["rm", "-rf", filePath]);
                            model.remove(idx, 1);
                            model.save();
                        }
                    }
                    onObjectRemoved: (_idx, object) => object.destroy()
                }

                // background
                LazyLoader {
                    active: Wallpaper.ready
                    component: Background {
                        screen: reshell.screen
                        file: fileview
                        onDockUpdate: dock => {
                            reshell.dock.append({
                                "name": dock.name
                            });
                            reshell.dock.save();
                            fileview.updateQueue.push(dock);
                        }
                    }
                }
            }
        }

        Connections {
            target: Global
            function onColorUpdate() {
                const docks = fileview.docklist;
                for (const i in docks) {
                    docks[i].config.updateColor();
                }
            }
        }
    }
}
