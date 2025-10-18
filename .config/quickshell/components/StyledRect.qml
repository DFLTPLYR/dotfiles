pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import qs.assets
import qs.utils

Item {
    id: root

    // These properties will be used to connect to the loaded component
    property var styleLoader: loader
    property var innerContainer: loader.item ? loader.item.childContainer : null

    default property alias content: contentHolder.data
    property real childContainerHeight: innerContainer ? innerContainer.height : 30
    property real childContainerWidth: width
    property string style: "neumorphic"

    layer.enabled: true
    width: parent.width
    implicitHeight: childContainerHeight + 10

    FileView {
        id: settingsWatcher
        path: Qt.resolvedUrl("../settings.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
            root.style = settings.theme || "neumorphic";
        }
        onLoadFailed: {
            console.log("Failed to load settings");
        }
    }

    Item {
        id: contentHolder
        visible: false
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            if (item && (item as Item).childContainer && contentHolder.data.length > 0) {
                var cc = (item as Item).childContainer;
                for (var i = contentHolder.data.length - 1; i >= 0; i--) {
                    contentHolder.data[i].parent = cc;
                }
            }
        }
    }

    onStyleChanged: {
        var prevCC = loader.item && loader.item.childContainer;
        if (prevCC && prevCC.children.length > 0) {
            for (var i = prevCC.children.length - 1; i >= 0; i--) {
                prevCC.children[i].parent = contentHolder;
            }
        }
        loader.active = false;
        setLoaderSourceFromStyle();
        loader.active = true;
    }

    function setLoaderSourceFromStyle() {
        switch (style) {
        case "neumorphic":
            loader.sourceComponent = neuStyle;
            break;
        case "glass":
            loader.sourceComponent = glassStyle;
            break;
        case "brutalist":
            loader.sourceComponent = brutalistStyle;
            break;
        // Add more cases here for future styles
        default:
            loader.sourceComponent = defaultStyle;
        }
    }

    // Components
    Component {
        id: neuStyle
        NeumorphicStyle {}
    }

    Component {
        id: glassStyle
        GlassStyle {}
    }

    Component {
        id: brutalistStyle
        BrutalistStyle {}
    }

    Component {
        id: defaultStyle
        DefaultStyle {}
    }

    component NeumorphicStyle: Item {
        property alias childContainer: childContainer

        anchors {
            topMargin: 5
            top: parent.top
        }

        Rectangle {
            id: childContainer
            radius: 2
            color: Scripts.setOpacity(ColorPalette.background, 0.8)
            height: parent.height - 15
            border.width: 1
            border.color: Scripts.setOpacity(ColorPalette.background, 0.8)
            width: root.width - 10
            layer.enabled: true
            layer.effect: DropShadow {
                color: Scripts.setOpacity(ColorPalette.background, 0.8)

                transparentBorder: false
                horizontalOffset: 8
                verticalOffset: 8
            }
        }
    }

    component GlassStyle: Item {
        property alias childContainer: childContainer

        anchors {
            topMargin: 5
            leftMargin: 5
            rightMargin: 5
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0.33, 0.33, 0.41, 0.2)
        }

        Rectangle {
            id: childContainer
            radius: 2
            color: Scripts.setOpacity(ColorPalette.background, 0.5)
            height: parent.height - 10
            border.width: 1
            border.color: Scripts.setOpacity(ColorPalette.color10, 0.4)
            width: root.width - 10
        }
    }

    component BrutalistStyle: Item {
        property alias childContainer: childContainer
        Rectangle {
            id: childContainer
            radius: 0
            color: ColorPalette.background
            height: parent.height - 10
            border.width: 2
            border.color: ColorPalette.color1
            width: root.width - 10
        }
    }

    component DefaultStyle: Item {
        property alias childContainer: childContainer
        Rectangle {
            id: childContainer
            radius: 2
            color: Scripts.setOpacity(ColorPalette.background, 0.5)
            height: parent.height - 10
            border.width: 1
            border.color: Scripts.setOpacity(ColorPalette.color10, 0.4)
            width: root.width - 10
        }
    }

    Component.onCompleted: {
        setLoaderSourceFromStyle();
    }
}
