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

        property FileModel containers: FileModel {
            onSaved: list => {
                adapter.container = [...list];
                fileview.save();
            }
        }

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
                content.active = true;
                reshell.containers.sources = adapter.container;
                reshell.dock.sources = adapter.docks.map(value => ({
                            name: value
                        }));
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
                property list<var> container: []
            }

            function save() {
                fileview.writeAdapter();
            }
        }

        // Wayland Layers
        LazyLoader {
            id: content
            active: false
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
                }

                Bottom {
                    screen: reshell.screen
                    containers: reshell.containers
                    file: fileview
                    onDockUpdate: dock => {
                        reshell.dock.append({
                            "name": dock.name
                        });
                        reshell.dock.save();
                        fileview.updateQueue.push(dock);
                    }
                    onSave: reshell.containers.save()
                    onAddContainer: obj => reshell.containers.append(obj)
                    onRemoveContainer: idx => {
                        reshell.containers.remove(idx, 1);
                        reshell.containers.save();
                    }
                }

                // background
                LazyLoader {
                    active: Wallpaper.ready
                    component: Background {
                        screen: reshell.screen
                        file: fileview
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
