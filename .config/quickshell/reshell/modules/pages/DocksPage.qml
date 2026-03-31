import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

Page {
    ColumnLayout {
        width: parent.width

        Label {
            font.pixelSize: 32
            text: "Docks"
        }

        ListView {
            height: contentHeight
            model: ScriptModel {
                values: [...Global.docks]
            }
            delegate: Button {
                text: modelData.objectName
                onClicked: Global.dockpanel = modelData
            }
        }

        Button {
            text: "add Dock"
            onClicked: {
                config.docks.push({
                    name: Math.random().toString(36).substring(2, 10)
                });
            }
        }
    }
}
