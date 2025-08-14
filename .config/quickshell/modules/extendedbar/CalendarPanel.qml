import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.services
import qs.utils
import qs

Rectangle {
    id: calendarWrapper
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "transparent"

    property int year: Time.year
    property int month: Time.month

    property int currentYear: Time.year
    property int currentMonth: Time.month

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

        property var dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        property var monthShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        // Prev Button
        Rectangle {
            color: 'transparent'
            Layout.fillWidth: true
            Layout.fillHeight: false
            height: 20

            border.color: prevBtnMA.containsMouse ? Colors.color12 : Colors.color1
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
                color: Colors.color15
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
                color: Colors.color15
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: calendarWrapper.goToToday()
                    z: 1
                }
            }
        }

        // Next Button
        Rectangle {
            color: 'transparent'
            Layout.fillWidth: true
            Layout.fillHeight: false
            height: 20

            border.color: nextBtnMA.containsMouse ? Colors.color12 : Colors.color1
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
                color: Colors.color15
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
                color: 'transparent'
                Layout.fillWidth: true
                Layout.fillHeight: false
                height: 30

                border.color: Colors.color1
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: calendarGrid.dayNames[index]
                    font.bold: true
                    color: Colors.color11
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
                    return modelData === Time.date.getDate() && calendarWrapper.isCurrentDate;
                }

                color: selected ? Scripts.hexToRgba(Colors.color15, 0.2) : "transparent"
                radius: 4

                Layout.fillWidth: true
                Layout.fillHeight: true

                border.color: Colors.color1

                Text {
                    anchors.centerIn: parent
                    text: modelData ? modelData : '\uf111'
                    font.pixelSize: modelData ? 12 : 6
                    color: modelData ? (selected ? Colors.color10 : Colors.color15) : Colors.color0
                }
            }
        }
    }
}
