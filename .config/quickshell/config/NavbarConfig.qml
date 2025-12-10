import Quickshell.Io
import qs.assets

JsonObject {
    property string position: "top" // top, bottom, left, right
    property bool side: position === "left" || position === "right"
    property int width: 50
    property int height: 50
    property list<var> module: [
        {
            module: "workspaces",
            styles: ["roman", "kanji"],
            style: "roman",
            showSpecial: true,
            position: "left",
            setting: {
                styles: ["roman", "kanji"],
                style: "roman",
                showSpecial: true
            }
        },
        {
            module: "clock",
            position: "center",
            setting: {
                availableFormats: ["HH:mm", "hh:mm AP", "hh:mm:ss AP", "YYYY-MM-DD HH:mm", "DD/MM/YYYY HH:mm"],
                format: "HH:mm AP"
            }
        },
        {
            module: "powerbtn",
            position: "right"
        }
    ]
    property list<var> modules: [
        {
            module: "workspaces",
            styles: ["roman", "kanji"],
            style: "roman",
            showSpecial: true,
            position: {
                row: null,
                rowSpan: null,
                column: null,
                columnSpan: null
            },
            setting: {
                styles: ["roman", "kanji"],
                style: "roman",
                showSpecial: true
            }
        },
        {
            module: "clock",
            position: {
                row: null,
                rowSpan: null,
                column: null,
                columnSpan: null
            },
            setting: {
                availableFormats: ["HH:mm", "hh:mm AP", "hh:mm:ss AP", "YYYY-MM-DD HH:mm", "DD/MM/YYYY HH:mm"],
                format: "HH:mm AP"
            }
        },
        {
            module: "powerbtn",
            position: {
                row: null,
                rowSpan: null,
                column: null,
                columnSpan: null
            }
        }
    ]
    property ExtendedBarConfig extended: ExtendedBarConfig {}
    property PopupProps popup: PopupProps {}
    property RectProps main: RectProps {}
    property RectProps backing: RectProps {}
    property RectProps intersection: RectProps {}
}
