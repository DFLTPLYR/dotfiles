import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.config
import qs.assets
import qs.utils
import qs.components

Scope {
    id: root
    property bool isVisible: false
    signal toggle

    GlobalShortcut {
        id: cancelKeybind
        name: "showClipBoard"
        description: "Show Clipboard history"

        onPressed: {
            Qt.callLater(() => {
                root.isVisible = true;
                root.toggle();
            });
        }
    }

    LazyLoader {
        active: root.isVisible
        component: PanelWrapper {
            id: panelWrapper
            implicitWidth: 0
            color: isVisible ? Scripts.setOpacity(Color.background, 0.4) : "transparent"

            anchors {
                top: true
                bottom: true
                right: true
                left: true
            }

            KeyboardEventHandler {
                id: keyCatcher
                Keys.onPressed: event => {
                    const currentItem = clipboardList.currentItem;
                    switch (event.key) {
                    case Qt.Key_Escape:
                        searchValue = "";
                        panelWrapper.shouldBeVisible = false;
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
                            panelWrapper.shouldBeVisible = false;
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
            signal hide

            RowLayout {
                id: clipboardRoot

                x: Math.round(screen.width / 2 - width / 2)
                y: Math.round(screen.height / 2 - height / 2)

                width: Math.max(1, targetWidth * animProgress)
                height: Math.max(1, targetHeight * animProgress)

                scale: animProgress
                opacity: animProgress

                Item {
                    Layout.preferredWidth: clipboardRoot.width / 3
                    Layout.fillHeight: true

                    StyledRect {
                        childContainerHeight: parent.height

                        Item {
                            width: parent.width
                            height: 32

                            Text {
                                id: searchLabel
                                text: qsTr(panelWrapper.searchValue)
                                font.pixelSize: 32

                                font.bold: true

                                color: Color.color15
                                opacity: panelWrapper.showSearchInput ? 1.0 : 0.0
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
                            height: Math.round(parent.height)

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
                                        let pretty = raw.replace(/[ \t]+$/gm, "").replace(/\r\n/g, "\n");

                                        highlightedText.text = pretty;
                                        textScroller.visible = true;
                                    }
                                }
                            }

                            model: ScriptModel {
                                values: {
                                    if (!panelWrapper.searchValue || panelWrapper.searchValue.trim() === "")
                                        return panelWrapper.clipboardHistory.filter(obj => obj.text && obj.text.trim().length > 0);
                                    return panelWrapper.clipboardHistory.filter(obj => obj.text && obj.text.trim().length > 0 && obj.text.toLowerCase().includes(panelWrapper.searchValue.toLowerCase()));
                                }
                            }

                            delegate: ClipBoardItem {}

                            add: Transition {
                                NumberAnimation {
                                    property: "opacity"
                                    from: 0
                                    to: 1
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
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    StyledRect {
                        childContainerHeight: parent.height

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
                                    visible: clipboardList.currentItem && !clipboardList.currentItem.isImage
                                    readOnly: false
                                    textFormat: TextEdit.PlainText
                                    wrapMode: TextEdit.NoWrap
                                    color: Color.color15
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
                                            }
                                            break;
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
                        return panelWrapper.shouldBeVisible = false;
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
                                text: raw,
                                isImage
                            });
                        }
                        clipboardHistory = clipboardArray;
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Connections {
                target: root
                function onToggle() {
                    panelWrapper.shouldBeVisible = !panelWrapper.shouldBeVisible;
                }
            }

            Component.onCompleted: {
                cbHistory.running = true;
                if (this.WlrLayershell) {
                    this.WlrLayershell.layer = WlrLayer.Overlay;
                    this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
                    this.exclusionMode = ExclusionMode.Ignore;
                }
            }
        }
    }
}
