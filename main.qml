/*
 * Qt Quick Controls Asteroid - User interface components for AsteroidOS
 *
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
import quey.ui 0.1
import quey.watch 0.1
import org.asteroid.controls 1.0
import Qt.labs.settings 1.0


WatchApplication {
    id: app
    title: "Stopwatch"

    property bool running
    property var previousTime
    property int elapsed: 0

    property bool colorful: true

    Settings {
        id: settings
        property alias colorful: app.colorful
    }


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

    LayerStack {
        id: watchLayerStack

        Layer {
            id: settingsLayer
            Rectangle {
                anchors.fill: parent
                color: Style.palette.background

                Flickable {
                    anchors.fill: parent
                    interactive: false

                    contentWidth: parent.width
                    contentHeight: childrenRect.height

                    Column {
                        spacing: Style.spacing
                        anchors {
                            fill: parent
                            topMargin: Style.padding
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Settings"
                            font: Style.font.subheading
                        }

                        CheckBox {
                            id: checkboxColorful
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Colorful"
                            checked: app.colorful
                            onCheckedChanged: app.colorful = checked
                        }
                    }

                }

            }

        }

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
                        iconName: "media-play"
                    }
                    PropertyChanges {
                        target: mainPage
                        color: Style.palette.background
                    }
                },
                State {
                    name: "running"
                    PropertyChanges {
                        target: iconButton
                        iconName: "media-pause"
                    }
                    PropertyChanges {
                        target: mainPage
                        color: app.colorful ? Style.palette.green : Style.palette.background
                    }
                },
                State {
                    name: "paused"
                    PropertyChanges {
                        target: iconButton
                        iconName: "media-play"
                    }
                    PropertyChanges {
                        target: mainPage
                        color: app.colorful ? Style.palette.red : Style.palette.background
                    }
                }
            ]

            Label {
                anchors.centerIn: parent
                color: mainPage.state === "zero" || !app.colorful ? Style.palette.regular : "white"
                font: Style.font.code
                text: toTimeString(elapsed)
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    iconButton.clicked();
                }
            }

            IconButton {
                id: resetButton
                iconColor: app.colorful ? "white" : Style.palette.regular
                iconName: "reload"
                visible: mainPage.state === "paused"

                hovered: false

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    topMargin: Style.padding
                    top: parent.top
                }

                onClicked: {
                    elapsed = 0;
                    mainPage.state = "zero"
                }
            }

            IconButton {
                id: settingsButton
                iconColor: Style.palette.regular
                iconName: "cog"
                visible: mainPage.state === "zero"

                hovered: false

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    topMargin: Style.padding
                    top: parent.top
                }

                onClicked: {
                    settingsLayer.show();
                }
            }

            IconButton {
                id: iconButton
                iconName: "media-play"
                iconColor: mainPage.state === "zero" || !app.colorful ? Style.palette.regular : "white"

                hovered: false

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: Style.padding
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
