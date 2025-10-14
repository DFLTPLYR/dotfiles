import QtQuick
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

    anchors {
        topMargin: 2
        leftMargin: 10
        rightMargin: 10
        left: parent.left
        right: parent.right
        top: parent.top
    }

    Item {
        id: contentHolder
        visible: false
    }

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: style === "neumorphic" ? neuStyle : glassStyle

        onLoaded: {
            if (item && item.childContainer && contentHolder.data.length > 0) {
                for (var i = 0; i < contentHolder.data.length; i++) {
                    contentHolder.data[i].parent = item.childContainer;
                }
            }
        }
    }

    Component {
        id: neuStyle
        NeumorphicStyle {}
    }

    Component {
        id: glassStyle
        GlassStyle {}
    }

    component NeumorphicStyle: Item {
        property alias childContainer: childContainer

        anchors {
            topMargin: 2
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Rectangle {
            width: childContainer.width - 10
            height: childContainer.height
            radius: 2
            color: Scripts.setOpacity(ColorPalette.background, 0.9)
            border.width: 1
            border.color: Scripts.setOpacity(ColorPalette.accent, 0.4)
        }

        Rectangle {
            id: childContainer
            x: 5
            y: 5
            radius: 2
            color: Scripts.setOpacity(ColorPalette.background, 0.8)
            height: 30
            border.width: 1
            border.color: Scripts.setOpacity(ColorPalette.accent, 0.6)
            width: root.childContainerWidth - 10
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
            id: childContainer
            radius: 2
            color: Scripts.setOpacity(ColorPalette.background, 0.5)
            height: 30
            border.width: 1
            border.color: Scripts.setOpacity(ColorPalette.color10, 0.4)
            width: root.childContainerWidth - 10
        }
    }
}
