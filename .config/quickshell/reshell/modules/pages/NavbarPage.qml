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
            id: testWidgets

            z: 10
            property int setHeight: 100
            property int setWidth: 100
            property int relativeX: 0
            property int relativeY: 0

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

            MouseArea {
                id: ma
                anchors.fill: parent
                drag.target: testWidgets
                drag.axis: Drag.XAndYAxis
                onReleased: {
                    const dropArea = testWidgets.Drag.target;
                    testWidgets.Drag.drop();
                    if (dropArea) {
                        testWidgets.parent = dropArea.slot;
                    } else {
                        testWidgets.parent = origparent;
                        testWidgets.x = 0;
                        testWidgets.y = 0;
                        testWidgets.width = origparent.width;
                        testWidgets.height = origparent.height;
                    }
                }
            }
        }
    }
}
