pragma ComponentBehavior: Bound

import QtCore
import Quickshell
import Qt.labs.folderlistmodel
import System

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings

Page {
    property var screen

    GreeterSection {}

    ScreenRecSection {}

    DisplayTemp {}

    FontSection {}

    component GreeterSection: GroupContainer {
        label: "Greeter"

        Toggle {
            property bool greeter: Global.general.greeter
            text: greeter ? "Enable" : "Disable"
            checked: greeter
            onCheckedChanged: {
                Global.general.greeter = checked;
                Global.save();
            }
        }
    }

    component ScreenRecSection: GroupContainer {
        id: screenRec
        property bool recorder: Global.general.recorder
        label: "Screen Recorder"

        Toggle {
            id: replayToggle
            text: Global.general.recorder.replay ? "Enable" : "Disable"
            checked: Global.general.recorder.replay
            onCheckedChanged: {
                Global.general.recorder.replay = checked;
                Global.save();
            }
        }

        Column {
            visible: replayToggle.checked
            Label {
                text: "Replay Monitor"
                font.pixelSize: 14
            }
            Row {

                Repeater {
                    model: Quickshell.screens
                    delegate: RadioDelegate {
                        required property var modelData
                        text: modelData.name
                        checked: modelData.name === Global.general.recorder.monitor

                        onCheckedChanged: {
                            if (checked) {
                                Global.general.recorder.monitor = text;
                            }
                        }
                    }
                }
            }
        }

        Column {
            visible: replayToggle.checked
            Label {
                text: "Duration"
                font.pixelSize: 14
            }
            SpinBox {
                value: Global.general.recorder.duration
                width: 100
                onValueChanged: {
                    Global.general.recorder.duration = value;
                }
            }
        }

        Column {
            visible: replayToggle.checked
            Label {
                text: "Fps"
                font.pixelSize: 14
            }
            SpinBox {
                value: Global.general.recorder.fps
                width: 100
                onValueChanged: {
                    Global.general.recorder.fps = value;
                }
            }
        }
    }

    component DisplayTemp: GroupContainer {
        label: "Screen Temp"
        Row {
            Button {
                text: "Increase"
                onClicked: {
                    Quickshell.execDetached(["busctl", "--user", "call", "--", "rs.wl-gammarelay", "/", "rs.wl.gammarelay", "UpdateTemperature", "n", "500"]);
                }
            }

            Button {
                text: "Decrease"
                onClicked: {
                    Quickshell.execDetached(["busctl", "--user", "call", "--", "rs.wl-gammarelay", "/", "rs.wl.gammarelay", "UpdateTemperature", "n", "-500"]);
                }
            }
        }
    }

    component FontSection: GroupContainer {
        RowLayout {
            height: 400
            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }

            ListView {
                model: SysFont.list.filter(f => f.category === "sans-serif")
                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                delegate: Rectangle {
                    id: font
                    required property var modelData
                    width: ListView.view.width
                    height: 40
                    color: "transparent"

                    Text {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: font.modelData.name
                        font.family: font.modelData.name
                        color: Colors.theme.primary
                    }
                    MouseArea {
                        id: mafont
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (containsMouse) {
                                example.family = font.modelData.name;
                            }
                        }
                        anchors.fill: parent
                        onClicked: {
                            const family = font.modelData.family;
                            const name = font.modelData.name;
                            SysFont.apply(name, 12, family);
                        }
                    }
                }
            }

            ListView {
                id: example
                Layout.fillHeight: true
                Layout.fillWidth: true
                property var family
                property var alphabet: [
                    {
                        "alpha": "A",
                        "lowercase": "a",
                        "phonic": "/eɪ/, /æ/",
                        "name": "a"
                    },
                    {
                        "alpha": "B",
                        "lowercase": "b",
                        "phonic": "/biː/",
                        "name": "bee"
                    },
                    {
                        "alpha": "C",
                        "lowercase": "c",
                        "phonic": "/siː/",
                        "name": "cee"
                    },
                    {
                        "alpha": "D",
                        "lowercase": "d",
                        "phonic": "/diː/",
                        "name": "dee"
                    },
                    {
                        "alpha": "E",
                        "lowercase": "e",
                        "phonic": "/iː/",
                        "name": "e"
                    },
                    {
                        "alpha": "F",
                        "lowercase": "f",
                        "phonic": "/ɛf/",
                        "name": "ef"
                    },
                    {
                        "alpha": "G",
                        "lowercase": "g",
                        "phonic": "/dʒiː/",
                        "name": "gee"
                    },
                    {
                        "alpha": "H",
                        "lowercase": "h",
                        "phonic": "/(h)eɪtʃ/",
                        "name": "(h)aitch"
                    },
                    {
                        "alpha": "I",
                        "lowercase": "i",
                        "phonic": "/aɪ/",
                        "name": "i"
                    },
                    {
                        "alpha": "J",
                        "lowercase": "j",
                        "phonic": "/dʒeɪ/",
                        "name": "jay"
                    },
                    {
                        "alpha": "K",
                        "lowercase": "k",
                        "phonic": "/keɪ/",
                        "name": "kay"
                    },
                    {
                        "alpha": "L",
                        "lowercase": "l",
                        "phonic": "/ɛl/",
                        "name": "el"
                    },
                    {
                        "alpha": "M",
                        "lowercase": "m",
                        "phonic": "/ɛm/",
                        "name": "em"
                    },
                    {
                        "alpha": "N",
                        "lowercase": "n",
                        "phonic": "/ɛn/",
                        "name": "en"
                    },
                    {
                        "alpha": "O",
                        "lowercase": "o",
                        "phonic": "/oʊ/",
                        "name": "o"
                    },
                    {
                        "alpha": "P",
                        "lowercase": "p",
                        "phonic": "/piː/",
                        "name": "pee"
                    },
                    {
                        "alpha": "Q",
                        "lowercase": "q",
                        "phonic": "/kjuː/",
                        "name": "cue"
                    },
                    {
                        "alpha": "R",
                        "lowercase": "r",
                        "phonic": "/ɑːr/",
                        "name": "ar"
                    },
                    {
                        "alpha": "S",
                        "lowercase": "s",
                        "phonic": "/ɛs/",
                        "name": "ess"
                    },
                    {
                        "alpha": "T",
                        "lowercase": "t",
                        "phonic": "/tiː/",
                        "name": "tee"
                    },
                    {
                        "alpha": "U",
                        "lowercase": "u",
                        "phonic": "/juː/",
                        "name": "u"
                    },
                    {
                        "alpha": "V",
                        "lowercase": "v",
                        "phonic": "/viː/",
                        "name": "vee"
                    },
                    {
                        "alpha": "W",
                        "lowercase": "w",
                        "phonic": "/ˈdʌbəl.juː/",
                        "name": "double-u"
                    },
                    {
                        "alpha": "X",
                        "lowercase": "x",
                        "phonic": "/ɛks/",
                        "name": "ex"
                    },
                    {
                        "alpha": "Y",
                        "lowercase": "y",
                        "phonic": "/waɪ/",
                        "name": "wy"
                    },
                    {
                        "alpha": "Z",
                        "lowercase": "z",
                        "phonic": "/ziː/ or /zɛd/",
                        "name": "zee/zed"
                    }
                ]

                model: alphabet
                clip: true
                delegate: Row {
                    id: row
                    required property var modelData
                    spacing: 20

                    Text {
                        text: row.modelData.alpha
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        width: 30
                        font.family: example.family || SysFont.current
                        color: Colors.theme.primary
                    }

                    Text {
                        text: row.modelData.lowercase
                        font.pixelSize: 16
                        width: 30
                        font.family: example.family || SysFont.current
                        color: Colors.theme.primary
                    }

                    Text {
                        text: row.modelData.phonic
                        font.pixelSize: 16
                        width: 120
                        font.family: example.family || SysFont.current
                        color: Colors.theme.primary
                    }

                    Text {
                        text: row.modelData.name
                        font.pixelSize: 16
                        width: 80
                        font.family: example.family || SysFont.current
                        color: Colors.theme.primary
                    }
                }
            }
        }
    }
}
