import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick3D

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Greetd
import Quickshell.Services.Pipewire
import Quickshell.Wayland

import qs.assets
import qs.components
import qs.services
import qs.utils
import qs.config

ShellRoot {
  id: root
    FloatingWindow {
      id: floatingWindow
      property var isPortrait: screen.height > screen.width
      property var landscapeSize: Qt.size(screen.width / 3, screen.height / 2)
      property var portraitSize: Qt.size(screen.width / 2, screen.height / 3)
      
      maximumSize: isPortrait ? portraitSize : landscapeSize
      minimumSize: isPortrait ? portraitSize : landscapeSize
      
      color: "transparent"

      // content
      Rectangle {
        id: contentRect
        
        anchors  {
          left: parent.left
          right: parent.right
          top: parent.top
        }

        width: parent.width
        height: parent.height / 4
      }

      Rectangle {
        id: settingsRect

        anchors {
          left: parent.left
          right: parent.right
          bottom: parent.bottom
          top: contentRect.bottom
        }

        width: parent.width
        height: parent.height / 4
      }
    }
}
