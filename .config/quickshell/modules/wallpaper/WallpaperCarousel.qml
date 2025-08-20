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

    onClicked: {
        return;
    }

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
                    console.log(JSON.stringify(currentItem.modelData));
                }

                event.accepted = true;
                break;
            case Qt.Key_Left:
            case Qt.Key_Down:
                if (flick.currentIndex > 0)
                    flick.currentIndex -= 1;
                event.accepted = true;
                break;
            case Qt.Key_Up:
            case Qt.Key_Right:
                if (flick.currentIndex < flick.count - 1)
                    flick.currentIndex += 1;
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
    property real targetWidth: isPortrait ? screen.width * 0.9 : screen.width * 0.6
    property real targetHeight: screen.height * 0.5

    ColumnLayout {
        id: myLayout

        x: Math.round(screen.width / 2 - width / 2)
        y: Math.round(screen.height / 2 - height / 2)

        spacing: 8

        // Colors
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.max(1, targetWidth * animProgress)
            Layout.preferredHeight: Math.max(1, (targetHeight / 2) * animProgress)

            scale: animProgress
            opacity: animProgress
            radius: 10
            transformOrigin: Item.Center
            color: Scripts.hexToRgba(Colors.background, 0.2)
            border.color: Scripts.hexToRgba(Colors.colors10, 0.2)

            GridView {
                id: topTagList
                anchors.fill: parent

                clip: true
                property var perRow: 20
                // Grid properties
                cellWidth: Math.floor(parent.width / perRow)
                cellHeight: Math.floor(parent.width / perRow)

                flow: GridView.LeftToRight

                model: (toplevel.isPortrait ? WallpaperStore.portraitColors.slice() : WallpaperStore.landscapeColors.slice()).reverse()

                delegate: Rectangle {
                    id: wrapper
                    width: topTagList.cellWidth
                    height: topTagList.cellHeight
                    radius: 12
                    color: 'transparent'

                    Rectangle {
                        id: container
                        anchors.centerIn: wrapper
                        width: topTagList.cellWidth * 0.8
                        height: width

                        radius: 10

                        property bool isSelected: {
                            if (toplevel.colorFilter) {
                                for (var i = 0; i < toplevel.colorFilter.length; i++) {
                                    if (toplevel.colorFilter[i] === modelData.color)
                                        return true;
                                }
                            }
                            return false;
                        }

                        color: isSelected ? Colors.color10 : Scripts.hexToRgba(Colors.background, 0.4)

                        border.color: isSelected ? Colors.foreground : Scripts.hexToRgba(Colors.colors12, 0.7)

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            // Color preview circle
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: wrapper.height / 2
                                height: width
                                radius: width / 2
                                color: modelData.color
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (container.isSelected) {
                                    for (var i = 0; i < toplevel.colorFilter.length; i++) {
                                        if (toplevel.colorFilter[i] === modelData.color) {
                                            toplevel.colorFilter.splice(i, 1);
                                            break;
                                        }
                                    }
                                } else {
                                    toplevel.colorFilter.push(modelData.color);
                                }
                                toplevel.colorFilter = toplevel.colorFilter.slice();
                            }
                        }
                    }
                }
            }
        }

        // Carousel
        Rectangle {
            id: morphBox
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.max(1, targetWidth * animProgress)
            Layout.preferredHeight: Math.max(1, targetHeight * animProgress)

            scale: animProgress
            opacity: animProgress
            radius: 10
            transformOrigin: Item.Center
            color: Scripts.hexToRgba(Colors.background, 0.2)
            border.color: Scripts.hexToRgba(Colors.colors10, 0.2)

            ListContent {
                id: flick
                width: morphBox.width
                height: morphBox.height
                visible: animProgress > 0
                opacity: animProgress
                searchText: toplevel.searchValue
                colorsFilter: toplevel.colorFilter
                tagsFilter: toplevel.tagFilter
            }
        }

        // Tags
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.max(1, targetWidth * animProgress)
            Layout.preferredHeight: Math.max(1, (targetHeight / 4) * animProgress)

            scale: animProgress
            opacity: animProgress
            radius: 10
            transformOrigin: Item.Center
            color: Scripts.hexToRgba(Colors.background, 0.2)
            border.color: Scripts.hexToRgba(Colors.colors10, 0.2)

            Flickable {
                id: tickerView
                anchors.fill: parent
                anchors.margins: 10
                contentWidth: masonryContent.width
                contentHeight: height
                clip: true

                // Enable interactive scrolling
                interactive: true
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 1500
                maximumFlickVelocity: 2500

                // Auto-scroll properties
                property real lastPosition: 0
                property bool autoScrolling: true
                property var scrollAnimationObject: null

                // Initialize animation on completion
                Component.onCompleted: {
                    startScrollAnimation();
                }

                function startScrollAnimation() {
                    if (scrollAnimationObject) {
                        scrollAnimationObject.stop();
                    }

                    // Fix potential negative duration with Math.max
                    const duration = 20000 * (Math.max(1, contentWidth - lastPosition) / 1000);

                    // Create animation dynamically
                    scrollAnimationObject = scrollAnimationComponent.createObject(tickerView, {
                        from: lastPosition,
                        to: Math.max(contentWidth - width, 0),
                        duration: duration
                    });

                    if (autoScrolling && visible && contentWidth > width) {
                        scrollAnimationObject.start();
                    }
                }

                // Animation component
                Component {
                    id: scrollAnimationComponent

                    NumberAnimation {
                        target: tickerView
                        property: "contentX"
                        loops: Animation.Infinite
                        running: false
                        onStopped: {
                            tickerView.lastPosition = tickerView.contentX;
                        }
                    }
                }

                // Pause auto-scroll when user interacts with the list
                onMovementStarted: {
                    autoScrolling = false;
                    if (scrollAnimationObject) {
                        lastPosition = contentX;
                        scrollAnimationObject.stop();
                    }
                }

                // Resume auto-scroll after user stops interacting
                onMovementEnded: {
                    resumeTimer.restart();
                }

                Timer {
                    id: resumeTimer
                    interval: 5000
                    onTriggered: {
                        tickerView.autoScrolling = true;
                        tickerView.startScrollAnimation();
                    }
                }

                // Masonry content container
                Item {
                    id: masonryContent
                    width: childrenRect.width + 20
                    height: tickerView.height
                    // Masonry layout properties
                    property int rowCount: 5
                    property int rowHeight: 50
                    property var rowWidths: [0, 0, 0, 0]
                    property var rowItems: [[], [], [], []]

                    // Layout function - call after model changes
                    function layoutItems() {

                        // Place each item in the row with the least width so far
                        for (let i = 0; i < repeater.count; i++) {
                            const item = repeater.itemAt(i);
                            if (!item)
                                continue;

                            // Find row with minimum width
                            let minRow = 0;
                            let minWidth = rowWidths[0];

                            for (let r = 1; r < rowCount; r++) {
                                if (rowWidths[r] < minWidth) {
                                    minRow = r;
                                    minWidth = rowWidths[r];
                                }
                            }

                            // Position item in this row
                            item.y = minRow * (rowHeight);
                            item.x = rowWidths[minRow];

                            // Update row width
                            rowWidths[minRow] += item.width + 8;
                            rowItems[minRow].push(item);
                        }
                    }

                    // Masonry item repeater
                    Repeater {
                        id: repeater
                        model: toplevel.isPortrait ? WallpaperStore.portraitTags : WallpaperStore.landscapeTags

                        delegate: Item {
                            id: tagItem
                            width: wordText.width + 40
                            height: masonryContent.rowHeight

                            Text {
                                id: wordText
                                text: modelData
                                color: Colors.color15
                                font.pixelSize: 20
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    searchValue = modelData;
                                    showSearchInput = true;
                                    searchTimer.restart();
                                }
                            }

                            // Layout when ready
                            Component.onCompleted: {
                                if (index === repeater.count - 1) {
                                    Qt.callLater(masonryContent.layoutItems);
                                }
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
        }
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
