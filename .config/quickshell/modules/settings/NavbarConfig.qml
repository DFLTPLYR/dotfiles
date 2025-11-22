import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.components
import qs.assets

Item {
    id: root

    property QtObject mainrect: QtObject {
        property int rounding: 0
        property int padding: 0
        property string color: "background"
    }

    property QtObject backingrect: QtObject {
        property string color: "background"
        property int x: 0
        property int y: 0
        property real opacity: 1
    }

    property QtObject intersection: QtObject {
        property real opacity: 1
        property string color: "background"
        property QtObject border: QtObject {
            property string color: "background"
            property int width: 2
        }
    }

    component Container: StyledRectangle {
        anchors.fill: parent

        // mainrect
        transparency: 1
        rounding: mainrect.rounding
        padding: mainrect.padding
        bgColor: ColorPalette.background

        backingVisible: backingrect.visible !== 0 ? true : false
        backingrectX: backingrect.x
        backingrectY: backingrect.y
        backingrectOpacity: backingrect.opacity

        intersectionOpacity: intersection.opacity
        intersectionColor: intersection.color
    }

    property Component previewComponent: Container {}

    FileView {
        id: settingsWatcher
        path: Qt.resolvedUrl("./config/navbar.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
            root.mainrect.rounding = settings.rounding || root.mainrect.rounding;
            root.mainrect.padding = settings.padding || root.mainrect.padding;

            // Assign backingrect properties
            root.backingrect.color = settings.backingrect?.color || root.backingrect.color;
            root.backingrect.x = settings.backingrect?.x || root.backingrect.x;
            root.backingrect.y = settings.backingrect?.y || root.backingrect.y;
            root.backingrect.opacity = settings.backingrect?.opacity || root.backingrect.opacity;

            // Assign intersection properties
            root.intersection.opacity = settings.intersection?.opacity || root.intersection.opacity;
            root.intersection.color = settings.intersection?.color || root.intersection.color;
            root.intersection.border.color = settings.intersection?.border?.color || root.intersection.border.color;
            root.intersection.border.width = settings.intersection?.border?.width || root.intersection.border.width;
        }
        onLoadFailed: root.saveSettings()
    }

    function saveSettings() {
        const settings = {
            rounding: root.mainrect.rounding || 0,
            padding: root.mainrect.padding || 0,
            backingrect: {
                color: root.backingrect.color || ColorPalette.background,
                x: root.backingrect.x || 0,
                y: root.backingrect.y || 0,
                opacity: root.backingrect.opacity || 0
            },
            intersection: {
                opacity: root.intersection.opacity || 0,
                color: root.intersection.color,
                border: {
                    color: root.intersection.border.color,
                    width: root.intersection.border.width
                }
            }
        };
        settingsWatcher.setText(JSON.stringify(settings, null, 2));
    }

    ScrollView {
        width: parent.width
        height: parent.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        contentWidth: width - 20
        clip: true

        ColumnLayout {
            width: parent.width

            Text {
                text: qsTr("Main Rect Settings")
                color: ColorPalette.color13
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.preferredWidth: 100
                Layout.margins: 20
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Text {
                    text: qsTr("Padding:")
                    color: ColorPalette.color13
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.preferredWidth: 100
                    Layout.margins: 20
                }
                Slider {
                    id: paddingSlider
                    from: 0
                    to: 50
                    stepSize: 1
                    value: root.mainrect.padding
                    Layout.fillWidth: true
                    Layout.margins: 10
                    onValueChanged: {
                        root.mainrect.padding = value;
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Text {
                    text: qsTr("Rounding:")
                    color: ColorPalette.color13
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.preferredWidth: 100
                    Layout.margins: 20
                }
                Slider {
                    from: 0
                    to: 50
                    stepSize: 1
                    value: root.mainrect.rounding
                    Layout.fillWidth: true
                    Layout.margins: 10
                    onValueChanged: {
                        root.mainrect.rounding = value;
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    text: "Position"
                    font.pixelSize: 18
                    color: ColorPalette.color13
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.preferredWidth: 100
                    Layout.margins: 20
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Slider {
                        from: 0
                        value: 0
                        to: Math.round(paddingSlider.value * 2)
                        live: true
                        Layout.fillWidth: true
                        onValueChanged: {
                            root.backingrect.x = Math.round(value);
                        }
                    }

                    Slider {
                        from: 0
                        value: 0
                        to: Math.round(paddingSlider.value * 2)
                        live: true
                        Layout.fillWidth: true
                        onValueChanged: {
                            root.backingrect.y = Math.round(value);
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Button {
                    text: qsTr("Save Settings")
                    onClicked: {
                        root.saveSettings();
                    }
                }
            }
        }
    }
}
