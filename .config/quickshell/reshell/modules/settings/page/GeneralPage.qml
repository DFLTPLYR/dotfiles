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
                model: Global.fonts
                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                delegate: Rectangle {
                    id: font
                    required property var modelData
                    property var val: JSON.parse(modelData)
                    width: ListView.view.width
                    height: 40
                    color: "transparent"

                    Text {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: font.val.name
                        font.family: font.val.name
                    }
                    MouseArea {
                        id: mafont
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (containsMouse) {
                                example.family = font.val.name;
                            }
                        }
                        anchors.fill: parent
                        onClicked: {
                            const family = font.val.family;
                            const name = font.val.name;
                            SysFont.apply(name, 12, family);
                            Quickshell.reload(false);
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
                    required property var modelData
                    spacing: 20
                    Text {
                        text: modelData.alpha
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        width: 30
                        font.family: example.family || SysFont.current
                    }
                    Text {
                        text: modelData.lowercase
                        font.pixelSize: 16
                        width: 30
                        font.family: example.family || SysFont.current
                    }
                    Text {
                        text: modelData.phonic
                        font.pixelSize: 16
                        width: 120
                        font.family: example.family || SysFont.current
                    }
                    Text {
                        text: modelData.name
                        font.pixelSize: 16
                        width: 80
                        font.family: example.family || SysFont.current
                    }
                }
            }
        }
    }
}
