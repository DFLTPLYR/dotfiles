// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

RoundButton {
    id: button
    implicitWidth: 48
    implicitHeight: 38
    radius: buttonRadius
    icon.source: getIcon()
    icon.width: 38
    icon.height: 38
    icon.color: getIconColor()
    text: "bs"

    property bool dimmable: true
    property bool dimmed: false
    readonly property color backgroundColor: "#222222"
    readonly property color borderColor: "#A9A9A9"
    readonly property color backspaceRedColor: "#DE2C2C"
    readonly property int buttonRadius: 8

    function getBackgroundColor() {
        if (button.dimmable && button.dimmed)
            return backgroundColor;
        if (button.pressed)
            return backspaceRedColor;
        return backgroundColor;
    }

    function getBorderColor() {
        if (button.dimmable && button.dimmed)
            return borderColor;
        if (button.pressed || button.hovered)
            return backspaceRedColor;
        return borderColor;
    }

    function getIconColor() {
        if (button.dimmable && button.dimmed)
            return Qt.darker(backspaceRedColor);
        if (button.pressed)
            return backgroundColor;
        return backspaceRedColor;
    }

    function getIcon() {
        if (button.dimmable && button.dimmed)
            return "backspace.svg";
        if (button.pressed)
            return "backspace_fill.svg";
        return "backspace.svg";
    }

    onReleased: {
        root.operatorPressed("bs");
        updateDimmed();
    }

    background: Rectangle {
        radius: button.buttonRadius
        color: getBackgroundColor()
        border.color: getBorderColor()
    }
}
