import QtQuick
import QtQuick.Layouts

import QtQml.Models

import qs.components
import qs.core

ColumnLayout {
    id: navbarpage
    required property var settings
    property bool side: settings ? (settings.position === "left" || settings.position === "right") : false

    Layout.fillWidth: true
    Layout.fillHeight: true

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: "Anchor Positions"
        }

        Repeater {
            id: positions
            model: ["left", "top", "right", "bottom"]
            delegate: Button {
                required property string modelData
                text: modelData
                onClicked: {
                    settings.position = modelData;
                }
            }
        }
    }

    FlexboxLayout {
        id: widgetContainer
        Layout.fillWidth: true
        Layout.fillHeight: true

        Instantiator {
            model: ["clock", "bar", "other"]
            delegate: WidgetWrapper {}
            onObjectAdded: (idx, obj) => {
                obj.parent = widgetContainer;
            }
        }
    }

    Column {
        id: column

        Layout.fillWidth: true
        Layout.fillHeight: true

        function comparePosition(a, b) {
            return a.position - b.position;
        }
        function arrange(array) {
            return array.sort(comparePosition);
        }

        Button {
            text: "shuffle"
            onClicked: {
                var array = column.children.filter(function (child) {
                    return child.hasOwnProperty('position');
                });
                for (var a in array) {
                    array[a].parent = null;
                }
                array = column.arrange(array);
                for (var a in array) {
                    array[a].parent = column;
                }
            }
        }

        Button {
            id: button3
            property int position: 3
            text: "I am button 3"
        }
        Button {
            id: button2
            property int position: 2
            text: "I am button 2 "
        }

        Button {
            id: button1
            property int position: 1
            text: "I am button 1"
        }
    }
    component WidgetWrapper: Rectangle {
        id: origparent
        width: 40
        height: 40
        color: Colors.setOpacity(Colors.color.background, 0.2)

        border {
            width: 1
            color: Colors.color.outline
        }

        Rectangle {
            id: widget

            z: 10
            property int setHeight: 100
            property int setWidth: 100
            property int relativeX: 0
            property int relativeY: 0
            property int position: -1
            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)
            width: parent ? parent.width : 0
            height: parent ? parent.height : 0

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
                anchors.fill: parent
                drag.target: widget
                drag.axis: Drag.XAndYAxis
                onReleased: {
                    const dropArea = widget.Drag.target;
                    widget.Drag.drop();
                    if (!dropArea) {
                        widget.parent = origparent;
                        widget.x = 0;
                        widget.y = 0;
                        widget.width = origparent.width;
                        widget.height = origparent.height;
                        widget.position = -1;
                        return;
                    }
                }
            }
        }
    }
}
