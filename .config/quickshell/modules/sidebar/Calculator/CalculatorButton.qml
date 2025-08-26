// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import qs.services
import qs.utils

RoundButton {
    id: button
    radius: buttonRadius

    property bool dimmable: false
    property bool dimmed: false
    readonly property int fontSize: 22
    readonly property int buttonRadius: 8
    property color textColor: Colors.color12
    property color accentColor: Colors.color10
    readonly property color backgroundColor: 'transparent'
    readonly property color borderColor: Colors.color10

    function getBackgroundColor() {
        if (button.dimmable && button.dimmed)
            return backgroundColor;
        if (button.pressed)
            return accentColor;
        return backgroundColor;
    }

    function getBorderColor() {
        if (button.dimmable && button.dimmed)
            return borderColor;
        if (button.pressed || button.hovered)
            return accentColor;
        return borderColor;
    }

    function getTextColor() {
        if (button.dimmable && button.dimmed)
            return Qt.darker(textColor);
        if (button.pressed)
            return backgroundColor;
        if (button.hovered)
            return accentColor;
        return textColor;
    }

    background: Rectangle {
        radius: button.buttonRadius
        color: getBackgroundColor()
        border.color: getBorderColor()
    }

    contentItem: Text {
        text: button.text
        font.pixelSize: button.fontSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: getTextColor()

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutElastic
            }
        }
    }
}
