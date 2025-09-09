import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import Quickshell

import qs.components

ShellRoot {
    FloatingWindow {
        title: 'test'
        minimumSize: Qt.size(screen.width / 4, screen.height / 2)
        color: 'transparent'

        ScrollView {
            anchors.fill: parent
            ScrollBar.vertical: ScrollBar {}

            Column {
                width: parent.width

                NotificationGroup {
                    width: parent.width
                    notifications: [
                        {
                            summary: "New Email",
                            body: "You have a new message from John.",
                            appName: "Mail"
                        },
                        {
                            summary: "Update Available",
                            body: "Version 2.0 is ready to install.",
                            appName: "Updater"
                        },
                        {
                            summary: "Meeting Reminder",
                            body: "Team meeting in 10 minutes.",
                            appName: "Calendar"
                        },
                        {
                            summary: "Battery Low",
                            body: "Battery at 15%. Please charge.",
                            appName: "System"
                        },
                        {
                            summary: "Friend Request",
                            body: "Alice sent you a friend request.",
                            appName: "Social"
                        }
                    ]
                }
                NotificationGroup {
                    width: parent.width
                    notifications: [
                        {
                            summary: "New Email",
                            body: "You have a new message from John.",
                            appName: "Mail"
                        },
                        {
                            summary: "Update Available",
                            body: "Version 2.0 is ready to install.",
                            appName: "Updater"
                        },
                        {
                            summary: "Meeting Reminder",
                            body: "Team meeting in 10 minutes.",
                            appName: "Calendar"
                        },
                        {
                            summary: "Battery Low",
                            body: "Battery at 15%. Please charge.",
                            appName: "System"
                        },
                        {
                            summary: "Friend Request",
                            body: "Alice sent you a friend request.",
                            appName: "Social"
                        }
                    ]
                }
                NotificationGroup {
                    width: parent.width
                    notifications: [
                        {
                            summary: "New Email",
                            body: "You have a new message from John.",
                            appName: "Mail"
                        },
                        {
                            summary: "Update Available",
                            body: "Version 2.0 is ready to install.",
                            appName: "Updater"
                        },
                        {
                            summary: "Meeting Reminder",
                            body: "Team meeting in 10 minutes.",
                            appName: "Calendar"
                        },
                        {
                            summary: "Battery Low",
                            body: "Battery at 15%. Please charge.",
                            appName: "System"
                        },
                        {
                            summary: "Friend Request",
                            body: "Alice sent you a friend request.",
                            appName: "Social"
                        }
                    ]
                }
                NotificationGroup {
                    width: parent.width
                    notifications: [
                        {
                            summary: "New Email",
                            body: "You have a new message from John.",
                            appName: "Mail"
                        },
                        {
                            summary: "Update Available",
                            body: "Version 2.0 is ready to install.",
                            appName: "Updater"
                        },
                        {
                            summary: "Meeting Reminder",
                            body: "Team meeting in 10 minutes.",
                            appName: "Calendar"
                        },
                        {
                            summary: "Battery Low",
                            body: "Battery at 15%. Please charge.",
                            appName: "System"
                        },
                        {
                            summary: "Friend Request",
                            body: "Alice sent you a friend request.",
                            appName: "Social"
                        }
                    ]
                }
                NotificationGroup {
                    width: parent.width
                    notifications: [
                        {
                            summary: "New Email",
                            body: "You have a new message from John.",
                            appName: "Mail"
                        },
                        {
                            summary: "Update Available",
                            body: "Version 2.0 is ready to install.",
                            appName: "Updater"
                        },
                        {
                            summary: "Meeting Reminder",
                            body: "Team meeting in 10 minutes.",
                            appName: "Calendar"
                        },
                        {
                            summary: "Battery Low",
                            body: "Battery at 15%. Please charge.",
                            appName: "System"
                        },
                        {
                            summary: "Friend Request",
                            body: "Alice sent you a friend request.",
                            appName: "Social"
                        }
                    ]
                }
            }
        }
    }
}
