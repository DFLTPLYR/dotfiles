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

                width: Math.max(1, targetWidth * animProgress)
                height: Math.max(1, targetHeight * animProgress)

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

                contentWidth: masonryContent.width
                contentHeight: height
                clip: true

                // Enable interactive scrolling
                flickableDirection: Flickable.HorizontalFlick
                interactive: contentWidth > width
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 1500
                maximumFlickVelocity: 2500

                // Auto-scroll properties
                property real lastPosition: 0
                property bool autoScrolling: true
                property var scrollAnimationObject: null
                property bool scrollForward: true
                property real edgeEpsilon: 1.0
                property real baseScrollSpeed: 20000

                // Initialize animation on completion
                Component.onCompleted: startScrollAnimation()

                function startScrollAnimation() {
                    if (scrollAnimationObject) {
                        scrollAnimationObject.stop();
                    }

                    // Nothing to scroll
                    if (contentWidth <= width)
                        return;

                    // Clamp current position to valid range
                    const maxX = Math.max(0, contentWidth - width);
                    contentX = Math.min(Math.max(contentX, 0), maxX);

                    // Decide direction when we're at an edge
                    const atEnd = Math.abs(contentX - maxX) <= edgeEpsilon;
                    const atStart = contentX <= edgeEpsilon;

                    if (atEnd)
                        scrollForward = false;
                    if (atStart)
                        scrollForward = true;

                    const fromX = contentX;
                    const toX = scrollForward ? maxX : 0;

                    const distance = Math.max(1, Math.abs(toX - fromX));
                    const duration = baseScrollSpeed * (distance / 1000);

                    scrollAnimationObject = scrollAnimationComponent.createObject(tickerView, {
                        from: fromX,
                        to: toX,
                        duration: duration
                    });

                    if (autoScrolling && visible) {
                        scrollAnimationObject.start();
                    }
                }

                // Animation component
                Component {
                    id: scrollAnimationComponent

                    NumberAnimation {
                        target: tickerView
                        property: "contentX"
                        loops: 1
                        running: false
                        onStopped: {
                            tickerView.lastPosition = tickerView.contentX;
                            if (tickerView.autoScrolling && tickerView.visible && tickerView.contentWidth > tickerView.width) {
                                tickerView.startScrollAnimation();
                            }
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
                    lastPosition = contentX;
                    resumeTimer.restart();
                }

                onFlickEnded: lastPosition = contentX
                onContentXChanged: if (!autoScrolling)
                    lastPosition = contentX

                Timer {
                    id: resumeTimer
                    interval: 1000
                    repeat: false
                    onTriggered: {
                        tickerView.autoScrolling = true;
                        tickerView.startScrollAnimation();
                    }
                }

                // Masonry content container
                Item {
                    id: masonryContent
                    width: Math.max(childrenRect.width + 20, tickerView.width)
                    height: tickerView.height

                    // Spacing between rows and items
                    property int spacing: 8
                    // Fixed item height per row (tune this)
                    property int rowHeight: 20
                    // How many rows can fit vertically, given rowHeight + spacing
                    property int rowCount: Math.max(1, Math.floor((height + spacing) / (rowHeight + spacing)))

                    // Will be (rowCount)-sized
                    property var rowWidths: []
                    property var rowItems: []

                    function resetRows() {
                        rowWidths = Array(rowCount).fill(0);
                        rowItems = [];
                        for (let r = 0; r < rowCount; r++)
                            rowItems.push([]);
                    }

                    // Layout function - call after model or size changes
                    function layoutItems() {
                        resetRows();

                        for (let i = 0; i < repeater.count; i++) {
                            const item = repeater.itemAt(i);
                            if (!item)
                                continue;

                            // Find row with minimum width so far
                            let minRow = 0;
                            let minWidth = rowWidths[0];
                            for (let r = 1; r < rowCount; r++) {
                                if (rowWidths[r] < minWidth) {
                                    minRow = r;
                                    minWidth = rowWidths[r];
                                }
                            }

                            // Position item
                            item.height = rowHeight;
                            item.y = minRow * (rowHeight + spacing);
                            item.x = rowWidths[minRow];

                            // Advance width for that row
                            rowWidths[minRow] += item.width + spacing;
                            rowItems[minRow].push(item);
                        }
                    }

                    // Re-layout on size/row changes
                    onHeightChanged: Qt.callLater(layoutItems)
                    onRowHeightChanged: Qt.callLater(layoutItems)
                    onRowCountChanged: Qt.callLater(layoutItems)

                    // Masonry item repeater
                    Repeater {
                        id: repeater
                        model: toplevel.isPortrait ? WallpaperStore.portraitTags : WallpaperStore.landscapeTags

                        delegate: Item {
                            id: tagItem
                            width: wordText.width + 40

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

                            // Trigger layout after all items are created
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
