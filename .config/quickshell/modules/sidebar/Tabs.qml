import QtQuick
import QtQuick.Layouts

RowLayout {
    id: tabRow
    Layout.fillWidth: true
    Layout.maximumHeight: 32

    property int currentIndex: container.currentIndex // Link to your StackLayout

    ListModel {
        id: tabModel
        ListElement {
            label: "Calendar"
        }
        ListElement {
            label: "Todo"
        }
        ListElement {
            label: "System"
        }
    }

    Repeater {
        model: tabModel
        TabButton {
            label: model.label
            tabIndex: index
            currentIndex: tabRow.currentIndex
        }
    }
}
