import QtQuick

import qs.config

Item {
    id: root
    property StyledConfig mainconfig: StyledConfig {}

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
    }

    Rectangle {
        id: intersection
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
