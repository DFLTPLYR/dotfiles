import Quickshell.Io

JsonObject {
    property list<string> styles: ["roman", "kanji"]
    property string style: "roman"
    property list<string> widgets: ["powerBtn", "workSpaces", "clock"]
    property int rows: 2
    property int columns: 2
    property list<var> activeWidgets: [
        {
            widget: "powerBtn",
            position: {
                column: 0,
                row: 0
            }
        },
    ]
}
