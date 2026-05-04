import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: root
    visible: true
    width: 500
    height: 500
    minimumWidth: 500
    maximumWidth: 500
    minimumHeight: 500
    maximumHeight: 500
    title: "Digital Cluster"

    property int displaySpeed: 0

    Rectangle {
        anchors.fill: parent
        color: "#000000"

        Item {
            anchors.centerIn: parent
            width: 320
            height: 320

            Canvas {
                id: dial
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var cx = width/2
                    var cy = height/2

                    var start = Math.PI * 0.75
                    var end   = Math.PI * 2.25
                    var range = end - start

                    // ======================
                    // SPEED ARC
                    // ======================
                    var r1 = width/2 - 15

                    ctx.beginPath()
                    ctx.lineWidth = 10
                    ctx.strokeStyle = "#333"
                    ctx.arc(cx, cy, r1, start, end)
                    ctx.stroke()

                    var angle = start + (displaySpeed / 180) * range

                    ctx.beginPath()
                    ctx.strokeStyle = displaySpeed > 120 ? "red" : "#00c853"
                    ctx.arc(cx, cy, r1, start, angle)
                    ctx.stroke()

                    // ======================
                    // SPEED TICKS + NUMBERS
                    // ======================
                    for (var i = 0; i <= 180; i += 10) {

                        var a = start + (i / 180) * range

                        var inner = r1 - (i % 20 === 0 ? 18 : 10)
                        var outer = r1

                        var x1 = cx + inner * Math.cos(a)
                        var y1 = cy + inner * Math.sin(a)
                        var x2 = cx + outer * Math.cos(a)
                        var y2 = cy + outer * Math.sin(a)

                        ctx.beginPath()
                        ctx.lineWidth = (i % 20 === 0) ? 2 : 1
                        ctx.strokeStyle = "white"
                        ctx.moveTo(x1, y1)
                        ctx.lineTo(x2, y2)
                        ctx.stroke()

                        // --- NUMBERS ---
                        if (i % 20 === 0) {
                            var tx = cx + (r1 - 35) * Math.cos(a)
                            var ty = cy + (r1 - 35) * Math.sin(a)

                            ctx.fillStyle = "white"
                            ctx.font = "11px sans-serif"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"

                            ctx.fillText(i.toString(), tx, ty)
                        }
                    }

                    // ======================
                    // FUEL ARC (INNER)
                    // ======================
                    var r2 = r1 - 65   // smaller inner ring 
                    ctx.lineWidth = 5  

                    ctx.beginPath()
                    ctx.lineWidth = 8
                    ctx.strokeStyle = "#333"
                    ctx.arc(cx, cy, r2, start, end)
                    ctx.stroke()

                    var fAngle = start + (backend.fuel / 100) * range

                    ctx.beginPath()
                    ctx.strokeStyle = "orange"
                    ctx.arc(cx, cy, r2, start, fAngle)
                    ctx.stroke()

                    // ======================
                    // FUEL TICKS + %
                    // ======================
                    for (var j = 0; j <= 100; j += 10) {

                        var a2 = start + (j / 100) * range

                        var inner2 = r2 - (j % 20 === 0 ? 12 : 6)
                        var outer2 = r2

                        var fx1 = cx + inner2 * Math.cos(a2)
                        var fy1 = cy + inner2 * Math.sin(a2)
                        var fx2 = cx + outer2 * Math.cos(a2)
                        var fy2 = cy + outer2 * Math.sin(a2)

                        ctx.beginPath()
                        ctx.lineWidth = (j % 20 === 0) ? 2 : 1
                        ctx.strokeStyle = "orange"
                        ctx.moveTo(fx1, fy1)
                        ctx.lineTo(fx2, fy2)
                        ctx.stroke()

                        // % labels (only major)
                        if (j % 20 === 0) {
                            var ftx = cx + (r2 - 25) * Math.cos(a2)
                            var fty = cy + (r2 - 25) * Math.sin(a2)

                            ctx.fillStyle = "orange"
                            ctx.font = "10px sans-serif"
                            ctx.fillText(j.toString(), ftx, fty)
                        }
                    }
                }
            }

            // ======================
            // NEEDLE
            // ======================
            Rectangle {
                width: 4
                height: 120
                color: "red"
                radius: 2
                anchors.centerIn: parent

                transform: Rotation {
                    origin.x: 2
                    origin.y: 120
                    angle: -135 + (displaySpeed / 180) * 270
                }
            }

            // Pivot
            Rectangle {
                width: 14
                height: 14
                radius: 7
                color: "white"

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 60
            }

            // Speed text
            Text {
                text: displaySpeed + " km/h"
                color: "white"
                font.pixelSize: 26

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.verticalCenter
                anchors.topMargin: 90
            }
        }

        // ======================
        // BATTERY BAR
        // ======================
        Rectangle {
        id: batteryBg
            width: 30
            height: 200
            radius: 10
            color: "#222"

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 30

            Rectangle {
                width: parent.width
                height: Math.max(0, Math.min(backend.battery, 100) / 100 * parent.height)
                anchors.bottom: parent.bottom
                radius: 10
                color: "#00c853"
            }
        }
    }
    
	Text {
	    text: backend.battery + "%"
	    color: "lightgreen"
	    font.pixelSize: 12

	    anchors.bottom: batteryBg.bottom
	    anchors.topMargin: 6
	}

    // ======================
    // STARTUP SWEEP
    // ======================
    SequentialAnimation {
        running: true

        NumberAnimation { target: root; property: "displaySpeed"; from: 0; to: 180; duration: 900 }
        NumberAnimation { target: root; property: "displaySpeed"; from: 180; to: 0; duration: 700 }
        NumberAnimation { target: root; property: "displaySpeed"; to: backend.speed; duration: 400 }
    }

    Connections {
        target: backend

        function onSpeedChanged() {
            displaySpeed = backend.speed
            dial.requestPaint()
        }
    }
}
