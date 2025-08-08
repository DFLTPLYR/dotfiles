//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Adjust this to make the shell smaller or larger
// @ pragma Env QT_SCALE_FACTOR=1
//@ pragma Env QT_QPA_PLATFORM=wayland

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick.Shapes
import Quickshell.Wayland

// component
import qs.modules
import qs.services
import qs.assets
import qs.components

import qs.modules.bar
import qs.modules.appmenu
import qs.modules.extendedbar
import qs.modules.wallpaper
import qs.modules.sessionmenu

ShellRoot {
    Variants {
        // see Variants for details
        model: Quickshell.screens

        PanelWindow {
            id: screenRoot
            property var modelData
            screen: modelData

            color: "transparent"
            implicitHeight: 42

            // margins {
            //     left: 10
            //     right: 10
            //     top: 10
            //     bottom: 10
            // }

            anchors {
                top: true
                left: true
                right: true
            }

            Bar {}

            // LazyLoader {
            //     active: persistStates.showWallpaperCarousel
            //     component: AnimatedScreenOverlay {
            //         id: overlay
            //         screen: modelData
            //         color: ColorUtils.hexToRgba(Colors.background, 0.2)
            //         onClicked: {
            //             return;
            //         }

            //         onHidden: key => GlobalState.removeDrawer(key)

            //         Connections {
            //             target: GlobalState

            //             function onShowWallpaperCarouselSignal(value, monitorName) {
            //                 const isMatch = monitorName === screen.name;

            //                 if (isMatch) {
            //                     overlay.shouldBeVisible = value;
            //                 }
            //             }
            //         }
            //     }
            // }

            LazyLoader {
                active: persistStates.showAppMenu
                activeAsync: true
                loading: true
                component: AppMenu {}
            }

            LazyLoader {
                active: persistStates.showMpris
                activeAsync: true
                loading: true
                component: ExtendedBar {}
            }

            LazyLoader {
                active: persistStates.showWallpaperCarousel
                activeAsync: true
                loading: true
                component: WallpaperCarousel {}
            }

            Scope {
                property var modelData

                PersistentProperties {
                    id: persistStates
                    reloadableId: modelData && modelData.name ? "persistStates-" + modelData.name : "persistStates-undefined"
                    property bool showWallpaperCarousel: false
                    property bool showMpris: false
                    property bool showAppMenu: false
                    property bool showWindowsOptions: false
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
                            },
                            {
                                name: 'WindowsOptions',
                                property: 'showWindowsOptions'
                            }
                        ];
                        const monitorName = modelData.name;

                        for (let i = 0; i < drawers.length; i++) {
                            const drawer = drawers[i];
                            const uniqueKey = ['WindowsOptions'];

                            const key = uniqueKey.includes(drawer.name) ? drawer.name : `${drawer.name}-${monitorName}`;

                            const exists = GlobalState.hasDrawer(key);
                            persistStates[drawer.property] = exists;
                        }
                    }
                }
            }
        }
    }

    Shortcuts {}

    VolumeOsd {}

    LazyLoader {
        active: GlobalState.isSessionMenuOpen
        component: SessionMenu {}
    }

    Scope {
        PersistentProperties {
            id: panelStates
            reloadableId: "persistPanelStates"
            property bool showAppMenu: false
            property bool showWindowsOptions: false
        }

        Connections {
            target: GlobalState
            function onOpenPanelsUpdated() {
                const panels = [
                    {
                        name: 'WindowsOptions',
                        property: 'showWindowsOptions'
                    },
                    {
                        name: 'AppMenu',
                        property: 'showAppMenu'
                    }
                ];

                for (let i = 0; i < panels.length; i++) {
                    const panel = panels[i];
                    const key = panel.name;
                    const exists = GlobalState.hasPanel(key);
                    panelStates[panel.property] = exists ?? false;
                }
            }
        }
    }

    // starting singletons
    Component.onCompleted: {
        HardwareStats;
        MprisManager;
        WallpaperStore;
        WeatherFetcher;
        AppManager;
        FontAssets;
    }
}
