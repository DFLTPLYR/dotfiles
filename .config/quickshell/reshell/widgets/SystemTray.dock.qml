pragma NativeMethodBehavior: AcceptThisObject
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

import qs.core
import qs.types
import qs.components

Wrapper {
    id: wrap
    clip: true

    property: Property {
        property int radius: 0
        property bool showText: false
    }

    width: wrap.setWidth(list.contentWidth)
    height: wrap.setHeight(list.contentHeight)

    ListView {
        id: list

        width: wrap.slotConfig ? (wrap.slotConfig.side ? wrap.width : list.contentWidth) : (wrap.parent ? wrap.parent.width : 0)
        height: wrap.slotConfig ? (wrap.slotConfig.side ? list.contentHeight : wrap.height) : (wrap.parent ? wrap.parent.height : 0)

        orientation: wrap.slotConfig ? (wrap.slotConfig.side ? ListView.Vertical : ListView.Horizontal) : ListView.Horizontal
        interactive: false

        model: SystemTray.items
        delegate: Image {
            id: trayItem
            required property SystemTrayItem modelData
            width: (wrap.slotConfig?.side) ? (wrap.parent?.width || 0) : height
            height: (wrap.slotConfig?.side) ? width : (wrap.parent?.height || 0)
            source: trayItem.modelData.icon

            MouseArea {
                id: trayMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    const actions = trayItem.modelData;
                    switch (mouse.button) {
                    case Qt.LeftButton:
                        traymenu.open();
                        actions.activate();
                    case Qt.MiddleButton:
                        actions.secondaryActivate();
                    case Qt.RightButton:
                        return;
                    default:
                        return;
                    }
                }
            }

            QsMenuOpener {
                id: traymenuItems
                menu: trayItem.modelData.menu
            }
            Instantiator {
                model: traymenuItems.children
                delegate: Action {
                    required property var modelData
                    text: modelData.text
                }
                onObjectAdded: (idx, obj) => {
                    traymenu.insertAction(idx, obj);
                }
            }

            Menu {
                id: traymenu
            }
        }
    }
}
