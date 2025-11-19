import QtQuick

import qs.config

Item {
    id: root

    property Item contentItem: main //main, background, intersection
    default property alias content: contentItem.data

    property StyledConfig mainconfig: StyledConfig {}
    property StyledConfig backgroundconfig: StyledConfig {}
    property StyledConfig intersectionconfig: StyledConfig {}

    function setContentItem(newParent) {
        if (newParent !== main && newParent !== background && newParent !== intersection) {
            console.warn("setContentItem: invalid target:", newParent);
            return;
        }

        root.contentItem = newParent;
    }

    Rectangle {
        id: main
        color: root.mainconfig.color

        anchors {
            margins: root.mainconfig.anchors.margins
            leftMargin: root.mainconfig.anchors.leftMargin
            rightMargin: root.mainconfig.anchors.rightMargin
            topMargin: root.mainconfig.anchors.topMargin
            bottomMargin: root.mainconfig.anchors.bottomMargin
        }
        Component.onCompleted: {
            root.applyConfig(main, root.mainconfig.anchors);
        }
    }

    Rectangle {
        id: background
        color: root.backgroundconfig.color
        anchors {
            margins: root.backgroundconfig.anchors.margins
            leftMargin: root.backgroundconfig.anchors.leftMargin
            rightMargin: root.backgroundconfig.anchors.rightMargin
            topMargin: root.backgroundconfig.anchors.topMargin
            bottomMargin: root.backgroundconfig.anchors.bottomMargin
        }
        Component.onCompleted: {
            root.applyConfig(background, root.backgroundconfig.anchors);
        }
    }

    Rectangle {
        id: intersection
        color: root.intersectionconfig.color
        anchors {
            margins: root.intersectionconfig.anchors.margins
            leftMargin: root.intersectionconfig.anchors.leftMargin
            rightMargin: root.intersectionconfig.anchors.rightMargin
            topMargin: root.intersectionconfig.anchors.topMargin
            bottomMargin: root.intersectionconfig.anchors.bottomMargin
        }
        Component.onCompleted: {
            root.applyConfig(intersection, root.intersectionconfig.anchors);
        }
    }

    function clearAnchors(item) {
        const anchor = item.anchors;
        anchor.fill = undefined;
        anchor.left = undefined;
        anchor.right = undefined;
        anchor.top = undefined;
        anchor.bottom = undefined;
        anchor.horizontalCenter = undefined;
        anchor.horizontalCenter = undefined;
    }

    function applyConfig(item, cfg) {
        root.clearAnchors(item);

        if (cfg.fill) {
            item.anchors.fill = cfg.fill;
            return;
        }

        if (cfg.left)
            item.anchors.left = cfg.left;
        if (cfg.right)
            item.anchors.right = cfg.right;
        if (cfg.top)
            item.anchors.top = cfg.top;
        if (cfg.bottom)
            item.anchors.bottom = cfg.bottom;
        if (cfg.horizontalCenter)
            item.anchors.horizontalCenter = cfg.horizontalCenter;
        if (cfg.verticalCenter)
            item.anchors.verticalCenter = cfg.verticalCenter;
    }
}
