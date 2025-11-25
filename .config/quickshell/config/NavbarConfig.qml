import Quickshell.Io
import qs.assets

JsonObject {
    property string position: "top" // top, bottom, left, right
    property bool side: position === "left" || position === "right"
    property RectProps main: RectProps {}
    property RectProps backing: RectProps {}
    property RectProps intersection: RectProps {}
}
