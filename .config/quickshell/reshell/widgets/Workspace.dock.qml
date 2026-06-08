import QtQuick
import Quickshell
import Quickshell.WindowManager

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

    readonly property var sets: wrap.screen ? WindowManager.screenProjection(wrap.screen)?.windowsets : null
    ListView {
        id: list

        readonly property var windows: wrap.screen ? WindowManager.screenProjection(wrap.screen)?.windowsets : null

        width: wrap.slotConfig ? (wrap.slotConfig.side ? wrap.width : list.contentWidth) : (wrap.parent ? wrap.parent.width : 0)
        height: wrap.slotConfig ? (wrap.slotConfig.side ? list.contentHeight : wrap.height) : (wrap.parent ? wrap.parent.height : 0)

        orientation: wrap.slotConfig ? (wrap.slotConfig.side ? ListView.Vertical : ListView.Horizontal) : ListView.Horizontal

        interactive: false

        model: ScriptModel {
            values: [...list.windows]
        }

        delegate: Rectangle {
            id: windowSet
            color: ma.hoveredChanged ? Colors.color.background : Colors.setOpacity(Colors.theme.primary, 0.2)
            width: (wrap.slotConfig?.side) ? (wrap.parent?.width || 0) : height
            height: (wrap.slotConfig?.side) ? width : (wrap.parent?.height || 0)

            radius: wrap.property.radius

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            LazyLoader {
                id: text
                active: wrap.property.showText
                component: Text {
                    parent: windowSet
                    anchors.centerIn: parent
                    text: index + 1
                    color: Colors.theme.primary
                }
            }

            LazyLoader {
                id: color
                active: !wrap.property.showText
                component: Rectangle {
                    parent: windowSet
                    width: parent.width / 2
                    height: parent.height / 2
                    radius: width / 2
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    color: modelData?.active ? Colors.theme.primary : Colors.theme.tertiary

                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
            MouseArea {
                id: ma
                hoverEnabled: true
                propagateComposedEvents: true
                anchors.fill: parent
                enabled: Global.normal
                onClicked: {
                    if (modelData.canActivate) {
                        modelData.activate();
                    }
                }
            }
        }
    }
}
