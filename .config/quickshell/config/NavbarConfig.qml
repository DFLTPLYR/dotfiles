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
            location: "left"
        },
        {
            module: "clock",
            location: "center"
        },
        {
            module: "powerbtn",
            location: "right"
        }
    ]
    property ExtendedBarConfig extended: ExtendedBarConfig {}
    property PopupProps popup: PopupProps {}
    property RectProps main: RectProps {}
    property RectProps backing: RectProps {}
    property RectProps intersection: RectProps {}
}
