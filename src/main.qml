/*
 * Copyright (C) 2026 Timo Könnecke <github.com/moWerk>
 *               2016 Florent Revest <revestflo@gmail.com>
 *               2015 Tim Süberkrüb <tim.sueberkrueb@web.de>
 * Part of this code is based on "Stopwatch" (https://github.com/baleboy/stopwatch)
 * Copyright (C) 2011 Francesco Balestrieri
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

import QtQuick
import org.asteroid.controls
import org.asteroid.stopwatch

Application {
    id: app

    centerColor: "#9800A6"
    outerColor: "#0C0009"

    property string swState: Stopwatch.running ? "running"
                           : Stopwatch.elapsed < 0 ? "zero" : "paused"

    function zeroPad(n) {
        return (n < 10 ? "0" : "") + n
    }

    function toTimeString(usec) {
        var mod = Math.abs(usec)
        if (mod >= 3600000) {      // Hours + Minutes + Seconds
            return  '<font color=\"#FFFFFF\" size="3">' + Math.floor(mod / 3600000) + '<sup>h</sup>' + '<br></font>' +
                    '<font color=\"#CCCCF3\" size="1">' + zeroPad(Math.floor((mod % 3600000) / 60000)) + '<sup>m</sup>' +
                    zeroPad(Math.floor((mod % 60000) / 1000)) + '<sup>s</sup></font>'

        } else if (mod >= 60000) { // Minutes + Seconds + Tenth
            return '<font color="#FFFFFF" size="3">' + zeroPad(Math.floor((mod % 3600000) / 60000)) + '<sup>m</sup>' + '<br></font>' +
                   '<font color="#CCCCF3" size="1">' + zeroPad(Math.floor((mod % 60000) / 1000)) + '<sup>s</sup>' +
                   Math.floor((mod % 1000) / 100) + '</font>'
        } else {                   // Seconds + Tenth
            return '<font color="#FFFFFF" size="3">' + zeroPad(Math.floor((mod % 60000) / 1000)) + '<sup>s</sup>' + '</font>' +
                   '<font color="#CCCCF3" size="1">' + Math.floor((mod % 1000) / 100) + '</font>'
        }
    }

    function resetAll() {
        Stopwatch.reset()
        pageView.currentIndex = 0
    }

    ListView {
        id: pageView
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        flickDeceleration: 5000
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        model: 2

        delegate: Item {
            width: pageView.width
            height: pageView.height

            Item {
                anchors.fill: parent
                visible: index === 0

                Label {
                    id: elapsedLabel
                    clip: false
                    textFormat: Text.RichText
                    anchors.centerIn: parent
                    text: toTimeString(Stopwatch.elapsed)
                    font.pixelSize: Dims.h(25)
                    horizontalAlignment: Text.AlignHCenter

                    SequentialAnimation {
                        running: app.swState == "paused"
                        loops: Animation.Infinite
                        NumberAnimation { target: elapsedLabel; property: "opacity"; from: 1; to: 0; duration: 500 }
                        NumberAnimation { target: elapsedLabel; property: "opacity"; from: 0; to: 1; duration: 500 }
                        onStopped: elapsedLabel.opacity = 1
                    }
                }

                MouseArea {
                    anchors.fill: parent
                        onClicked: {
                            switch(app.swState) {
                                case "zero":
                                case "paused":
                                    Stopwatch.start()
                                    break;
                                case "running":
                                    Stopwatch.stop()
                                    break;
                            }
                        }
                }

                Item {
                    visible: app.swState === "paused"
                    anchors {
                        top: elapsedLabel.bottom
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }

                    Icon {
                        anchors.centerIn: parent
                        name: "ios-refresh"
                        width: Dims.l(24)
                        height: Dims.l(24)
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Stopwatch.reset()
                    }
                }
            }

            LapPage {
                anchors.fill: parent
                visible: index === 1
                elapsedMs: Stopwatch.elapsed
                swState: app.swState
                lapList: Stopwatch.laps
                onLapRecorded: Stopwatch.recordLap()
            }
        }
    }

    PageDot {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Dims.h(2)
        }
        height: Dims.h(2)
        dotNumber: 2
        currentIndex: pageView.currentIndex
        visible: !(app.swState === "paused" && pageView.currentIndex === 0)
    }
}
