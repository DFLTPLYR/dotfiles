// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import "calculator.js" as CalcEngine

import qs.services
import qs.utils

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    readonly property int margin: 18
    readonly property color backgroundColor: "#222222"
    readonly property int minLandscapeModeWidth: numberPad.landscapeModeWidth + display.minWidth + margin * 3
    property bool isPortraitMode: width < minLandscapeModeWidth

    Display {
        id: display
        backgroundColor: Scripts.setOpacity(Colors.background, 0.9)
        qtGreenColor: Scripts.setOpacity(Colors.color12, 0.9)
        Layout.margins: 10
    }

    NumberPad {
        id: numberPad
        Layout.margins: 10
        Layout.alignment: Qt.AlignHCenter
    }

    // define the responsive layouts
    ColumnLayout {
        id: portraitMode
        anchors.fill: parent
        visible: true

        LayoutItemProxy {
            target: display
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        LayoutItemProxy {
            target: numberPad
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    RowLayout {
        id: landscapeMode
        anchors.fill: parent
        visible: false

        LayoutItemProxy {
            target: display
        }
        LayoutItemProxy {
            target: numberPad
            Layout.alignment: Qt.AlignVCenter
        }
    }

    function operatorPressed(operator) {
        CalcEngine.operatorPressed(operator, display);
    }
    function digitPressed(digit) {
        CalcEngine.digitPressed(digit, display);
    }
    function isButtonDisabled(op) {
        return CalcEngine.isOperationDisabled(op, display);
    }

    Keys.onPressed: function (event) {
        switch (event.key) {
        case Qt.Key_0:
            digitPressed("0");
            break;
        case Qt.Key_1:
            digitPressed("1");
            break;
        case Qt.Key_2:
            digitPressed("2");
            break;
        case Qt.Key_3:
            digitPressed("3");
            break;
        case Qt.Key_4:
            digitPressed("4");
            break;
        case Qt.Key_5:
            digitPressed("5");
            break;
        case Qt.Key_6:
            digitPressed("6");
            break;
        case Qt.Key_7:
            digitPressed("7");
            break;
        case Qt.Key_8:
            digitPressed("8");
            break;
        case Qt.Key_9:
            digitPressed("9");
            break;
        case Qt.Key_E:
            digitPressed("e");
            break;
        case Qt.Key_P:
            digitPressed("π");
            break;
        case Qt.Key_Plus:
            operatorPressed("+");
            break;
        case Qt.Key_Minus:
            operatorPressed("-");
            break;
        case Qt.Key_Asterisk:
            operatorPressed("×");
            break;
        case Qt.Key_Slash:
            operatorPressed("÷");
            break;
        case Qt.Key_Enter:
        case Qt.Key_Return:
            operatorPressed("=");
            break;
        case Qt.Key_Comma:
        case Qt.Key_Period:
            digitPressed(".");
            break;
        case Qt.Key_Backspace:
            operatorPressed("bs");
            break;
        }
    }
}
