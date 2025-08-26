// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

pragma ComponentBehavior: Bound

import QtQuick
import "calculator.js" as CalcEngine
import QtQuick.Layouts
import qs.services

Item {
    id: controller

    readonly property color qtGreenColor: Colors.color11
    readonly property color backspaceRedColor: Colors.color12
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
    }

    component OperatorButton: CalculatorButton {
        onReleased: {
            root.operatorPressed(text);
            updateDimmed();
        }
        textColor: Colors.color10
        implicitWidth: 72
        dimmable: true
    }

    Component.onCompleted: updateDimmed()

    Rectangle {
        id: numberPad
        anchors.fill: parent

        radius: 2
        color: "transparent"

        RowLayout {

            anchors.centerIn: parent
            GridLayout {
                id: scientificGrid
                columns: 3

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
                    implicitWidth: 72
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
                    implicitWidth: 72
                }
            }

            GridLayout {
                id: mainGrid
                columns: 5

                BackspaceButton {}
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
                    implicitWidth: 38
                }

                OperatorButton {
                    text: "AC"
                    textColor: controller.backspaceRedColor
                    accentColor: controller.backspaceRedColor
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
                    implicitWidth: 38
                }

                OperatorButton {
                    text: "="
                    implicitHeight: 81
                    Layout.rowSpan: 2
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
                    implicitWidth: 38
                }

                OperatorButton {
                    text: "±"
                    implicitWidth: 38
                }
                DigitButton {
                    text: "0"
                }
                DigitButton {
                    text: "."
                    dimmable: true
                }
                OperatorButton {
                    text: "+"
                    implicitWidth: 38
                }
            }
        }
    }
}
