import QtQuick

import qs.core

Item {
    id: navbar
    default property alias content: container.data
    property var configFile: Global.fileManager.find(function (s) {
        return s && s.subject === screen.name + "-navbar";
    })
    property QtObject config: configFile ? configFile.ref.adapter : null

    property bool side: config ? (config.position === "left" || config.position === "right") : false

    width: side ? (config ? config.width : 40) : parent.width
    height: !side ? (config ? config.height : 40) : parent.height

    Rectangle {
        id: container
        color: config && config.style ? config.style.color : 'transparent'

        border {
            width: config && config.style && config.style.border ? config.style.border.width : 0
            color: config && config.style && config.style.border ? config.style.border.color : 'transparent'
        }

        anchors {
            fill: parent
            topMargin: config && config.style && config.style.margin ? config.style.margin.top : 0
            bottomMargin: config && config.style && config.style.margin ? config.style.margin.bottom : 0
            leftMargin: config && config.style && config.style.margin ? config.style.margin.left : 0
            rightMargin: config && config.style && config.style.margin ? config.style.margin.right : 0
        }
    }

    // Instantiate
    DropArea {
        anchors.fill: parent
        onContainsDragChanged: {
            container.border.color = containsDrag ? "red" : Qt.rgba(0, 0, 0, 0.3);
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log(config ? config.style.color : "no config");
        }
    }
}
