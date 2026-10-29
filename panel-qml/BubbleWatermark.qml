pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons as Commons

// Pure-vector RGB glass bubble watermark for the Omarchy top bar.
// Zero raster textures or runtime shader effects are loaded; each bubble is
// drawn with lightweight QML vector primitives and gated on RGB Bubble's
// shell.toml marker so switching themes hides it immediately.
Item {
  id: root

  anchors.fill: parent
  clip: true
  z: 0
  readonly property real unit: Math.min(width, height)
  readonly property bool enabledForTheme: Commons.Color.shellValues["rgb-bubble.watermark"] === "true"

  Repeater {
    model: root.enabledForTheme ? [
      { x: 0.04, y: 0.16, s: 0.34, c: "#FF7184" },
      { x: 0.11, y: 0.68, s: 0.24, c: "#4AD69A" },
      { x: 0.19, y: 0.20, s: 0.40, c: "#73A3FF" },
      { x: 0.28, y: 0.66, s: 0.28, c: "#FF7184" },
      { x: 0.36, y: 0.14, s: 0.32, c: "#4AD69A" },
      { x: 0.44, y: 0.72, s: 0.22, c: "#73A3FF" },
      { x: 0.56, y: 0.18, s: 0.36, c: "#FF7184" },
      { x: 0.64, y: 0.68, s: 0.26, c: "#4AD69A" },
      { x: 0.73, y: 0.14, s: 0.42, c: "#73A3FF" },
      { x: 0.81, y: 0.66, s: 0.25, c: "#FF7184" },
      { x: 0.89, y: 0.20, s: 0.35, c: "#4AD69A" },
      { x: 0.96, y: 0.64, s: 0.28, c: "#73A3FF" }
    ] : []

    delegate: Item {
      id: bubble
      required property var modelData
      width: Math.max(6, root.unit * modelData.s)
      height: width
      x: root.width * modelData.x - width / 2
      y: (root.height - height) * modelData.y

      // Outer translucent glass sphere + colored rim
      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: bubble.modelData.c
        opacity: 0.11
        border.color: bubble.modelData.c
        border.width: Math.max(1, root.unit * 0.028)
      }

      // Inner subtle rim ring for glass depth
      Rectangle {
        anchors.fill: parent
        anchors.margins: Math.max(1, parent.width * 0.12)
        radius: width / 2
        color: "transparent"
        border.color: "white"
        border.width: 1
        opacity: 0.08
      }

      // Primary top-left specular highlight
      Rectangle {
        x: parent.width * 0.20
        y: parent.height * 0.18
        width: parent.width * 0.22
        height: Math.max(1.5, parent.width * 0.08)
        radius: height / 2
        rotation: -38
        color: "white"
        opacity: 0.34
      }

      // Secondary bottom-right bounce reflection dot
      Rectangle {
        x: parent.width * 0.66
        y: parent.height * 0.68
        width: Math.max(1.5, parent.width * 0.09)
        height: width
        radius: width / 2
        color: bubble.modelData.c
        opacity: 0.28
      }
    }
  }
}
