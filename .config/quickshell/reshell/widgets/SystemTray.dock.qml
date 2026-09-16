pragma NativeMethodBehavior: AcceptThisObject
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import QtQml.Models

import qs.types
import qs.components

Wrapper {
    id: wrap
    clip: true

    property: Property {
        property int icon: 24
    }

    width: wrap.setWidth(list.contentWidth)
    height: wrap.setHeight(list.contentHeight)

    property QtObject focused: QtObject {
        property var item: null
        property var menu: null
    }

    onClicked: mouse => {
        const actions = wrap.focused;

        switch (mouse.button) {
        case Qt.LeftButton:
            actions.item.activate();
            return;
        case Qt.MiddleButton:
            actions.item.secondaryActivate();
            return;
        case Qt.RightButton:
            actions.menu.open();
            return;
        default:
            return;
        }
    }

    ListView {
        id: list

        width: wrap.slotConfig ? (wrap.slotConfig.side ? wrap.width : list.contentWidth) : (wrap.parent ? wrap.parent.width : 0)
        height: wrap.slotConfig ? (wrap.slotConfig.side ? list.contentHeight : wrap.height) : (wrap.parent ? wrap.parent.height : 0)

        orientation: wrap.slotConfig ? (wrap.slotConfig.side ? ListView.Vertical : ListView.Horizontal) : ListView.Horizontal
        interactive: false

        model: SystemTray.items
        delegate: Rectangle {
            id: trayItem
            color: "transparent"
            required property SystemTrayItem modelData
            width: (wrap.slotConfig?.side) ? (wrap.parent?.width || 0) : height
            height: (wrap.slotConfig?.side) ? width : (wrap.parent?.height || 0)

            Image {
                anchors.centerIn: parent
                source: trayItem.modelData.icon
                width: wrap.property.icon
                height: wrap.property.icon

                HoverHandler {
                    onHoveredChanged: {
                        if (wrap.focused === trayItem.modelData) {
                            wrap.focused.menu = null;
                            wrap.item.focused = null;
                            return;
                        }

                        wrap.focused.menu = traymenu;
                        wrap.focused.item = trayItem.modelData;
                    }
                }

                QsMenuOpener {
                    id: traymenuItems
                    menu: trayItem.modelData.menu
                }

                Instantiator {
                    model: traymenuItems.children
                    delegate: DelegateChooser {
                        role: "isSeparator"
                        DelegateChoice {
                            roleValue: true
                            MenuSeparator {}
                        }
                        DelegateChoice {
                            roleValue: false
                            Action {
                                required property var modelData
                                text: modelData.text
                                enabled: modelData.enabled
                                icon.name: modelData.icon
                                checkable: modelData.buttonType !== QsMenuButtonType.None
                                checked: modelData.buttonType !== QsMenuButtonType.None && modelData.checkState !== Qt.Unchecked
                                onTriggered: modelData.triggered()
                            }
                        }
                    }
                    onObjectAdded: (idx, obj) => {
                        if (obj instanceof Action) {
                            traymenu.insertAction(idx, obj);
                        } else {
                            traymenu.insertItem(idx, obj);
                        }
                    }
                    onObjectRemoved: (idx, obj) => {
                        if (obj instanceof Action) {
                            traymenu.removeAction(idx, obj);
                        } else {
                            traymenu.removeItem(idx, obj);
                        }
                    }
                }

                Menu {
                    id: traymenu
                    width: 200
                    onOpened: wrap.area(traymenu.background)
                    onClosed: wrap.area(null)
                }
            }
        }
    }
}
