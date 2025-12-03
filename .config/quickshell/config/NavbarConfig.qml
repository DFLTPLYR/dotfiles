import Quickshell.Io
import qs.assets

JsonObject {
    property string position: "top" // top, bottom, left, right
    property bool side: position === "left" || position === "right"
    property int width: 50
    property int height: 50
    property list<string> modules: ["workspaces", "clock", "buttons"]
    property ExtendedBarConfig extended: ExtendedBarConfig {}
    property PopupProps popup: PopupProps {}
    property RectProps main: RectProps {}
    property RectProps backing: RectProps {}
    property RectProps intersection: RectProps {}
}
