import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io

import qs.components
import qs.core
import qs.types

Wrapper {
    id: wrap

    onModal: (_modal, hasChanges) => {
        if (hasChanges) {
            getDefinition.update();
        }
    }

    property: Property {
        id: prop
        property string word: ""
        property string wordFont: ""
        onWordFontChanged: {
            mainWord.font = wordFont;
        }
        onWordChanged: {
            if (wrap.word === undefined) {
                getDefinition.update();
            }
        }
    }

    property string url: `https://api.dictionaryapi.dev/api/v2/entries/en/${prop.word}`
    property var word

    Process {
        id: getDefinition

        command: ["curl", wrap.url]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text)
                    return;
                const word = JSON.parse(text)[0];
                if (word) {
                    return wrap.word = word;
                }
            }
        }

        function update() {
            wrap.url = `https://api.dictionaryapi.dev/api/v2/entries/en/${prop.word}`;
            getDefinition.running = true;
        }
    }

    FlexboxLayout {
        id: column
        clip: true
        width: wrap.width
        height: wrap.height
        direction: FlexboxLayout.Column

        Label {
            id: mainWord
            Layout.fillWidth: true
            text: wrap.word ? wrap.word.word : ""
            font.pixelSize: 32
            font.capitalization: Font.AllUppercase
            color: Colors.theme.primary
        }

        Text {
            id: phonetic

            Layout.fillWidth: true
            color: Colors.theme.on_surface
            text: wrap.word ? wrap.word.phonetic : ""
            font.pixelSize: 12
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: Colors.theme.primary
        }

        Repeater {
            model: wrap.word ? wrap.word.meanings : []

            delegate: ColumnLayout {
                spacing: 4

                Label {
                    Layout.fillWidth: true
                    text: modelData.partOfSpeech
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.theme.primary
                }

                Repeater {
                    model: modelData.definitions

                    delegate: Label {
                        Layout.fillWidth: true
                        text: `\u2022 ${modelData.definition}`
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        color: Colors.theme.on_surface
                        leftPadding: 8
                    }
                }

                RowLayout {
                    visible: modelData.synonyms.length > 0

                    Label {
                        text: "Synonyms:"
                        font.pixelSize: 11
                        font.bold: true
                        color: Colors.theme.primary
                    }

                    Label {
                        Layout.fillWidth: true
                        text: modelData.synonyms.join(", ")
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        color: Colors.theme.on_surface
                    }
                }

                RowLayout {
                    visible: modelData.antonyms.length > 0

                    Label {
                        text: "Antonyms:"
                        font.pixelSize: 11
                        font.bold: true
                        color: Colors.theme.primary
                    }

                    Label {
                        Layout.fillWidth: true
                        text: modelData.antonyms.join(", ")
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        color: Colors.theme.on_surface
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Colors.theme.outline
                    visible: wrap.word && index < wrap.word.meanings.length - 1
                }
            }
        }
    }
}
