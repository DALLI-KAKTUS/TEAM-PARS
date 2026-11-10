// ui/views/overview/cockpit/CenterCommandPanel.qml
// Kokpitin sol ve sağ kanatları arasında kalan merkez komuta alanı.
// 4 ana katmandan oluşur:
// 1. Arka Planda 3B Tünel Akışı (`Tunnel3DRingsCanvas`): Arkadan öne doğru akan
//    perspektif tünel halkaları.
// 2. Ana Komut Halkaları (`E-START` ve `E-STOP`): Tünelin tam kaçış noktasına
//    hizalanmış, etrafında dönen nişangah yayları olan başlatma ve acil durdurma butonları.
// 3. Yönelim ve Sıfırlama Satırı: Yapay ufuk (`horizonCanvas`), Roll-Pitch-Yaw açıları
//    ve kapsül durduğunda beliren "0 m SIFIRLA" butonu.
// 4. Termal Özet ve Sistem Durumu: LIM Motor, Sürücü/İnvertör ve Ray ΔT sıcaklıkları
//    ile en alttaki telemetri/CAN-FD kayıt bilgisi.
import QtQuick
import ParsHyperloop

Item {
    id: centerCockpitZone
    clip: true

    // Dışarıdan bağlanan durum, yönelim, sıcaklık ve animasyon parametreleri
    property string runState: "STANDBY"
    property bool isSweeping: false
    property bool linkOk: true
    property bool motorEnabled: true
    property real simDistance: 0.0
    property real displaySpeedKmh: 0.0
    property int litReflectors: 0
    property int reflectorTotal: 46
    property int logRateHz: 30

    property real rollDeg: 0.0
    property real pitchDeg: 0.0
    property real yawDeg: 0.0

    property real displayMotorTempC: 27.0
    property real displayDriverTempC: 29.0
    property real railDeltaT: 0.0

    property real tunnelTravelPhase: 0.0
    property real tunnelLightWave: 0.0
    property real reticleSweepAngle: 0.0
    property real liveOrbitAngle: 0.0

    signal eStartClicked()
    signal eStopClicked()
    signal resetTrackClicked()

    // E-START ve E-STOP halkalarının çapı ve dikey merkez konumu
    readonly property real ringDiameter: Math.min(width * 0.35, height * 0.41, 134)
    readonly property real ringsCenterY: Math.max(ringDiameter * 0.5 + 34, height * 0.39)

    // E-START veya E-STOP'a basıldığında dışa doğru yayılan beyaz dalga halkasını tetikler
    function triggerEStartPulse() {
        eStartPulseAnim.restart()
    }

    function triggerEStopPulse() {
        eStopPulseAnim.restart()
    }

    onLiveOrbitAngleChanged: eStartReticleCanvas.requestPaint()
    onReticleSweepAngleChanged: {
        eStartReticleCanvas.requestPaint()
        eStopReticleCanvas.requestPaint()
    }
    onPitchDegChanged: horizonCanvas.requestPaint()
    onRollDegChanged: horizonCanvas.requestPaint()

    // -------------------------------------------------------------------------
    // 1. ARKA PLAN: 3B PERSPEKTİF TÜNEL VE REFLEKTÖR IŞIKLARI
    // -------------------------------------------------------------------------
    Tunnel3DRingsCanvas {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        ringsCenterY: centerCockpitZone.ringsCenterY
        ringDiameter: centerCockpitZone.ringDiameter
        tunnelTravelPhase: centerCockpitZone.tunnelTravelPhase
        tunnelLightWave: centerCockpitZone.tunnelLightWave
        displaySpeedKmh: centerCockpitZone.displaySpeedKmh
        isSweeping: centerCockpitZone.isSweeping
        litReflectors: centerCockpitZone.litReflectors
        reflectorTotal: centerCockpitZone.reflectorTotal
    }

    // -------------------------------------------------------------------------
    // 2. MERKEZ KOMUT HALKALARI: E-START (SOL) VE E-STOP (SAĞ)
    // -------------------------------------------------------------------------
    Row {
        id: commandRingsRow
        anchors.horizontalCenter: parent.horizontalCenter
        y: centerCockpitZone.ringsCenterY - height * 0.5
        spacing: Math.max(28, parent.width * 0.075)

        // SOL HALKASI: E-START (BAŞLAT)
        // Bağlantı veya Motor kapalıysa (`!canStart`) siyah zemine dönüp "KİLİTLİ" yazar.
        Item {
            id: eStartBtn
            width: centerCockpitZone.ringDiameter
            height: centerCockpitZone.ringDiameter

            scale: eStartMouse.pressed ? 0.95 : (eStartMouse.containsMouse ? 1.03 : 1.0)
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            // Arkadaki tünel çizgilerinin butonla karışmasını önleyen siyah gölge halesi
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 22
                height: parent.height + 22
                radius: width / 2
                color: "#000000"
                opacity: 0.88
            }

            // Tıklandığında dışarı doğru büyüyerek sönen dalga halkası
            Rectangle {
                id: eStartPulseRing
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                radius: width / 2
                color: "transparent"
                border.color: "#FFFFFF"
                border.width: 1.5
                opacity: 0.0

                ParallelAnimation {
                    id: eStartPulseAnim
                    NumberAnimation { target: eStartPulseRing; property: "scale"; from: 0.95; to: 1.32; duration: 480; easing.type: Easing.OutCubic }
                    NumberAnimation { target: eStartPulseRing; property: "opacity"; from: 0.85; to: 0.0; duration: 480; easing.type: Easing.OutCubic }
                }
            }

            // Butonun etrafında 90'ar derece arayla çizilen 4 parçalı dönen nişangah çemberi
            Canvas {
                id: eStartReticleCanvas
                anchors.centerIn: parent
                width: parent.width + 18
                height: parent.height + 18
                rotation: centerCockpitZone.reticleSweepAngle + centerCockpitZone.liveOrbitAngle
                onWidthChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var cx = width / 2
                    var cy = height / 2
                    var r = width / 2 - 2

                    ctx.lineWidth = 1.5
                    ctx.strokeStyle = eStartMouse.containsMouse ? "#FFFFFF" : "rgba(255, 255, 255, 0.56)"

                    for (var k = 0; k < 4; k++) {
                        var a0 = (k * 90 - 20) * Math.PI / 180
                        var a1 = (k * 90 + 20) * Math.PI / 180
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, a0, a1, false)
                        ctx.stroke()
                    }
                }
            }

            // Ana yuvarlak buton gövdesi
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#000000"
                border.color: "#FFFFFF"
                border.width: 1.8

                Rectangle {
                    readonly property bool canStart: centerCockpitZone.linkOk && centerCockpitZone.motorEnabled
                    anchors.centerIn: parent
                    width: parent.width * 0.82
                    height: width
                    radius: width / 2
                    color: !canStart ? "#000000" : (eStartMouse.containsMouse ? "#EFEFEF" : "#FFFFFF")
                    border.color: "#FFFFFF"
                    border.width: canStart ? 0 : 1.5

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "E-START"
                            color: parent.parent.canStart ? "#000000" : Qt.rgba(1, 1, 1, 0.55)
                            font.family: Colors.fontFamily
                            font.pixelSize: Math.max(13, eStartBtn.width * 0.125)
                            font.weight: Font.Black
                            font.letterSpacing: 1.4
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: eStartBtn.width * 0.36
                            height: 1.5
                            color: parent.parent.canStart ? "#000000" : Qt.rgba(1, 1, 1, 0.45)
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: !parent.parent.canStart ? "KİLİTLİ"
                                                          : (centerCockpitZone.runState === "RUNNING" ? "AKTİF" : "BAŞLAT")
                            color: parent.parent.canStart ? "#000000" : Qt.rgba(1, 1, 1, 0.55)
                            font.family: Colors.fontFamily
                            font.pixelSize: Math.max(9, eStartBtn.width * 0.068)
                            font.weight: Font.Bold
                            font.letterSpacing: 1.5
                        }
                    }
                }
            }

            MouseArea {
                id: eStartMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: (centerCockpitZone.linkOk && centerCockpitZone.motorEnabled) ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                onClicked: centerCockpitZone.eStartClicked()
                onContainsMouseChanged: eStartReticleCanvas.requestPaint()
            }
        }

        // SAĞ HALKASI: E-STOP (ACİL DURDURMA)
        // Normalde siyah zemin üzerine beyaz yazılıdır; devreye girdiğinde (`runState === "ESTOP"`)
        // tam beyaz zemine dönerek operatöre görsel kilit onayı verir.
        Item {
            id: eStopBtn
            width: centerCockpitZone.ringDiameter
            height: centerCockpitZone.ringDiameter

            scale: eStopMouse.pressed ? 0.95 : (eStopMouse.containsMouse ? 1.03 : 1.0)
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 22
                height: parent.height + 22
                radius: width / 2
                color: "#000000"
                opacity: 0.88
            }

            Rectangle {
                id: eStopPulseRing
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                radius: width / 2
                color: "transparent"
                border.color: "#FFFFFF"
                border.width: 1.5
                opacity: 0.0

                ParallelAnimation {
                    id: eStopPulseAnim
                    NumberAnimation { target: eStopPulseRing; property: "scale"; from: 0.95; to: 1.32; duration: 480; easing.type: Easing.OutCubic }
                    NumberAnimation { target: eStopPulseRing; property: "opacity"; from: 0.85; to: 0.0; duration: 480; easing.type: Easing.OutCubic }
                }
            }

            Canvas {
                id: eStopReticleCanvas
                anchors.centerIn: parent
                width: parent.width + 18
                height: parent.height + 18
                rotation: -centerCockpitZone.reticleSweepAngle
                onWidthChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var cx = width / 2
                    var cy = height / 2
                    var r = width / 2 - 2

                    ctx.lineWidth = 1.5
                    ctx.strokeStyle = eStopMouse.containsMouse ? "#FFFFFF" : "rgba(255, 255, 255, 0.56)"

                    for (var k = 0; k < 4; k++) {
                        var a0 = (k * 90 + 25) * Math.PI / 180
                        var a1 = (k * 90 + 65) * Math.PI / 180
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, a0, a1, false)
                        ctx.stroke()
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#000000"
                border.color: "#FFFFFF"
                border.width: 1.8

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.82
                    height: width
                    radius: width / 2
                    color: centerCockpitZone.runState === "ESTOP" ? "#FFFFFF" : "#000000"
                    border.color: "#FFFFFF"
                    border.width: 2.4

                    Behavior on color { ColorAnimation { duration: 180 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "E-STOP"
                            color: centerCockpitZone.runState === "ESTOP" ? "#000000" : "#FFFFFF"
                            font.family: Colors.fontFamily
                            font.pixelSize: Math.max(13, eStopBtn.width * 0.125)
                            font.weight: Font.Black
                            font.letterSpacing: 1.4
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: eStopBtn.width * 0.42
                            height: 1.5
                            color: centerCockpitZone.runState === "ESTOP" ? "#000000" : Qt.rgba(1, 1, 1, 0.65)
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "ACİL DURDURMA"
                            color: centerCockpitZone.runState === "ESTOP" ? "#000000" : "#FFFFFF"
                            font.family: Colors.fontFamily
                            font.pixelSize: Math.max(8, eStopBtn.width * 0.058)
                            font.weight: Font.Bold
                            font.letterSpacing: 0.8
                        }
                    }
                }
            }

            MouseArea {
                id: eStopMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: centerCockpitZone.eStopClicked()
                onContainsMouseChanged: eStopReticleCanvas.requestPaint()
            }
        }
    }

    // -------------------------------------------------------------------------
    // 3. YÖNELİM (R·P·Y), "0 m SIFIRLA" BUTONU VE TERMAL ÖZET TABLOSU
    // -------------------------------------------------------------------------
    Column {
        id: centerInfoColumn
        anchors {
            top: commandRingsRow.bottom
            topMargin: 16
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 6

        // Üst satır: Yapay ufuk ikonu, Roll/Pitch/Yaw açıları ve Sıfırlama butonu
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            height: 20

            // Kapsülün yunuslama (pitch) ve yatış (roll) açılarına göre eğilen yapay ufuk çizgisi
            Canvas {
                id: horizonCanvas
                width: 54
                height: 18
                anchors.verticalCenter: parent.verticalCenter

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var cx = width / 2
                    var cy = height / 2

                    // Yan sabit ufuk referans çizgileri
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.38)"
                    ctx.lineWidth = 1.2
                    ctx.beginPath()
                    ctx.moveTo(2, cy); ctx.lineTo(12, cy)
                    ctx.moveTo(width - 12, cy); ctx.lineTo(width - 2, cy)
                    ctx.stroke()

                    // Kapsül kanat ve merkez nokta çizgisi
                    ctx.save()
                    ctx.translate(cx, cy + centerCockpitZone.pitchDeg * 3.0)
                    ctx.rotate(centerCockpitZone.rollDeg * Math.PI / 180)
                    ctx.strokeStyle = "#FFFFFF"
                    ctx.lineWidth = 1.8
                    ctx.beginPath()
                    ctx.moveTo(-13, 0); ctx.lineTo(-4, 0)
                    ctx.moveTo(4, 0); ctx.lineTo(13, 0)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(0, 0, 2.0, 0, Math.PI * 2)
                    ctx.fillStyle = "#FFFFFF"
                    ctx.fill()
                    ctx.restore()
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "R " + centerCockpitZone.rollDeg.toFixed(1) + "°   ·   P " +
                      (centerCockpitZone.pitchDeg >= 0 ? "+" : "") + centerCockpitZone.pitchDeg.toFixed(1) + "°   ·   Y " +
                      centerCockpitZone.yawDeg.toFixed(1) + "°"
                color: Qt.rgba(1, 1, 1, 0.75)
                font.family: Colors.fontFamily
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 0.7
            }

            // Kapsül 0.5 metreden ileri gittikten sonra durduğunda beliren sıfırlama butonu
            Rectangle {
                visible: !centerCockpitZone.isSweeping && centerCockpitZone.runState !== "RUNNING" && centerCockpitZone.simDistance > 0.5
                width: resetTxt.implicitWidth + 16
                height: 20
                radius: 10
                color: resetMouse.containsMouse ? "#FFFFFF" : "#000000"
                border.color: "#FFFFFF"
                border.width: 1.2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: resetTxt
                    anchors.centerIn: parent
                    text: "0 m SIFIRLA"
                    color: resetMouse.containsMouse ? "#000000" : "#FFFFFF"
                    font.family: Colors.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.Black
                    font.letterSpacing: 0.6
                }

                MouseArea {
                    id: resetMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: centerCockpitZone.resetTrackClicked()
                }
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300
            height: 1
            color: Qt.rgba(1, 1, 1, 0.18)
        }

        // Alt satır: LIM Motor, Sürücü/İnvertör ve Ray ΔT sıcaklık göstergeleri
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 22

            Column {
                spacing: 1
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "LIM MOTOR"
                    color: Qt.rgba(1, 1, 1, 0.58)
                    font.family: Colors.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Math.round(centerCockpitZone.displayMotorTempC) + "°C"
                    color: "#FFFFFF"
                    font.family: Colors.fontFamily
                    font.pixelSize: 19
                    font.weight: Font.Black
                }
            }

            Rectangle {
                width: 1
                height: 26
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(1, 1, 1, 0.18)
            }

            Column {
                spacing: 1
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SÜRÜCÜ / İNV."
                    color: Qt.rgba(1, 1, 1, 0.58)
                    font.family: Colors.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Math.round(centerCockpitZone.displayDriverTempC) + "°C"
                    color: "#FFFFFF"
                    font.family: Colors.fontFamily
                    font.pixelSize: 19
                    font.weight: Font.Black
                }
            }

            Rectangle {
                width: 1
                height: 26
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(1, 1, 1, 0.18)
            }

            Column {
                spacing: 1
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "RAY ΔT  (≤ 30°C)"
                    color: Qt.rgba(1, 1, 1, 0.58)
                    font.family: Colors.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "+" + centerCockpitZone.railDeltaT.toFixed(1) + "°C"
                    color: "#FFFFFF"
                    font.family: Colors.fontFamily
                    font.pixelSize: 19
                    font.weight: Font.Black
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // 4. EN ALT BİLGİ SATIRI: TELEMETRİ BAĞLANTISI VE CAN-FD KAYIT HIZI
    // Ortadaki dikey geçiş okunun soluna ve sağına simetrik olarak yerleştirildi.
    // -------------------------------------------------------------------------
    Text {
        anchors {
            bottom: parent.bottom
            bottomMargin: 2
            right: parent.horizontalCenter
            rightMargin: 58
        }
        text: "SİSTEM TELEMETRİSİ: " + (centerCockpitZone.linkOk ? "AKTİF" : "KESİNTİ")
        color: Qt.rgba(1, 1, 1, 0.56)
        font.family: Colors.fontFamily
        font.pixelSize: 9
        font.weight: Font.Bold
        font.letterSpacing: 0.6
    }

    Text {
        anchors {
            bottom: parent.bottom
            bottomMargin: 2
            left: parent.horizontalCenter
            leftMargin: 58
        }
        text: "VERİ KAYDI: " + centerCockpitZone.logRateHz + " Hz · CAN-FD"
        color: Qt.rgba(1, 1, 1, 0.56)
        font.family: Colors.fontFamily
        font.pixelSize: 9
        font.weight: Font.Bold
        font.letterSpacing: 0.6
    }
}
