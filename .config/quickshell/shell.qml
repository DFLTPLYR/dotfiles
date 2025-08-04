//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick.Shapes
import Quickshell.Wayland

// component
import qs.modules
import qs.services

ShellRoot {
    // Shortcut

    Scope {
        Variants {
            // see Variants for details
            model: Quickshell.screens

            PanelWindow {
                id: screenRoot
                property var modelData
                screen: modelData
                WlrLayershell.layer: WlrLayer.Top
                color: "transparent"
                implicitHeight: 42

                margins {
                    left: screen.width / (screen.width * 0.25)
                    right: screen.width / (screen.width * 0.25)
                    top: 10
                    bottom: 10
                }

                anchors {
                    top: true
                    left: true
                    right: true
                }

                Navbar {}

                LazyLoader {
                    active: persistStates.showMpris
                    component: ResourceBar {}
                }

                LazyLoader {
                    active: persistStates.showWallpaperCarousel
                    component: WallpaperCarousel {}
                }

                Scope {
                    PersistentProperties {
                        id: persistStates
                        reloadableId: "persistStates-" + screen.name
                        property bool showWallpaperCarousel: false
                        property bool showMpris: false
                        property bool showAppMenu: false
                    }

                    Connections {
                        target: GlobalState
                        function onOpenDrawersUpdated() {
                            const drawers = [
                                {
                                    name: 'WallpaperCarousel',
                                    property: 'showWallpaperCarousel'
                                },
                                {
                                    name: 'MprisDashboard',
                                    property: 'showMpris'
                                },
                                {
                                    name: 'AppMenu',
                                    property: 'showAppMenu'
                                }
                            ];
                            const monitorName = screen.name;

                            for (let i = 0; i < drawers.length; i++) {
                                const drawer = drawers[i];
                                const key = `${drawer.name}-${monitorName}`;
                                const exists = GlobalState.hasDrawer(key);
                                persistStates[drawer.property] = exists;
                            }
                        }
                    }
                }
            }
        }
    }

    Shortcuts {}

    VolumeOsd {}

    // Component.onCompleted: HardwareStats.updateTimer.start()
    // PanelWindow {
    //     id: window
    //     width: 500
    //     height: 240
    //     visible: false
    //     color: "transparent"

    //     // Visual container for shape dimensions
    //     Item {
    //         id: wrapper
    //         width: parent.width
    //         height: parent.height
    //     }

    //     Shape {
    //         anchors.fill: wrapper

    //         ShapePath {
    //             id: root

    //             // All values defined locally
    //             readonly property real rounding: 40
    //             readonly property bool flatten: wrapper.height < rounding * 2
    //             readonly property real roundingY: flatten ? wrapper.height / 2 : rounding

    //             strokeWidth: -1
    //             fillColor: "#ccccff" // Instead of Colours.palette.m3surface

    //             // Top-left outward arc
    //             PathArc {
    //                 relativeX: root.rounding
    //                 relativeY: root.roundingY
    //                 radiusX: root.rounding
    //                 radiusY: root.roundingY
    //             }

    //             PathLine {
    //                 relativeX: 0
    //                 relativeY: wrapper.height - root.roundingY * 2
    //             }

    //             // Bottom-left outward arc
    //             PathArc {
    //                 relativeX: root.rounding
    //                 relativeY: root.roundingY
    //                 radiusX: root.rounding
    //                 radiusY: root.roundingY
    //                 direction: PathArc.Counterclockwise
    //             }

    //             PathLine {
    //                 relativeX: wrapper.width - root.rounding * 4
    //                 relativeY: 0
    //             }

    //             // Bottom-right outward arc
    //             PathArc {
    //                 relativeX: root.rounding
    //                 relativeY: -root.roundingY
    //                 radiusX: root.rounding
    //                 radiusY: root.roundingY
    //                 direction: PathArc.Counterclockwise
    //             }

    //             PathLine {
    //                 relativeX: 0
    //                 relativeY: -(wrapper.height - root.roundingY * 2)
    //             }

    //             // Top-right outward arc
    //             PathArc {
    //                 relativeX: root.rounding
    //                 relativeY: -root.roundingY
    //                 radiusX: root.rounding
    //                 radiusY: root.roundingY
    //             }

    //             Behavior on fillColor {
    //                 ColorAnimation {
    //                     duration: 250
    //                     easing.type: Easing.InOutQuad
    //                 }
    //             }
    //         }
    //     }
    // }

    // starting singletons
    Component.onCompleted: {
        HardwareStats;
        MprisManager;
        WallpaperStore;
        WeatherFetcher;
    }
}
