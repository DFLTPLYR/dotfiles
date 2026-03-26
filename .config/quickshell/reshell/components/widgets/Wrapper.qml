import QtQuick
import qs.core

Rectangle {
    id: widget
    property Item origparent
    property bool dynamicsize: false
    property int setHeight: 100
    property int setWidth: 100
    property int relativeX: 0
    property int relativeY: 0
    property int position: -1
    property bool active: Global.enableSetting
    property bool side: false

    Connections {
        target: Compositor
        function onReadyChanged() {
            const config = Global.getConfigManager(`${Compositor.focusedMonitor}-navbar`).adapter;
            widget.side = config.side;

            config.onSideChanged.connect(() => {
                widget.side = config.side;
            });
        }
    }

    clip: true
    color: "transparent"

    implicitWidth: parent ? parent.width : 0
    implicitHeight: parent ? parent.height : 0

    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Drag.active: ma.drag.active

    Drag.hotSpot.x: width * 0.6
    Drag.hotSpot.y: height * 0.6
    Drag.keys: ["widget", widget.position]

    MouseArea {
        id: ma
        visible: widget.active
        anchors.fill: parent
        drag.target: widget
        drag.axis: Drag.XAndYAxis
        onReleased: {
            const dropArea = widget.Drag.target;
            widget.Drag.drop();
            if (!dropArea) {
                if (origparent) {
                    widget.parent = origparent;
                    widget.x = 0;
                    widget.y = 0;
                    widget.width = origparent.width;
                    widget.height = origparent.height;
                }
                widget.position = -1;

                const config = Global.getConfigManager(`${Compositor.focusedMonitor}-navbar`).adapter;
                const index = config.widgets.findIndex(s => s.name === widget.objectName);

                if (index !== -1) {
                    config.widgets.splice(index, 1);
                }
            }
        }
    }
}
