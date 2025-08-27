import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

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
    key: 'WallpaperCarousel'

    color: Scripts.hexToRgba(Colors.background, 0.2)

    onHidden: key => GlobalState.removeDrawer(key)

    KeyboardEventHandler {
        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Escape:
                searchValue = "";
                GlobalState.toggleDrawer("wallpaper");
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
                const currentItem = flick.currentItem;
                if (currentItem) {
                    const screenName = screen.name;
                    const path = currentItem.modelData.path;
                    WallpaperStore.setWallpaper(screenName, path);
                }

                event.accepted = true;
                break;
            case Qt.Key_Right:
            case Qt.Key_Down:
                if (flick.currentIndex < flick.count - 1)
                    flick.currentIndex += 1;
                event.accepted = true;
                break;
            case Qt.Key_Up:
            case Qt.Key_Left:
                if (flick.currentIndex > 0)
                    flick.currentIndex -= 1;
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
    property var tagFilter: []
    property var colorFilter: []
    property bool showSearchInput: false

    readonly property bool isPortrait: screen.height > screen.width

    // Target sizes
    property real targetWidth: screen.width * 0.9
    property real targetHeight: screen.height * 0.8

    // Content

    Item {
        width: Math.max(1, targetWidth * animProgress)
        height: Math.max(1, targetHeight * animProgress)

        scale: animProgress

        x: Math.round(screen.width / 2 - width / 2)
        y: Math.round(screen.height / 2 - height / 2)
        clip: true

        RowLayout {
            anchors.fill: parent

            // List Panel
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width / 4
                color: Scripts.setOpacity(Colors.background, 0.8)
                border.color: Scripts.setOpacity(Colors.colors10, 0.2)
                radius: 10

                ListView {
                    id: flick
                    anchors.fill: parent
                    spacing: 10
                    anchors.margins: 16

                    snapMode: ListView.SnapToItem
                    boundsBehavior: Flickable.StopAtBounds

                    highlightMoveDuration: 250
                    highlightMoveVelocity: 400
                    highlightFollowsCurrentItem: true
                    highlightRangeMode: ListView.StrictlyEnforceRange

                    property bool isPortrait: screen.height > screen.width

                    model: ScriptModel {
                        values: {
                            let wallpapers = isPortrait ? WallpaperStore.portraitWallpapers : WallpaperStore.landscapeWallpapers;
                            return wallpapers;
                        }
                    }

                    delegate: Rectangle {
                        id: wrapper
                        required property var modelData
                        implicitWidth: flick.width
                        height: 250
                        radius: 10
                        clip: true
                        color: Scripts.setOpacity(Colors.foreground, 0.2)
                        border.color: Scripts.setOpacity(Colors.colors10, 0.2)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            Rectangle {
                                Layout.preferredHeight: parent.height * 0.8
                                Layout.fillWidth: true
                                color: 'transparent'

                                Image {
                                    id: maskee
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop
                                    source: Qt.resolvedUrl(modelData.path)
                                    cache: true
                                    asynchronous: true
                                    smooth: true
                                    visible: false
                                }

                                Rectangle {
                                    id: masking
                                    anchors.fill: parent
                                    radius: 16
                                    clip: true
                                    visible: false
                                }

                                OpacityMask {
                                    anchors.fill: parent
                                    source: maskee
                                    maskSource: masking
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                        }

                        MouseArea {
                            z: 10
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                var resolvedIndex = -1;
                                if (typeof index !== "undefined") {
                                    resolvedIndex = index;
                                } else if (flick && flick.model && flick.model.values) {
                                    var arr = flick.model.values;
                                    for (var i = 0; i < arr.length; ++i) {
                                        if (arr[i] === modelData || (arr[i].path && modelData.path && arr[i].path === modelData.path)) {
                                            resolvedIndex = i;
                                            break;
                                        }
                                    }
                                }
                                if (resolvedIndex >= 0) {
                                    flick.currentIndex = resolvedIndex;
                                } else {
                                    if (flick.currentItem && flick.currentItem.modelData === modelData)
                                        flick.currentIndex = flick.currentIndex;
                                }
                            }
                        }
                    }

                    onCurrentItemChanged: {
                        if (currentItem && currentItem.modelData) {
                            previewImage.source = Qt.resolvedUrl(currentItem.modelData.path);
                            previewColorPallete.model = currentItem.modelData.colors.slice(0, 19) || [];
                            // set repeater model to a unique list so no duplicates show
                            previewTagsRepeater.model = toplevel.uniqueTags(currentItem.modelData.tags || []);
                        } else {
                            previewImage.source = "";
                            previewColorPallete.model = [];
                            previewTagsRepeater.model = [];
                        }
                    }
                }
            }

            // Preview Panel
            Rectangle {
                id: previewPanel
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Scripts.setOpacity(Colors.background, 0.8)
                border.color: Scripts.setOpacity(Colors.colors10, 0.2)
                radius: 10

                Item {
                    anchors.fill: parent
                    // image preview
                    Rectangle {
                        id: previewCard
                        anchors.fill: parent
                        color: 'transparent'

                        Image {
                            id: previewImage
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            visible: false
                        }

                        Rectangle {
                            id: previewMask
                            anchors.fill: parent
                            radius: 8
                            clip: true
                            visible: false
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: previewImage
                            maskSource: previewMask
                            visible: previewCard.width <= 16384 && previewCard.height <= 16384
                        }
                    }

                    // preview description
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: parent.height / 6
                        color: Scripts.setOpacity(Colors.background, 0.8)

                        ColumnLayout {
                            id: previewWrapper
                            anchors.fill: parent

                            Flow {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                spacing: 10

                                Text {
                                    id: previewTag
                                    text: qsTr("Tags:")
                                    color: Colors.color10
                                    font.pixelSize: Math.max(10, Math.floor(parent.height * 0.45))
                                }

                                Repeater {
                                    id: previewTagsRepeater
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                    delegate: Text {
                                        text: qsTr(modelData)
                                        color: Colors.color10
                                        font.pixelSize: Math.max(10, Math.floor(parent.height * 0.45))
                                    }
                                }
                            }

                            RowLayout {
                                id: previewColorPalleteRow
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                spacing: 6
                                Item {
                                    Layout.fillWidth: true
                                }
                                Repeater {
                                    id: previewColorPallete
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                    model: flick.currentItem.modelData.colors.slice(0, 19)
                                    delegate: Rectangle {
                                        radius: 4
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: width
                                        color: modelData && modelData.color ? modelData.color : "transparent"
                                        visible: modelData && !!modelData.color
                                    }
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function uniqueTags(arr) {
        if (!arr)
            return [];
        var seen = {};
        var out = [];
        for (var i = 0; i < arr.length; ++i) {
            var t = arr[i];
            if (typeof t === "string") {
                t = t.replace(/^\s*rating:\s*/i, "").trim();
            }
            if (!t || seen[t])
                continue;
            seen[t] = true;
            out.push(t);
        }
        return out;
    }

    Connections {
        target: GlobalState

        function onShowWallpaperCarouselSignal(value, monitorName) {
            const isMatch = monitorName === screen.name;
            if (isMatch) {
                toplevel.shouldBeVisible = value;
            }
        }
    }
}
