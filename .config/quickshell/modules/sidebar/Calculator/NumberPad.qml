// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

pragma ComponentBehavior: Bound

import QtQuick
import "calculator.js" as CalcEngine
import QtQuick.Layouts
import qs.services
import qs.assets

Item {
    id: controller

    readonly property color qtGreenColor: Assets.color11
    readonly property color backspaceRedColor: Assets.color12
    readonly property int spacing: 5

    property int portraitModeWidth: mainGrid.width
    property int landscapeModeWidth: scientificGrid.width + mainGrid.width

    function updateDimmed() {
        for (let i = 0; i < mainGrid.children.length; i++) {
            mainGrid.children[i].dimmed = root.isButtonDisabled(mainGrid.children[i].text);
        }
        for (let j = 0; j < scientificGrid.children.length; j++) {
            scientificGrid.children[j].dimmed = root.isButtonDisabled(scientificGrid.children[j].text);
        }
    }

    component DigitButton: CalculatorButton {
        onReleased: {
            root.digitPressed(text);
            updateDimmed();
        }
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: mainGrid.widthPerCol
    }

    component OperatorButton: CalculatorButton {
        onReleased: {
            root.operatorPressed(text);
            updateDimmed();
        }
        textColor: Assets.color10
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: mainGrid.widthPerCol
        dimmable: true
    }

    Component.onCompleted: updateDimmed()

    RowLayout {
        anchors.fill: parent

        GridLayout {
            id: scientificGrid
            columns: 3
            visible: false

            OperatorButton {
                text: "x²"
            }
            OperatorButton {
                text: "⅟x"
            }
            OperatorButton {
                text: "√"
            }
            OperatorButton {
                text: "x³"
            }
            OperatorButton {
                text: "sin"
            }
            OperatorButton {
                text: "|x|"
            }
            OperatorButton {
                text: "log"
            }
            OperatorButton {
                text: "cos"
            }
            DigitButton {
                text: "e"
                dimmable: true
            }
            OperatorButton {
                text: "ln"
            }
            OperatorButton {
                text: "tan"
            }
            DigitButton {
                text: "π"
                dimmable: true
            }
        }

        GridLayout {
            id: mainGrid
            columns: 5

            Layout.fillHeight: true
            Layout.fillWidth: true

            rowSpacing: 8
            columnSpacing: 8

            property int widthPerCol: mainGrid.width / 5

            BackspaceButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            DigitButton {
                text: "7"
            }
            DigitButton {
                text: "8"
            }
            DigitButton {
                text: "9"
            }
            OperatorButton {
                text: "÷"
            }

            OperatorButton {
                text: "AC"
            }
            DigitButton {
                text: "4"
            }
            DigitButton {
                text: "5"
            }
            DigitButton {
                text: "6"
            }
            OperatorButton {
                text: "×"
            }

            OperatorButton {
                text: "="
                Layout.rowSpan: 2
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            DigitButton {
                text: "1"
            }
            DigitButton {
                text: "2"
            }
            DigitButton {
                text: "3"
            }
            OperatorButton {
                text: "−"
            }

            OperatorButton {
                text: "±"
            }
            DigitButton {
                text: "0"
            }
            DigitButton {
                text: "."
                dimmable: true
                textColor: Assets.color10
            }
            OperatorButton {
                text: "+"
            }
        }
    }
}
