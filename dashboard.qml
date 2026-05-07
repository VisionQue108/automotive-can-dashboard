import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 500
    height: 500
    title: "Digital Cluster"

    // ---------------------------
    // CALIBRATION
    // ---------------------------
    property int maxSpeed: 180
    property real startAngle: -120
    property real sweepAngle: 240

    function speedToAngle(speed) {
        return startAngle + (speed / maxSpeed) * sweepAngle
    }

    function degToRad(deg) {
        return deg * Math.PI / 180
    }

    Rectangle {
        anchors.fill: parent
        color: "#0b0b0b"

        // =========================
        // SPEEDOMETER
        // =========================
        Item {
            id: cluster
            anchors.centerIn: parent
            width: 320
            height: 320

            // -------- CANVAS ARC --------
            Canvas {
                id: dial
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var cx = width / 2
                    var cy = height / 2
                    var r = width / 2 - 20

                    var start = degToRad(startAngle)
                    var end = degToRad(startAngle + sweepAngle)

                    // ---- Background arc ----
                    ctx.beginPath()
                    ctx.lineWidth = 12
                    ctx.strokeStyle = "#333"
                    ctx.arc(cx, cy, r, start, end)
                    ctx.stroke()

                    // ---- Active arc ----
                    var speedEnd = degToRad(speedToAngle(backend.speed))

                    ctx.beginPath()
                    ctx.lineWidth = 12
                    ctx.lineCap = "round"
                    ctx.strokeStyle = backend.speed > 120 ? "#ff3b3b" : "#00c853"
                    ctx.arc(cx, cy, r, start, speedEnd)
                    ctx.stroke()
                }
            }

            // -------- NEEDLE --------
            Rectangle {
                id: needle
                width: 4
                height: 120
                radius: 2
                color: "red"

                anchors.centerIn: parent

                transform: Rotation {
                    origin.x: needle.width / 2
                    origin.y: needle.height - 10   // pivot fix

                    angle: speedToAngle(backend.speed)

                    Behavior on angle {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // -------- CENTER HUB --------
            Rectangle {
                width: 16
                height: 16
                radius: 8
                color: "white"
                anchors.centerIn: parent
            }

            // -------- SPEED TEXT --------
            Text {
                text: backend.speed + " km/h"
                color: "white"
                font.pixelSize: 28

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.verticalCenter
                anchors.topMargin: 40
            }
        }

        // =========================
        // BATTERY BAR
        // =========================
        Column {
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Rectangle {
                width: 40
                height: 160
                radius: 20
                color: "#333"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * backend.battery / 100
                    radius: 20
                    color: "#00c853"
                }
            }

            Text {
                text: backend.battery + "%"
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // =========================
    // FORCE CANVAS UPDATE
    // =========================
    Connections {
        target: backend
        function onSpeedChanged() {
            dial.requestPaint()
        }
    }
}
