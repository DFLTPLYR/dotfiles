import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

import qs
import qs.utils
import qs.services
import qs.components

AnimatedScreenOverlay {
    id: toplevel

    screen: screenRoot.modelData
    key: 'ClipBoard'

    color: Scripts.hexToRgba(Colors.background, 0.2)

    onClicked: {
        return GlobalState.toggleDrawer("clipBoard");
    }

    onHidden: key => GlobalState.removeDrawer(key)

    KeyboardEventHandler {
        Keys.onPressed: event => {
            const currentItem = clipboardList.currentItem;
            switch (event.key) {
            case Qt.Key_Escape:
                searchValue = "";
                GlobalState.toggleDrawer("clipBoard");
                event.accepted = true;
                break;
            case Qt.Key_Backspace:
                searchValue = searchValue.slice(0, -1);
                showSearchInput = true;
                searchTimer.restart();
                event.accepted = true;
                break;
            case Qt.Key_Enter:
            case Qt.Key_Return:
                if (currentItem) {
                    const id = currentItem.modelData.id;
                    copySelectedId(id);
                }

                event.accepted = true;
                break;
            case Qt.Key_Delete:
                if (currentItem) {
                    const id = currentItem.modelData.id;
                    deleteClipboardEntry(id);
                    event.accepted = true;
                }
                break;
            case Qt.Key_Left:
            case Qt.Key_Down:
                if (clipboardList.currentIndex < clipboardList.count - 1)
                    clipboardList.currentIndex += 1;
                event.accepted = true;
                break;
            case Qt.Key_Up:
            case Qt.Key_Right:
                if (clipboardList.currentIndex > 0)
                    clipboardList.currentIndex -= 1;
                event.accepted = true;
                break;
            default:
                if (event.text.length > 0) {
                    searchValue += event.text;
                    showSearchInput = true;
                    searchTimer.restart();
                    event.accepted = true;
                }
            }
        }
    }

    Timer {
        id: searchTimer
        interval: 1000
        repeat: false
        onTriggered: {
            showSearchInput = false;
        }
    }

    property string searchValue: ""
    property bool showSearchInput: false

    readonly property bool isPortrait: screen.height > screen.width

    // Target sizes
    property real targetWidth: 400
    property real targetHeight: 600

    ClippingRectangle {
        id: morphBox
        anchors.centerIn: parent

        width: Math.max(1, targetWidth * animProgress)
        height: Math.max(1, targetHeight * animProgress)

        scale: animProgress
        opacity: animProgress

        radius: 2

        transformOrigin: Item.Center
        color: Scripts.hexToRgba(Colors.background, 0.8)

        border.color: Scripts.hexToRgba(Colors.colors10, 1)
        border.width: 2

        x: Math.round(screen.width / 2 - width / 2)
        y: Math.round(screen.height / 2 - height / 2)

        ListView {
            id: clipboardList
            anchors.centerIn: parent

            width: Math.round(parent.width * 0.95)
            height: Math.round(parent.height * 0.95)

            clip: false
            orientation: ListView.Vertical

            spacing: 2

            focus: true
            snapMode: ListView.SnapToItem
            boundsBehavior: Flickable.StopAtBounds

            preferredHighlightBegin: height / 2 - (48 / 2)
            preferredHighlightEnd: height / 2 + (48 / 2)
            highlightFollowsCurrentItem: true
            highlightRangeMode: ListView.StrictlyEnforceRange

            onCountChanged: {
                clipboardList.currentIndex = 0;
            }

            model: ScriptModel {
                values: {
                    if (!toplevel.searchValue || toplevel.searchValue.trim() === "")
                        return toplevel.clipboardHistory.filter(obj => obj.text && obj.text.trim().length > 0);
                    return toplevel.clipboardHistory.filter(obj => obj.text && obj.text.trim().length > 0 && obj.text.toLowerCase().includes(toplevel.searchValue.toLowerCase()));
                }
            }

            delegate: Item {
                required property var modelData

                property bool isSelected: ListView.isCurrentItem
                property bool isHovered: clickableArea.containsMouse
                visible: clipboardList.count !== 0
                width: clipboardList.width
                height: 48 // adjust height if you want else...then dont wtf

                Rectangle {
                    id: container

                    anchors.fill: parent

                    border.color: isHovered || isSelected ? Colors.color10 : Colors.color15

                    color: isHovered || isSelected ? Colors.color10 : Scripts.hexToRgba(Colors.background, 0.2)
                    radius: 4

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        width: Math.round(parent.width * 0.95)
                        height: parent.height
                        spacing: 8

                        // First child: fills width and height
                        Text {
                            text: modelData.text.length > 80 ? modelData.text.slice(0, 80) + "..." : modelData.text
                            color: isHovered || isSelected ? Colors.color15 : Colors.color10
                            font.pixelSize: 18
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: Text.AlignVCenter
                            MouseArea {
                                id: clickableArea
                                anchors.fill: parent
                                propagateComposedEvents: true
                                onClicked: {
                                    toplevel.copySelectedId(modelData.id);
                                }
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        // Second child: example icon or placeholder
                        Text {
                            id: trash
                            text: '\uf1f8'
                            color: isHovered || isSelected ? Colors.color15 : Colors.color10

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    toplevel.deleteClipboardEntry(modelData.id);
                                }
                                z: 1
                            }
                        }

                        // Third child: example button or placeholder
                        Text {
                            id: copy
                            text: '\uf0c5'
                            color: isHovered || isSelected ? Colors.color15 : Colors.color10
                        }
                    }
                }
            }
        }

        Text {
            id: searchLabel
            text: qsTr(searchValue)
            font.pixelSize: 32
            font.bold: true
            anchors.centerIn: parent
            color: Colors.color15
            opacity: showSearchInput ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Text {
            id: searchLabel
            text: qsTr(searchValue)
            font.pixelSize: 32
            font.bold: true
            anchors.centerIn: parent
            color: Colors.color15
            opacity: showSearchInput ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    property var clipboardHistory: []
    function copySelectedId(id) {
        const command = ['sh', '-c', `cliphist decode ${id} | wl-copy`];
        copyClipboardEntry.command = command;
        return copyClipboardEntry.running = true;
    }

    function shellSingleQuoteEscape(str) {
        return str.replace(/'/g, "'\\''");
    }

    function deleteClipboardEntry(text) {
        const safeText = text.replace(/'/g, "'\\''");
        const command = ['bash', '-c', `printf '%s' '${safeText}' | cliphist delete`];
        removeClipboardEntry.command = command;
        removeClipboardEntry.running = true;
    }

    Process {
        id: removeClipboardEntry
        running: false
        onExited: (exitCode, exitStatus) => {
            cbHistory.running = true;
        }
    }

    Process {
        id: copyClipboardEntry
        running: false
    }

    // start up
    Process {
        id: cbHistory
        command: ['cliphist', 'list']
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split('\n');
                const clipboardArray = lines.map(line => {
                    const [id, ...textParts] = line.split('\t');
                    return {
                        id: id,
                        text: textParts.join('\t')
                    };
                });
                clipboardHistory = clipboardArray;
            }
        }
    }

    Component.onCompleted: {
        cbHistory.running = true;
    }

    Connections {
        target: GlobalState
        function onShowClipBoardChangedSignal(value, monitorName) {
            const isMatch = monitorName === screen.name;

            if (isMatch) {
                toplevel.shouldBeVisible = value;
            }
        }
    }

    Connections {
        target: copyClipboardEntry
        function onExited(exitCode, exitStatus) {
            return GlobalState.toggleDrawer("clipBoard");
        }
    }
}
