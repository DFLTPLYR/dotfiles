import QtQuick
import Quickshell
import QtQuick.Shapes
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland

import qs
import qs.utils
import qs.services
import qs.components

AnimatedScreenOverlay {
    id: toplevel
    screen: screenRoot.modelData
    key: 'AppMenu'

    color: Scripts.hexToRgba(Colors.background, 0.2)

    onClicked: {
        return;
    }

    onHidden: key => GlobalState.removeDrawer(key)

    Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Escape:
                searchValue = "";
                GlobalState.toggleDrawer("appMenu");
                event.accepted = true;
                break;
            case Qt.Key_Backspace:
                searchValue = searchValue.slice(0, -1);
                event.accepted = true;
                break;
            case Qt.Key_Enter:
            case Qt.Key_Return:
                if (grid.currentItem && grid.currentItem.openApp) {
                    grid.currentItem.openApp();
                }
                event.accepted = true;
                break;
            case Qt.Key_Left:
                if (grid.currentIndex > 0)
                    grid.currentIndex -= 1;
                event.accepted = true;
                break;
            case Qt.Key_Right:
                if (grid.currentIndex < grid.count - 1)
                    grid.currentIndex += 1;
                event.accepted = true;
                break;
            case Qt.Key_Up:
                grid.currentIndex = Math.max(0, grid.currentIndex - grid.columns);
                event.accepted = true;
                break;
            case Qt.Key_Down:
                grid.currentIndex = Math.min(grid.count - 1, grid.currentIndex + grid.columns);
                event.accepted = true;
                break;
            default:
                if (event.text.length > 0) {
                    searchValue += event.text;
                    event.accepted = true;
                }
            }
        }
    }

    property string searchValue: ''
    property bool isPortrait: screen.height > screen.width

    ClippingRectangle {
        width: Math.round(isPortrait ? screen.width / 1.5 : screen.width / 2.5)
        height: Math.round(isPortrait ? screen.height / 2.25 : screen.height / 2)

        x: Math.round(screen.width / 2 - width / 2)
        y: Math.round(screen.height / 2 - height / 2)

        color: Scripts.hexToRgba(Colors.background, 0.6)
        opacity: animProgress

        radius: 20

        scale: animProgress
        transformOrigin: Item.Center

        Column {
            anchors.fill: parent

            // Item list
            Item {
                height: Math.round(parent.height * 0.9)
                width: parent.width

                Rectangle {
                    anchors.fill: parent
                    color: Scripts.hexToRgba(Colors.foreground, 0.4)
                }

                Row {
                    anchors.fill: parent
                    Rectangle {
                        width: Math.round(parent.width * 0.2)
                        height: parent.height
                        clip: true

                        Image {
                            id: name
                            source: WallpaperStore.currentWallpapers[screen.name] ?? null
                            fillMode: Image.Pad
                        }
                    }

                    Rectangle {
                        width: Math.round(parent.width * 0.8)
                        height: parent.height
                        color: 'transparent'
                        AppListView {
                            id: grid
                            searchText: searchValue
                        }
                    }
                }
            }

            // Search Bar
            Item {
                height: Math.round(parent.height * 0.1)
                width: parent.width

                Rectangle {
                    anchors.fill: parent
                    color: Scripts.hexToRgba(Colors.background, 0.1)
                }

                Text {
                    id: searchText
                    text: qsTr(`Search: ${searchValue}`)
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    color: Colors.color15
                }
            }
        }
    }

    Connections {
        target: GlobalState

        function onShowAppMenuChangedSignal(value, monitorName) {
            const isMatch = monitorName === screen.name;

            if (isMatch) {
                toplevel.shouldBeVisible = value;
            }
        }
    }

    Component.onCompleted: AppManager.loadApplications()
}
