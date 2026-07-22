pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.core
import qs.types
import qs.modules.dock
import qs.modules.background
import qs.modules.overlay

Variants {
    model: Quickshell.screens
    delegate: Item {
        id: reshell
        required property ShellScreen modelData
        property FileModel dock: FileModel {
            onSaved: list => {
                adapter.docks = list.map(item => item.name);
                fileview.save();
            }
        }

        implicitWidth: modelData.width
        implicitHeight: modelData.height
        x: modelData.x
        y: modelData.y

        // config
        FileView {
            id: fileview
            path: Qt.resolvedUrl(`./core/data/monitor/${modelData.name}.json`)
            watchChanges: true
            preload: true
            onLoaded: {
                Global.configs.push({
                    "screen": reshell.modelData,
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
                property Notification notification: Notification {}
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
                property var screen: reshell.modelData

                // overlay
                Overlay {
                    screen: display.screen
                }

                // docks
                Instantiator {
                    id: dockInstantiator
                    model: reshell.dock
                    delegate: Dock {
                        screen: display.screen
                        onAddDock: item => fileview.docklist = fileview.docklist.concat([item])
                        onRemoveDock: idx => {
                            const model = reshell.dock;
                            const screen = reshell.modelData.name;
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
                        screen: display.screen
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
    }

    component Notification: JsonObject {
        property int duration: 5000
        property int width: 300
        property int height: 100
        property string sizing: "custom"
        property string position: "right"
        property bool reverse: true
        readonly property JsonObject style: JsonObject {
            property color color: Colors.setOpacity(Colors.theme.surface, 0.5)
            property DirectionJson padding: DirectionJson {}
            property DirectionJson inset: DirectionJson {}
            property JsonObject background: JsonObject {
                property CornerJson rounding: CornerJson {}
                property DirectionJson margins: DirectionJson {}

                function apply(data) {
                    if (data.rounding !== undefined)
                        rounding.apply(data.rounding);
                    if (data.margins !== undefined)
                        margins.apply(data.margins);
                }
            }

            function apply(data) {
                if (data.color !== undefined)
                    color = data.color;
                if (data.padding !== undefined)
                    padding.apply(data.padding);
                if (data.inset !== undefined)
                    inset.apply(data.inset);
                if (data.background !== undefined)
                    background.apply(data.background);
            }
        }

        function apply(data) {
            if (data.duration !== undefined)
                duration = data.duration;
            if (data.width !== undefined)
                width = data.width;
            if (data.height !== undefined)
                height = data.height;
            if (data.sizing !== undefined)
                sizing = data.sizing;
            if (data.position !== undefined)
                position = data.position;
            if (data.reverse !== undefined)
                reverse = data.reverse;
            if (data.style !== undefined)
                style.apply(data.style);
        }
    }
}
