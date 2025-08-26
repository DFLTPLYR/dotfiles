import QtQuick
import QtQuick.Layouts

RowLayout {
    id: tabRow
    property int currentIndex: container.currentIndex

    ListModel {
        id: tabModel
        ListElement {
            label: "Calculator"
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
        }s
    }
}
