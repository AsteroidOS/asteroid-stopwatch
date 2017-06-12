/*
 * Copyright (C) 2016 Florent Revest <revestflo@gmail.com>
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

import QtQuick 2.5
import org.asteroid.controls 1.0
import org.nemomobile.configuration 1.0

Application {
    id: app

    centerColor: "#b01c7e"
    outerColor: "#420a2f"

    ConfigurationValue {
        id: previousTime
        key: "/stopwatch/previousTime"
        defaultValue: -1
    }
    ConfigurationValue {
        id: elapsed
        key: "/stopwatch/elapsed"
        defaultValue: -1
    }
    ConfigurationValue {
        id: running
        key: "/stopwatch/running"
        defaultValue: false
    }

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

    Item {
        id: mainPage
        anchors.fill: parent

        state: running.value ? "running" : elapsed.value == -1 ? "zero" : "paused"
        states: [
            State { name: "zero" },
            State { name: "running" },
            State { name: "paused" }
        ]

        Text {
            id: elapsedLabel
            textFormat: Text.RichText
            anchors.centerIn: parent
            text: toTimeString(elapsed.value)
            font.pixelSize: parent.height*0.25
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter

            SequentialAnimation {
                running: mainPage.state == "paused"
                loops: Animation.Infinite
                NumberAnimation { target: elapsedLabel; property: "opacity"; from: 1; to: 0; duration: 500 }
                NumberAnimation { target: elapsedLabel; property: "opacity"; from: 0; to: 1; duration: 500 }
                onStopped: elapsedLabel.opacity = 1
            }
        }

        MouseArea {
            anchors.fill: parent
                onClicked: {
                    console.log("from:" + mainPage.state + " " + elapsed.value + " " + running.value + " " + previousTime.value)
                    switch(mainPage.state) {
                        case "zero":
                        case "paused":
                            var curTime = new Date
                            previousTime.value = curTime.getTime()
                            running.value = true
                            break;
                        case "running":
                            running.value = false
                            break;
                    }
                    console.log("from:" + mainPage.state + " " + elapsed.value + " " + running.value + " " + previousTime.value)
                }
        }

        IconButton {
            id: resetButton
            iconColor: "white"
            pressedIconColor: "lightgrey"
            iconName: "ios-refresh"
            visible: mainPage.state === "paused"

            hovered: false

            anchors {
                horizontalCenter: parent.horizontalCenter
                topMargin: Units.dp(8)
                top: parent.top
            }

            onClicked: elapsed.value = -1
        }
    }

    Timer {
        interval: 100
        repeat:  true
        running: mainPage.state == "running"
        triggeredOnStart: true

        onTriggered: {
            var currentTime = new Date
            var delta = (currentTime.getTime() - previousTime.value)
            previousTime.value = currentTime.getTime()
            elapsed.value += delta
        }
    }
}
