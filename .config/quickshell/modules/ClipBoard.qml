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
import qs.assets
import qs.services
import qs.components

AnimatedScreenOverlay {
    id: toplevel

    screen: screenRoot.modelData
    key: 'ClipBoard'

    color: Scripts.setOpacity(ColorPalette.background, 0.2)

    onClicked: {
        return GlobalState.toggleDrawer("clipBoard");
    }

    onHidden: key => GlobalState.removeDrawer(key)

    KeyboardEventHandler {
        id: keyCatcher
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
                if (event.modifiers & Qt.ControlModifier) {
                    Quickshell.execDetached({
                        command: ["cliphist", "wipe"]
                    });
                    GlobalState.toggleDrawer("clipBoard");
                    event.accepted = true;
                } else {
                    if (currentItem) {
                        const id = currentItem.modelData.id;
                        deleteClipboardEntry(id);
                        event.accepted = true;
                    }
                }
                break;
            case Qt.Key_Left:
            case Qt.Key_Down:
                if (clipboardList.currentIndex < clipboardList.count - 1)
                    clipboardList.currentIndex += 1;
                event.accepted = true;
                break;
            case Qt.Key_Up:
                if (clipboardList.currentIndex > 0)
                    clipboardList.currentIndex -= 1;
                event.accepted = true;
                break;
            case Qt.Key_Right:
                highlightedText.focus = true;
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
    property real targetWidth: isPortrait ? screen.width * 0.9 : screen.width * 0.6
    property real targetHeight: screen.height * 0.5

    RowLayout {
        id: clipboardRoot

        x: Math.round(screen.width / 2 - width / 2)
        y: Math.round(screen.height / 2 - height / 2)

        width: Math.max(1, targetWidth * animProgress)
        height: Math.max(1, targetHeight * animProgress)

        scale: animProgress
        opacity: animProgress

        Rectangle {
            border.color: Scripts.setOpacity(ColorPalette.colors10, 0.9)
            border.width: 2

            Layout.preferredWidth: clipboardRoot.width / 3
            Layout.fillHeight: true
            color: Scripts.setOpacity(ColorPalette.background, 0.8)
            radius: 10
            clip: true

            Rectangle {
                width: parent.width
                height: 32
                color: 'transparent'

                Text {
                    id: searchLabel
                    text: qsTr(searchValue)
                    font.pixelSize: 32

                    font.bold: true

                    color: ColorPalette.color15
                    opacity: showSearchInput ? 1.0 : 0.0
                    font.family: FontProvider.fontSometypeMono
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            ListView {
                id: clipboardList
                anchors.centerIn: parent

                width: Math.round(parent.width * 0.95)
                height: Math.round(parent.height * 0.95)

                clip: false
                orientation: ListView.Vertical

                spacing: 10

                focus: true
                snapMode: ListView.SnapToItem
                boundsBehavior: Flickable.StopAtBounds

                preferredHighlightBegin: height / 2 - (48 / 2)
                preferredHighlightEnd: height / 2 + (48 / 2)
                highlightFollowsCurrentItem: true
                highlightRangeMode: ListView.StrictlyEnforceRange

                onCurrentItemChanged: {
                    var item_id = clipboardList.currentItem.modelData.id;
                    if (!clipboardList.currentItem.isImage) {
                        decodeClip.id = item_id;
                        decodeClip.running = true;
                    } else {
                        textScroller.visible = false;
                    }
                }

                Process {
                    id: decodeClip
                    running: false
                    property int id
                    command: ["cliphist", "decode", id]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            let raw = this.text;

                            // keep indentation, only strip trailing spaces and fix newlines
                            let pretty = raw.replace(/[ \t]+$/gm, "") // remove trailing spaces at end of line
                            .replace(/\r\n/g, "\n"); // normalize Windows CRLF to LF

                            highlightedText.text = pretty;
                            textScroller.visible = true;
                        }
                    }
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
                    readonly property bool isImage: modelData.text.startsWith("[[ binary data") && modelData.text.includes("KiB") && (modelData.text.includes("png") || modelData.text.includes("jpeg") || modelData.text.includes("jpg"))
                    property bool isSelected: ListView.isCurrentItem
                    property bool isHovered: clickableArea.containsMouse

                    visible: clipboardList.count !== 0
                    width: clipboardList.width
                    height: 72

                    Rectangle {
                        id: container
                        anchors.fill: parent

                        border.color: isHovered || isSelected ? ColorPalette.color10 : ColorPalette.color15

                        color: isHovered || isSelected ? ColorPalette.color10 : Scripts.setOpacity(ColorPalette.background, 0.2)
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
                            Item {
                                id: clipboardDisplay
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                Text {
                                    id: clipboardText
                                    color: isHovered || isSelected ? ColorPalette.color15 : ColorPalette.color10
                                    width: parent.width
                                    height: parent.height

                                    anchors {
                                        left: parent.left // Start at the left
                                        verticalCenter: parent.verticalCenter // Center vertically
                                    }

                                    visible: false
                                    font.pixelSize: 18

                                    elide: Text.ElideRight
                                    wrapMode: Text.WordWrap
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Component.onCompleted: {
                                    var data = modelData.text;
                                    if (data.startsWith("[[ binary data")) {
                                        clipboardText.text = "IMAGE";
                                        clipboardText.color = ColorPalette.color15;
                                        clipboardText.visible = true;
                                    } else {
                                        clipboardText.text = modelData.text;
                                        clipboardText.visible = true;
                                    }
                                }

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
                                color: isHovered || isSelected ? ColorPalette.color15 : ColorPalette.color10

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        toplevel.deleteClipboardEntry(modelData.id);
                                    }
                                    z: 1
                                }
                            }

                            Text {
                                id: copy
                                text: '\uf0c5'
                                color: isHovered || isSelected ? ColorPalette.color15 : ColorPalette.color10
                            }
                        }
                    }
                }

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 250
                    }
                    NumberAnimation {
                        property: "x"
                        from: 200
                        to: 0
                        duration: 250
                    }
                }

                remove: Transition {
                    id: removeTransition
                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 250
                    }
                    NumberAnimation {
                        property: "x"
                        to: -200
                        duration: 250
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: 250
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Scripts.setOpacity(ColorPalette.background, 0.8)
            radius: 10

            Item {
                anchors.fill: parent

                Flickable {
                    id: textScroller
                    anchors.fill: parent
                    visible: clipboardList.currentItem && !clipboardList.currentItem.isImage
                    contentWidth: highlightedText.contentWidth
                    contentHeight: highlightedText.contentHeight
                    clip: true

                    TextEdit {
                        id: highlightedText
                        readOnly: false
                        textFormat: TextEdit.PlainText
                        wrapMode: TextEdit.NoWrap
                        color: ColorPalette.color15
                        font.pixelSize: 18
                        anchors.fill: parent
                        cursorVisible: focus
                        selectByMouse: false
                        font.family: FontProvider.fontSometypeMono
                        Keys.onPressed: function (event) {
                            switch (event.key) {
                            case Qt.Key_Escape:
                                keyCatcher.focus = true;
                                event.accepted = true;
                                break;
                            case Qt.Key_Left:
                                if (event.modifiers & Qt.ControlModifier) {
                                    keyCatcher.focus = true;
                                    event.accepted = true;
                                    break;
                                }
                            default:
                                break;
                            }
                        }
                    }
                }

                Image {
                    id: highlightedImage
                    visible: clipboardList.currentItem && clipboardList.currentItem.isImage
                    source: Quickshell.iconPath(`${Quickshell.env("HOME")}/.cache/clipboard/image_${clipboardList.currentItem?.modelData.id}.png`, true)
                    fillMode: Image.PreserveAspectFit
                    anchors.fill: parent
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
        stdout: StdioCollector {
            onStreamFinished: {
                return GlobalState.toggleDrawer("clipBoard");
            }
        }
    }

    // start up
    Process {
        id: cbHistory
        command: ['cliphist', 'list', '-preview-width', '10000']
        environment: ({
                CLIPHIST_PREVIEW_WIDTH: 100000,
                CLIPHIST_MAX_ITEMS: 1
            })
        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim();
                if (!out) {
                    clipboardHistory = [];
                    return;
                }

                const lines = out.split('\n');
                const clipboardArray = [];
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i];
                    const [id, ...textParts] = line.split('\t');
                    let raw = textParts.join('\t');

                    raw = raw.replace(/\\r\\n/g, "\n").replace(/\\n/g, "\n").replace(/\\r/g, "\n").replace(/\\t/g, "\t").replace(/\\\\/g, "\\");

                    if (raw.endsWith(','))
                        raw = raw.slice(0, -1);

                    const isImage = raw.startsWith("[[ binary data") && raw.includes("KiB") && (raw.includes("png") || raw.includes("jpeg") || raw.includes("jpg"));

                    if (isImage) {
                        const imagePath = `${Quickshell.env("HOME")}/.cache/clipboard/image_${id}.png`;
                        const iconExists = Quickshell.iconPath(imagePath, true);
                        if (!iconExists) {
                            Quickshell.execDetached({
                                command: ["sh", "-c", `mkdir -p ${Quickshell.env("HOME")}/.cache/clipboard && cliphist decode ${id} > ${imagePath}`]
                            });
                        }
                    }

                    clipboardArray.push({
                        id: id,
                        text: raw
                    });
                }
                clipboardHistory = clipboardArray;
            }
        }
    }

    Component.onCompleted: cbHistory.running = true

    Connections {
        target: GlobalState
        function onShowClipBoardChangedSignal(value, monitorName) {
            const isMatch = monitorName === screen.name;
            if (isMatch) {
                toplevel.shouldBeVisible = value;
            }
        }
    }
}
