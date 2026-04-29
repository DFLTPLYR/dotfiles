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
                containerModel.sync();
            }
            property list<var> docklist: []
            property list<var> updateQueue: []

            property ListModel containers: ListModel {
                id: containerModel

                function save() {
                    const list = [];
                    for (let i = 0; i < count; i++) {
                        const object = containerModel.get(i);
                        list.push(JSON.parse(JSON.stringify(object)));
                    }
                    adapter.container = [...list];
                    fileview.save();
                }

                function sync() {
                    const containers = adapter.container;
                    for (const i in containers) {
                        containerModel.append(containers[i]);
                    }
                }
            }

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
                    fileview.save();
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

            function removeDock(name) {
                const array = fileview.docklist.filter(s => s && s.dock);
                const found = array.find(s => s.dock.objectName === name);
                if (found) {
                    found.panel.visible = false;
                }
                const docks = fileview.adapter.docks;
                const idx = docks.findIndex(s => s === name);
                if (idx !== -1) {
                    const fileUrl = Qt.resolvedUrl(`./core/data/docks/${reshell.screen.name}+${name}.json`);
                    const filePath = fileUrl.toString().replace('file://', '');
                    Quickshell.execDetached(["rm", "-rf", filePath]);
                    docks.splice(idx, 1);
                    fileview.adapter.docks = docks;
                }
                fileview.save();
            }
        }

        // Wayland Layers
        LazyLoader {
            id: content
            active: false
            component: Item {
                id: display

                property ListModel docks: ListModel {
                    id: dockModel
                    function save() {
                        let arr = [];
                        for (let i = 0; i < dockModel.count; i++) {
                            const name = dockModel.get(i).name;
                            arr.push(name);
                        }
                        adapter.docks = [...arr];
                        fileview.writeAdapter();
                    }
                    function sync() {
                        dockModel.clear();

                        const container = adapter.docks;
                        for (const i in container) {
                            dockModel.append({
                                "name": container[i]
                            });
                        }
                    }
                    Component.onCompleted: {
                        const container = adapter.docks;
                        for (const i in container) {
                            dockModel.append({
                                "name": container[i]
                            });
                        }
                    }
                }

                // overlay
                Overlay {
                    screen: reshell.screen
                }

                // docks
                Instantiator {
                    id: dockInstantiator
                    model: dockModel
                    delegate: Dock {
                        screen: reshell.screen
                        onAddDock: item => fileview.docklist = fileview.docklist.concat([item])
                        onRemoveDock: idx => {
                            const model = docks;
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
                    file: fileview
                    onDockUpdate: dock => {
                        dockModel.append({
                            "name": dock.name
                        });
                        dockModel.save();
                        fileview.updateQueue.push(dock);
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
