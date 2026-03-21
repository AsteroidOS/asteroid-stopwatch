/*
 * Copyright (C) 2026 Timo Könnecke <github.com/moWerk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0

Item {
    id: lapPage

    property real elapsedMs: 0
    property var lapList: []
    property string swState: "zero"

    signal lapRecorded()

    function zeroPad(n) {
        return (n < 10 ? "0" : "") + n
    }

    function toLapString(ms) {
        var mod = Math.abs(ms)
        var minutes = Math.floor(mod / 60000)
        var seconds = Math.floor((mod % 60000) / 1000)
        var tenth = Math.floor((mod % 1000) / 100)
        if (minutes > 0) {
            return zeroPad(minutes) + ":" + zeroPad(seconds) + "." + tenth
        }
        return zeroPad(seconds) + "." + tenth + "s"
    }

    function toDeltaString(ms) {
        var sign = ms >= 0 ? "+" : "-"
        var mod = Math.abs(ms)
        var minutes = Math.floor(mod / 60000)
        var seconds = Math.floor((mod % 60000) / 1000)
        var tenth = Math.floor((mod % 1000) / 100)
        if (minutes > 0) {
            return sign + zeroPad(minutes) + ":" + zeroPad(seconds) + "." + tenth
        }
        return sign + zeroPad(seconds) + "." + tenth
    }

    // Full-page list, flows under the delta overlay
    ListView {
        id: lapListView
        anchors.fill: parent
        topMargin: Dims.h(30)
        clip: false
        footer: Item {
            width: lapListView.width
            height: DeviceSpecs.hasRoundScreen ? Dims.l(20) : Dims.l(8)
        }
        model: (lapPage.lapList ? lapPage.lapList.length : 0) + 1

        delegate: Item {
            width: lapListView.width
            height: Dims.l(20)

            readonly property bool isCurrentRow: index === 0
            readonly property int lapIndex: index - 1

            // Lap number — small, dimmed
            Label {
                id: rowLapNum
                anchors {
                    left: parent.left
                    leftMargin: Dims.l(15)
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: Dims.l(6)
                color: "#CCCCF3"
                opacity: 0.6
                text: {
                    var total = lapPage.lapList ? lapPage.lapList.length : 0
                    return isCurrentRow ? "L" + (total + 1) : "L" + (total - lapIndex)
                }
            }

            // Split time or live running elapsed for current row
            Label {
                anchors {
                    left: rowLapNum.right
                    leftMargin: Dims.l(3)
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: Dims.l(8)
                text: {
                    if (isCurrentRow) {
                        var mod = lapPage.elapsedMs < 0 ? 0 : lapPage.elapsedMs
                        var lapArr = lapPage.lapList
                        var base = (lapArr && lapArr.length > 0) ? lapArr[0] : 0
                        mod = mod - base
                        var h = Math.floor(mod / 3600000)
                        var m = Math.floor((mod % 3600000) / 60000)
                        var s = Math.floor((mod % 60000) / 1000)
                        if (h > 0) return zeroPad(h) + "h" + zeroPad(m) + "m" + zeroPad(s) + "s"
                        if (m > 0) return zeroPad(m) + "m" + zeroPad(s) + "s"
                        return zeroPad(s) + "s"
                    }
                    var lapArr = lapPage.lapList
                    var prev = (lapIndex + 1 < lapArr.length) ? lapArr[lapIndex + 1] : 0
                    return toLapString(lapArr[lapIndex] - prev)
                }
            }

            // Delta vs previous split — hidden on current row and first recorded lap
            Label {
                anchors {
                    right: parent.right
                    rightMargin: Dims.w(15)
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: Dims.l(6)
                visible: !isCurrentRow && lapIndex + 1 < (lapPage.lapList ? lapPage.lapList.length : 0)
                text: {
                    var lapArr = lapPage.lapList
                    if (!lapArr || lapIndex + 1 >= lapArr.length) return ""
                    var prev = lapArr[lapIndex + 1]
                    var prev2 = (lapIndex + 2 < lapArr.length) ? lapArr[lapIndex + 2] : 0
                    return toDeltaString((lapArr[lapIndex] - prev) - (prev - prev2))
                }
                color: {
                    var lapArr = lapPage.lapList
                    if (!lapArr || lapIndex + 1 >= lapArr.length) return "#CCCCF3"
                    var prev = lapArr[lapIndex + 1]
                    var prev2 = (lapIndex + 2 < lapArr.length) ? lapArr[lapIndex + 2] : 0
                    return ((lapArr[lapIndex] - prev) - (prev - prev2)) <= 0 ? "#AAEE44" : "#FF6644"
                }
            }

            RowSeparator { pinToBottom: true }
        }
    }

    // Fade mask — list scrolls under this, giving contrast to the delta label above
    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: Dims.h(40)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FF000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    // Current split or lap delta — tap to record a lap
    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: Dims.h(40)

        Label {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Dims.h(12)
            text: {
                var lapArr = lapPage.lapList
                var cur = lapPage.elapsedMs < 0 ? 0 : lapPage.elapsedMs
                if (!lapArr || lapArr.length === 0) {
                    return toLapString(cur)
                }
                var curSplit = cur - lapArr[0]
                if (lapArr.length < 2) {
                    return toLapString(curSplit)
                }
                return toDeltaString(curSplit - (lapArr[0] - lapArr[1]))
            }
            color: {
                var lapArr = lapPage.lapList
                if (!lapArr || lapArr.length < 2) return "#CCCCF3"
                var cur = lapPage.elapsedMs < 0 ? 0 : lapPage.elapsedMs
                var curSplit = cur - lapArr[0]
                var prev = lapArr[0] - lapArr[1]
                return (curSplit - prev) <= 0 ? "#AAEE44" : "#FF6644"
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: lapPage.lapRecorded()
        }
    }
}
