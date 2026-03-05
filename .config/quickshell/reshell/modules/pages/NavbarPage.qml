import QtQuick
import QtQuick.Layouts

import QtQml.Models

import qs.components
import qs.core

ColumnLayout {
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

    DelegateModel {
        id: widgetModel
        model: ["clock", "bar", "other"]
    }

    Rectangle {
        id: testWidgets
        property int setHeight: 100
        property int setWidth: 100

        width: 40
        height: 40

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
                }
            }
        }
    }
}
