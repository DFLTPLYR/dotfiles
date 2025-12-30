import QtQuick
import QtQuick.Layouts

Item {
    id: styledLayoutRoot
    property bool isPortrait: false
    property real spacing: layoutLoader.item ? layoutLoader.item.spacing : 0
    default property alias content: contentHolder.children

    QtObject {
        id: contentHolder
        property list<Item> children
    }

    Loader {
        id: layoutLoader
        anchors.fill: parent
        active: true
        sourceComponent: styledLayoutRoot.isPortrait ? portraitLayout : landscapeLayout
        onLoaded: styledLayoutRoot.reparentChildren()
    }

    function reparentChildren() {
        const layoutItem = layoutLoader.item;
        if (!layoutItem)
            return;
        for (let c of contentHolder.children) {
            if (c.parent !== layoutItem)
                c.parent = layoutItem;
        }
    }

    Component {
        id: portraitLayout
        ColumnLayout {
            anchors.fill: parent
        }
    }

    Component {
        id: landscapeLayout
        RowLayout {
            anchors.fill: parent
        }
    }
}
