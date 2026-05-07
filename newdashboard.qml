import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15

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
       // =========================
        // DASHCAM PIP (Picture-in-Picture)
        // =========================
        Rectangle {
            id: dashcamPanel
            width: 160
            height: 120 // 4:3 aspect ratio
            
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 20
            
            color: "#1a1a1a"
            border.color: "#333333"
            border.width: 2
            radius: 8
            clip: true // Keeps the video cleanly inside the rounded corners

            // --- THE GSTREAMER PIPELINE ---
            MediaPlayer {
                id: dashcam
                source: "gst-pipeline: v4l2src device=/dev/video0 ! image/jpeg,width=640,height=480 ! jpegdec ! videoconvert ! tee name=t t. ! queue ! qtvideosink t. ! queue ! x264enc tune=zerolatency ! matroskamux ! filesink location=/home/naresa/car_project/dashcam_save/latest_recording.mkv"
                autoPlay: true
            }

            // --- THE DISPLAY ---
            VideoOutput {
                anchors.fill: parent
                source: dashcam
                fillMode: VideoOutput.PreserveAspectCrop
            }

            // --- THE BLINKING 'REC' INDICATOR ---
            Row {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 8
                spacing: 5
                
                visible: dashcam.playbackState === MediaPlayer.PlayingState

                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: "#ff3b30"
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.2; duration: 800; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                    }
                }

                Text {
                    text: "REC"
                    color: "#ff3b30"
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
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

                    var start = Math.PI * 1
                    var end   = Math.PI * 2 
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

                    var angle = start + (displaySpeed / 120) * range

                    ctx.beginPath()
                    ctx.strokeStyle = displaySpeed > 90 ? "red" : "#00c853"
                    ctx.arc(cx, cy, r1, start, angle)
                    ctx.stroke()

                    // ======================
                    // SPEED TICKS + NUMBERS
                    // ======================
                    for (var i = 0; i <= 120; i += 10) {

                        var a = start + (i / 120) * range

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

                            ctx.fillStyle = "white"
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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter

                transform: Rotation {
		    origin.x: 2
		    origin.y: 120 // Rotates around the bottom of the needle
		    angle: 270 + (Math.min(displaySpeed, 120) / 120) * 180 
		}
            }

            // Pivot
            Rectangle {
                width: 14
                height: 14
                radius: 7
                color: "white"
		anchors.centerIn: parent
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
    

    // ======================
    // STARTUP SWEEP
    // ======================
    SequentialAnimation {
        running: true

        NumberAnimation { target: root; property: "displaySpeed"; from: 0; to: 120; duration: 900 }
        NumberAnimation { target: root; property: "displaySpeed"; from: 120; to: 0; duration: 700 }
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
