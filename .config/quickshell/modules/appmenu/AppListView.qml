import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

import qs.config
import qs.assets
import qs.services

GridView {
    id: grid

    anchors.fill: parent
    property int columns: cellWidth > 0 ? Math.max(1, Math.floor(width / cellWidth)) : 1
    property string searchText: ""
    property ListModel appList: ListModel {}

    clip: true

    cellWidth: Math.floor(parent.width / 5)
    cellHeight: Math.floor(parent.width / 5)

    focus: true
    keyNavigationWraps: true
    keyNavigationEnabled: true

    boundsBehavior: Flickable.StopAtBounds
    snapMode: GridView.NoSnap

    function updateDesktopApplicationsList(searchText) {
        grid.appList.clear();

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

    onSearchTextChanged: updateDesktopApplicationsList(grid.searchText)

    onCountChanged: {
        grid.currentIndex = 0;
    }

    model: appList

    function openApp() {
        var entry = grid.currentItem.modelData;

        // Clean execString by removing placeholders like %U, %u, %f, etc.
        var cleanedExec = entry.execString.replace(/%[a-zA-Z]/g, '').trim();

        // Split into command array, filtering out empty strings
        var execArgs = cleanedExec.split(/\s+/).filter(arg => arg !== '');

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
        root.toggle();
    }

    delegate: Rectangle {
        id: rect
        required property var modelData
        width: grid.cellWidth
        height: grid.cellHeight
        color: "transparent"

        property bool isHovered: false
        property bool isSelected: GridView.isCurrentItem

        Rectangle {
            anchors.centerIn: parent

            width: Math.floor(grid.cellWidth * 0.9)
            height: Math.floor(grid.cellHeight * 0.9)

            radius: 5
            color: rect.isHovered || isSelected ? Color.backgroundAlt : "transparent"

            border.color: isSelected ? Color.foreground : "transparent"
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
                        color: Color.color15
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

    Component.onCompleted: {
        grid.updateDesktopApplicationsList("");
    }
}
