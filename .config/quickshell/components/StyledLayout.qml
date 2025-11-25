import QtQuick
import QtQuick.Layouts

Item {
    id: styledLayoutRoot
    property bool isPortrait: false
    property real spacing: layoutLoader.item ? layoutLoader.item.spacing : 0
    default property alias content: contentHolder.data

    Item {
        id: contentHolder
        visible: false
    }

    Loader {
        id: layoutLoader
        anchors.fill: parent
        active: true
        sourceComponent: styledLayoutRoot.isPortrait ? portraitLayout : landscapeLayout
        onLoaded: {
            if (item && (item as Item) && contentHolder.data.length > 0) {
                var cc = item;
                var childrenArray = [];
                for (let i = 0; i < contentHolder.data.length; i++) {
                    childrenArray.push(contentHolder.data[i]);
                }

                for (let child of childrenArray) {
                    if (child instanceof Item)
                        child.parent = cc;
                }
            }
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
