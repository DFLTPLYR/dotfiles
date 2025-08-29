//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QML_XHR_ALLOW_FILE_READ=1
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
import qs.bunservice

import qs.modules.bar
import qs.modules.sidebar
import qs.modules.appmenu
import qs.modules.extendedbar
import qs.modules.wallpaper
import qs.modules.sessionmenu
import qs.modules.notification

ShellRoot {
    id: root
    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: screenRoot
            required property var modelData
            screen: modelData

            color: "transparent"
            implicitHeight: 42

            Bar {}

            anchors {
                top: true
                left: true
                right: true
            }

            LazyLoader {
                active: persistStates.showMpris
                component: ExtendedBar {}
            }

            LazyLoader {
                active: persistStates.showWallpaperCarousel
                component: WallpaperCarousel {}
            }

            LazyLoader {
                active: persistStates.showClipBoard
                component: ClipBoard {}
            }

            LazyLoader {
                active: persistStates.showAppMenu
                component: AppMenu {}
            }

            PersistentProperties {
                id: persistStates
                reloadableId: modelData && modelData.name ? "persistStates-" + modelData.name : "persistStates-undefined"
                property bool showWallpaperCarousel: false
                property bool showMpris: false
                property bool showAppMenu: false
                property bool showClipBoard: false
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
                            name: 'ClipBoard',
                            property: 'showClipBoard'
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

    Shortcuts {}

    VolumeOsd {}

    LazyLoader {
        active: GlobalState.isSessionMenuOpen
        component: SessionMenu {}
    }

    Sidebar {}

    Scope {
        PersistentProperties {
            id: panelStates
            reloadableId: "persistPanelStates"
            property bool showWindowsOptions: false
        }

        Connections {
            target: GlobalState
            function onOpenPanelsUpdated() {
                const panels = [
                    {
                        name: 'WindowsOptions',
                        property: 'showWindowsOptions'
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

    NotificationList {}

    Connections {
        target: Assets
        function onParseDone() {
            Buns;
        }
    }

    Component.onCompleted: {
        Assets;
    }
}
