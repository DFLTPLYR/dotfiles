pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.utils
import qs.config
import qs.assets
import qs.services

Rectangle {
    id: calendarWrapper
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Scripts.setOpacity(Color.color0, 0.5)
    radius: 10

    property int year: TimeService.year
    property int month: TimeService.month

    property int currentYear: TimeService.year
    property int currentMonth: TimeService.month

    property bool isCurrentDate: currentYear === year && currentMonth === month

    function goToToday() {
        year = currentYear;
        month = currentMonth;
    }

    function incrementMonth() {
        if (calendarWrapper.month >= 12) {
            calendarWrapper.month = 1;
            calendarWrapper.year++;
        } else {
            calendarWrapper.month++;
        }
    }

    function decrementMonth() {
        if (calendarWrapper.month <= 1) {
            calendarWrapper.month = 12;
            calendarWrapper.year--;
        } else {
            calendarWrapper.month--;
        }
    }

    function daysInMonth(y, m) {
        return new Date(y, m + 1, 0).getDate();
    }

    function firstDayOfMonth(y, m) {
        return new Date(y, m, 1).getDay();
    }

    GridLayout {
        id: calendarGrid
        anchors.fill: parent
        columns: 7
        rowSpacing: 4
        columnSpacing: 4
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        anchors {
            topMargin: 10
            rightMargin: 10
            leftMargin: 10
            bottomMargin: 10
        }

        property var dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        property var monthShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        // Prev Button
        Rectangle {
            color: Scripts.setOpacity(Color.color10, 0.4)
            Layout.fillWidth: true
            Layout.fillHeight: false
            height: 20

            border.color: prevBtnMA.containsMouse ? Color.color12 : Color.color14
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Text {
                id: prevBtn
                text: '\uf0d9'
                color: Color.color14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.centerIn: parent
            }

            MouseArea {
                id: prevBtnMA
                anchors.fill: parent
                onClicked: calendarWrapper.decrementMonth()
                z: 1
            }
        }

        // Date Year Month
        Rectangle {
            color: 'transparent'
            Layout.fillWidth: true
            Layout.fillHeight: false
            height: 20
            Layout.columnSpan: 5

            Text {
                id: currentDate
                anchors.centerIn: parent
                text: qsTr(`${calendarWrapper.year} - ${calendarGrid.monthShort[calendarWrapper.month - 1]}`)
                color: Color.color14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: FontProvider.fontSometypeMono
                MouseArea {
                    anchors.fill: parent
                    onClicked: calendarWrapper.goToToday()
                    z: 1
                }
            }
        }

        // Next Button
        Rectangle {
            color: Scripts.setOpacity(Color.color10, 0.4)
            Layout.fillWidth: true
            Layout.fillHeight: false
            height: 20

            border.color: nextBtnMA.containsMouse ? Color.color12 : Color.color14
            radius: 4

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Text {
                id: nextBtn
                text: '\uf0da'
                color: Color.color14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.centerIn: parent
            }

            MouseArea {
                id: nextBtnMA
                anchors.fill: parent
                onClicked: calendarWrapper.incrementMonth()
                z: 1
            }
        }

        Repeater {
            model: calendarGrid.columns
            delegate: Rectangle {
                color: Scripts.setOpacity(Color.color10, 0.4)
                Layout.fillWidth: true
                Layout.fillHeight: false
                height: 30

                border.color: Scripts.setOpacity(Color.color10, 0.4)
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: calendarGrid.dayNames[index]
                    font.bold: true
                    color: Color.color14
                    font.family: FontProvider.fontSometypeItalic
                }
            }
        }

        Repeater {
            model: {
                let year = calendarWrapper.year;
                let month = calendarWrapper.month - 1;
                let totalDays = calendarWrapper.daysInMonth(year, month);
                let startOffset = calendarWrapper.firstDayOfMonth(year, month);
                let cells = [];
                let totalCells = totalDays + startOffset;
                for (let i = 0; i < totalCells; i++) {
                    if (i < startOffset) {
                        cells.push("");
                    } else {
                        cells.push(i - startOffset + 1);
                    }
                }
                return cells;
            }

            delegate: Rectangle {
                property bool selected: {
                    return modelData === TimeService.date.getDate() && calendarWrapper.isCurrentDate;
                }

                color: selected ? Scripts.setOpacity(Color.color15, 0.4) : (modelData ? Scripts.setOpacity(Color.color10, 0.4) : "transparent")
                radius: 4

                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: modelData ? modelData : '\uf111'
                    font.pixelSize: modelData ? 12 : 8
                    color: modelData ? Color.color14 : "transparent"
                    font.family: FontProvider.fontSometypeItalic
                }
            }
        }
    }
}
