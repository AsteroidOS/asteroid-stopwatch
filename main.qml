/*
 * Copyright (C) 2015 Tim Süberkrüb <tim.sueberkrueb@web.de>
 * Part of this code is based on "Stopwatch" (https://github.com/baleboy/stopwatch)
 * Copyright (C) 2011 Francesco Balestrieri
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.3
import org.asteroid.controls 1.0

Application {
    id: app
    title: "Stopwatch"

    property bool running
    property var previousTime
    property int elapsed: 0

    function zeroPad(n) {
        return (n < 10 ? "0" : "") + n
    }

    function toTimeString(usec) {
        var mod = Math.abs(usec)
        return (usec < 0 ? "-" : "") +
                (mod >= 3600000 ? Math.floor(mod / 3600000) + ':' : '') +
                zeroPad(Math.floor((mod % 3600000) / 60000)) + ':' +
                zeroPad(Math.floor((mod % 60000) / 1000)) + '.' +
                Math.floor((mod % 1000) / 100)
    }

    Item {
        anchors.fill: parent

        Rectangle {
            id: mainPage
            anchors.fill: parent

            state: "zero"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            states: [
                State {
                    name: "zero"
                    PropertyChanges {
                        target: iconButton
                        iconName: "play"
                    }
                    PropertyChanges {
                        target: mainPage
                        color: "white"
                    }
                    PropertyChanges {
                        target: elapsedLabel
                        color: "black"
                    }
                },
                State {
                    name: "running"
                    PropertyChanges {
                        target: iconButton
                        iconName: "pause"
                    }
                    PropertyChanges {
                        target: mainPage
                        color: "#5469d5"
                    }
                },
                State {
                    name: "paused"
                    PropertyChanges {
                        target: iconButton
                        iconName: "play" }
                    PropertyChanges {
                        target: mainPage
                        color: "#d55469"
                    }
                }
            ]

            Label {
                id: elapsedLabel
                anchors.centerIn: parent
                color: mainPage.state === "zero" || "white"
                text: toTimeString(elapsed)
                font.pixelSize: Units.dp(17)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: iconButton.clicked();
            }

            IconButton {
                id: resetButton
                iconColor: "white"
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

            IconButton {
                id: iconButton
                iconName: "play"
                iconColor: mainPage.state === "zero" || "white"

                hovered: false

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: Units.dp(8)
                }

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
