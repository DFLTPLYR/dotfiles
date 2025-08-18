import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

import qs.services
import qs

GridView {
    id: grid
    anchors.fill: parent

    property string searchText: ""
    property int columns: cellWidth > 0 ? Math.max(1, Math.floor(width / cellWidth)) : 1
    property ListModel appList: ListModel {}

    clip: true

    cellWidth: Math.floor(parent.width / 6)
    cellHeight: Math.floor(parent.width / 6)

    focus: true
    keyNavigationWraps: true
    keyNavigationEnabled: true

    boundsBehavior: Flickable.StopAtBounds
    snapMode: GridView.NoSnap

    function updateDesktopApplicationsList(searchText) {
        appList.clear();
        const DesktopApplications = DesktopEntries.applications.values.filter(a => !a.noDisplay).filter(a => !(a.categories || []).includes("X-LSP-Plugins")).sort((a, b) => a.name.localeCompare(b.name));

        let filteredApps = DesktopApplications;
        if (searchText && searchText.trim() !== "") {
            const search = searchText.toLowerCase();
            filteredApps = DesktopApplications.filter(app => {
                const nameMatch = app.name?.toLowerCase().includes(search);
                const commentMatch = app.comment?.toLowerCase().includes(search);
                const categoriesMatch = (app.categories || []).join(" ").toLowerCase().includes(search);
                return nameMatch || commentMatch || categoriesMatch;
            });
        }

        for (let i = 0; i < filteredApps.length; ++i) {
            appList.append(filteredApps[i]);
        }
    }

    onSearchTextChanged: updateDesktopApplicationsList(searchText)

    onCountChanged: {
        grid.currentIndex = 0;
    }

    model: appList

    function openApp() {
        var entry = grid.currentItem.modelData;

        // Split execString into command array (handles spaces)
        var execArgs = entry.execString.split(" ");

        if (entry.runInTerminal) {
            Quickshell.execDetached({
                command: ["kitty", "-e", "zsh", "-c"].concat(execArgs),
                workingDirectory: entry.workingDirectory
            });
        } else {
            Quickshell.execDetached({
                command: execArgs,
                workingDirectory: entry.workingDirectory
            });
        }
        GlobalState.toggleDrawer("appMenu");
    }

    delegate: Rectangle {
        id: rect
        required property var modelData
        width: grid.cellWidth
        height: grid.cellHeight
        color: "transparent"

        property bool isHovered: false
        property bool isSelected: GridView.isCurrentItem

        ClippingRectangle {
            anchors.centerIn: parent

            width: Math.floor(grid.cellWidth * 0.9)
            height: Math.floor(grid.cellHeight * 0.9)

            radius: 5
            color: isHovered || isSelected ? Colors.backgroundAlt : "transparent"

            border.color: isSelected ? Colors.foreground : "transparent"
            border.width: isSelected ? 2 : 0

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                }
            }

            Column {
                anchors.fill: parent
                spacing: 0

                Item {
                    width: Math.floor(parent.width)
                    height: Math.floor(parent.height * 0.6)

                    IconImage {
                        anchors.centerIn: parent
                        source: Quickshell.iconPath(modelData.icon, "image-missing")
                        width: 48
                        height: 48
                        mipmap: false
                    }
                }

                Item {
                    width: Math.floor(parent.width)
                    height: Math.floor(parent.height * 0.4)

                    Text {
                        anchors.centerIn: parent
                        width: parent.width
                        text: modelData.name
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        color: Colors.color15
                        smooth: false
                        layer.enabled: true
                    }
                }
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                isHovered = true;
                grid.currentIndex = modelData.index;
            }
            onExited: isHovered = false
            onClicked: grid.openApp()
        }
    }

    add: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 200
        }
    }

    remove: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 200
        }
    }

    Component.onCompleted: updateDesktopApplicationsList(searchText)
}
