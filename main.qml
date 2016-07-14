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

Application {
    id: app

    property bool running
    property var previousTime
    property int elapsed: 0

    function zeroPad(n) {
        return (n < 10 ? "0" : "") + n
    }

    function toTimeString(usec) {
        var mod = Math.abs(usec)
        if (mod >= 3600000) {      // Hours + Minutes + Seconds
            return  '<font color=\"#FFFFFF\" size="3">' + Math.floor(mod / 3600000) + '<sup>h</sup>' + '<br></font>' +
                    '<font color=\"#F3BFB8\" size="1">' + zeroPad(Math.floor((mod % 3600000) / 60000)) + '<sup>m</sup>' +
                    zeroPad(Math.floor((mod % 60000) / 1000)) + '<sup>s</sup></font>'

        } else if (mod >= 60000) { // Minutes + Seconds + Tenth
            return '<font color="#FFFFFF" size="3">' + zeroPad(Math.floor((mod % 3600000) / 60000)) + '<sup>m</sup>' + '<br></font>' +
                   '<font color="#F3BFB8" size="1">' + zeroPad(Math.floor((mod % 60000) / 1000)) + '<sup>s</sup>' +
                   Math.floor((mod % 1000) / 100) + '</font>'
        } else {                   // Seconds + Tenth
            return '<font color="#FFF" size="3">' + zeroPad(Math.floor((mod % 60000) / 1000)) + '<sup>s</sup>' + '</font>' +
                   '<font color="#F3BFB8" size="1">' + Math.floor((mod % 1000) / 100) + '</font>'
        }
    }

    Item {
        anchors.fill: parent

        Rectangle {
            id: mainPage
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#F07060" }
                GradientStop { position: 1.0; color: "#DD5E4E" }
        }

        state: "zero"
        states: [
            State { name: "zero" },
            State { name: "running" },
            State { name: "paused" }
        ]

        Text {
            id: elapsedLabel
            textFormat: Text.RichText
            anchors.centerIn: parent
            text: toTimeString(elapsed)
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
                    switch (mainPage.state) {
                        case "zero":
                        case "paused":
                            previousTime = new Date;
                            stopwatch.start();
                            mainPage.state = "running";
                            break;
                        case "running":
                            mainPage.state = "paused";
                            stopwatch.stop();
                            break;
                    }
                }
            }

            IconButton {
                id: resetButton
                iconColor: "white"
                pressedIconColor: "lightgrey"
                iconName: "refresh-empty"
                visible: mainPage.state === "paused"

                hovered: false

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    topMargin: Units.dp(8)
                    top: parent.top
                }

                onClicked: {
                    elapsed = 0;
                    mainPage.state = "zero"
                }
            }
        }

        Timer {
            id: stopwatch

            interval: 100
            repeat:  true
            running: false
            triggeredOnStart: true

            onTriggered: {
                var currentTime = new Date
                var delta = (currentTime.getTime() - previousTime.getTime())
                previousTime = currentTime
                elapsed += delta
            }
        }
    }
}
