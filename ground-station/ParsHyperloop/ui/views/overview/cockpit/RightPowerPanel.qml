// ui/views/overview/cockpit/RightPowerPanel.qml
// Yarışma kokpitinin sağ kanadı (Sol hız kanadının ayna simetriğidir).
// İçerisinde 5 ana bölüm yer alır:
// 1. Pahlı Sağ Kanat Çerçevesi: Kanadın dış sınırlarını çizen Canvas.
// 2. LIM Motor Gücü Kadranı (`powerArcCanvas`): 0 - 80 kW arası 41 çentikli güç kadranı.
// 3. Güç Tüketimi Sütunu: Kadranın sol boşluğunda çekilen anlık akım (A) ve harcanan enerji (Wh).
// 4. Canlı Güç Profili Grafiği (`OscilloscopeGraph`): Motor gücünün zamanla değişim eğrisi.
// 5. Batarya, Fren ve Tank Basıncı: 8 hücreli animasyonlu batarya ikonu (`BatteryCellsCanvas`),
//    SOC %, paket voltajı, hücre sıcaklıkları ve en altta fren kuvveti (%) ile tank basıncı (bar).
import QtQuick
import ParsHyperloop

Item {
    id: rightGaugeWing

    // Dışarıdan bağlanan güç, batarya, fren ve grafik parametreleri
    property real displayMotorPowerKw: 0.0
    property real maxMotorPowerKw: 80.0
    property int displayPowerPercent: 0
    property real peakPowerKw: 0.0
    property real simCurrentA: 0.0
    property real simEnergyWh: 0.0

    property real displayBatteryPercent: 98.0
    property real displayPackVoltage: 110.8
    property real batteryTemp1: 28.0
    property real batteryTemp2: 29.0
    property real battAnimPhase: 0.0

    property real displayBrakePercent: 100.0
    property real displayTankBar: 8.2

    property var powerHistory: []
    property int historyRevision: 0

    // Kadran yarıçapı ve merkez koordinatları (Sol kanat ile tam simetrik)
    readonly property real dialR: Math.min(width * 0.255, height * 0.268, 88)
    readonly property real dialCx: width * 0.57
    readonly property real dialCy: dialR + 14

    onDisplayMotorPowerKwChanged: powerArcCanvas.requestPaint()

    // -------------------------------------------------------------------------
    // 1. SAĞ KANAT DIŞ ÇERÇEVE ÇİZGİLERİ
    // -------------------------------------------------------------------------
    Canvas {
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width
            var h = height

            // İnce yarı saydam dış poligon çerçeve
            ctx.beginPath()
            ctx.moveTo(w - 32, 4)
            ctx.lineTo(6, 4)
            ctx.lineTo(32, 30)
            ctx.lineTo(32, h - 52)
            ctx.lineTo(8, h - 22)
            ctx.lineTo(20, h - 6)
            ctx.lineTo(w - 18, h - 6)
            ctx.lineTo(w - 2, h - 22)
            ctx.lineTo(w - 2, 34)
            ctx.closePath()
            ctx.lineWidth = 1.2
            ctx.strokeStyle = "rgba(255, 255, 255, 0.22)"
            ctx.stroke()

            // Sağ üst köşe ve alt tabandaki kalın beyaz vurgu hatları
            ctx.lineWidth = 2.4
            ctx.strokeStyle = "#FFFFFF"

            ctx.beginPath()
            ctx.moveTo(w - 2, 56)
            ctx.lineTo(w - 2, 34)
            ctx.lineTo(w - 32, 4)
            ctx.lineTo(w - 70, 4)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(26, h - 6)
            ctx.lineTo(w - 24, h - 6)
            ctx.stroke()
        }
    }

    // -------------------------------------------------------------------------
    // 2. 41 SEGMANLI LIM MOTOR GÜCÜ KADRANI (0 - 80 kW)
    // 214 dereceden 406 dereceye uzanan yay üzerinde 41 çentik çizer. Her 5
    // çentikte bir ana bölmeyi daha uzun ve kalın olarak vurgular.
    // -------------------------------------------------------------------------
    Canvas {
        id: powerArcCanvas
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var cx = rightGaugeWing.dialCx
            var cy = rightGaugeWing.dialCy
            var radius = rightGaugeWing.dialR

            var startRad = 214 * Math.PI / 180
            var endRad = 406 * Math.PI / 180
            var totalTicks = 41
            var ratio = Math.max(0.0, Math.min(1.0, rightGaugeWing.displayMotorPowerKw / rightGaugeWing.maxMotorPowerKw))
            var activeTicks = Math.round(ratio * totalTicks)

            // Dış ince yay
            ctx.beginPath()
            ctx.arc(cx, cy, radius + 6, startRad, endRad, false)
            ctx.lineWidth = 1.2
            ctx.strokeStyle = "rgba(255, 255, 255, 0.35)"
            ctx.stroke()

            // İç ince yay
            ctx.beginPath()
            ctx.arc(cx, cy, radius - 22, startRad + 0.08, endRad - 0.08, false)
            ctx.lineWidth = 1.0
            ctx.strokeStyle = "rgba(255, 255, 255, 0.18)"
            ctx.stroke()

            // 41 adet güç çentiği
            for (var i = 0; i < totalTicks; i++) {
                var t = i / (totalTicks - 1)
                var ang = startRad + t * (endRad - startRad)
                var isMajor = (i % 5 === 0)
                var len = isMajor ? 16 : 10

                ctx.beginPath()
                ctx.moveTo(cx + (radius - len) * Math.cos(ang), cy + (radius - len) * Math.sin(ang))
                ctx.lineTo(cx + radius * Math.cos(ang), cy + radius * Math.sin(ang))
                ctx.lineWidth = isMajor ? 2.5 : 1.5
                ctx.strokeStyle = (i < activeTicks) ? "#FFFFFF" : "rgba(255, 255, 255, 0.15)"
                ctx.stroke()
            }
        }
    }

    // Kadranın ortasındaki sayısal güç (kW) ve yük yüzdesi (% YÜK · LIM)
    Column {
        x: rightGaugeWing.dialCx - width / 2
        y: rightGaugeWing.dialCy - height / 2 + 2
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "MOTOR GÜCÜ"
            color: Qt.rgba(1, 1, 1, 0.68)
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 1.5
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: rightGaugeWing.displayMotorPowerKw.toFixed(1)
            color: "#FFFFFF"
            font.family: Colors.fontFamily
            font.pixelSize: 38
            font.weight: Font.Black
            font.features: { "tnum": 1 }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "kW"
            color: "#FFFFFF"
            font.family: Colors.fontFamily
            font.pixelSize: 12
            font.weight: Font.Bold
            font.letterSpacing: 0.8
        }

        Item { width: 1; height: 2 }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "YÜK %" + rightGaugeWing.displayPowerPercent + "  ·  LIM"
            color: Qt.rgba(1, 1, 1, 0.56)
            font.family: Colors.fontFamily
            font.pixelSize: 9
            font.weight: Font.Bold
            font.letterSpacing: 0.5
        }
    }

    // -------------------------------------------------------------------------
    // 3. KADRAN SOL SEKTÖRÜ: ANLIK AKIM (A) VE HARCANAN ENERJİ (Wh)
    // -------------------------------------------------------------------------
    Column {
        x: 40
        y: rightGaugeWing.dialCy - 20
        spacing: 4

        Text {
            text: "GÜÇ TÜKETİMİ"
            color: Qt.rgba(1, 1, 1, 0.45)
            font.family: Colors.fontFamily
            font.pixelSize: 8
            font.weight: Font.Bold
            font.letterSpacing: 0.9
        }

        Column {
            spacing: 0
            Text {
                text: "AKIM"
                color: Qt.rgba(1, 1, 1, 0.5)
                font.family: Colors.fontFamily
                font.pixelSize: 8
                font.weight: Font.Bold
                font.letterSpacing: 0.8
            }
            Text {
                text: Math.round(rightGaugeWing.simCurrentA) + " A"
                color: "#FFFFFF"
                font.family: Colors.fontFamily
                font.pixelSize: 13
                font.weight: Font.Black
                font.features: { "tnum": 1 }
            }
        }

        Column {
            spacing: 0
            Text {
                text: "ENERJİ"
                color: Qt.rgba(1, 1, 1, 0.5)
                font.family: Colors.fontFamily
                font.pixelSize: 8
                font.weight: Font.Bold
                font.letterSpacing: 0.8
            }
            Text {
                text: rightGaugeWing.simEnergyWh.toFixed(1) + " Wh"
                color: "#FFFFFF"
                font.family: Colors.fontFamily
                font.pixelSize: 13
                font.weight: Font.Black
                font.features: { "tnum": 1 }
            }
        }
    }

    // -------------------------------------------------------------------------
    // 4. ALT BÖLÜM: CANLI GÜÇ GRAFİĞİ, ANİMASYONLU BATARYA PAKETİ VE FREN/TANK
    // -------------------------------------------------------------------------
    Column {
        anchors {
            bottom: parent.bottom
            bottomMargin: 15
            left: parent.left
            right: parent.right
            leftMargin: 44
            rightMargin: 18
        }
        spacing: 5

        // Canlı güç grafiği üst başlığı ve ulaşılan tepe güç (kW)
        Item {
            width: parent.width
            height: 11

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "// CANLI GÜÇ PROFİLİ"
                color: Qt.rgba(1, 1, 1, 0.55)
                font.family: Colors.fontFamily
                font.pixelSize: 8
                font.weight: Font.Bold
                font.letterSpacing: 0.9
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "TEPE " + rightGaugeWing.peakPowerKw.toFixed(1) + " kW"
                color: Qt.rgba(1, 1, 1, 0.80)
                font.family: Colors.fontFamily
                font.pixelSize: 9
                font.weight: Font.Black
                font.features: { "tnum": 1 }
            }
        }

        // Osiloskop grafik kutusu (Motor gücü eğrisi)
        OscilloscopeGraph {
            width: parent.width
            height: 36
            primaryHistory: rightGaugeWing.powerHistory
            showSecondaryCurve: false
            historyRevision: rightGaugeWing.historyRevision
            horizontalDivisions: 2
            primaryLineWidth: 1.7
            trackingDotRadius: 2.2
            padTop: 3
            padBottom: 2
        }

        // 8 hücreli animasyonlu batarya ikonu ve yanında SOC %, Voltaj, Hücre sıcaklıkları
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            height: 40

            BatteryCellsCanvas {
                anchors.verticalCenter: parent.verticalCenter
                battAnimPhase: rightGaugeWing.battAnimPhase
                displayBatteryPercent: rightGaugeWing.displayBatteryPercent
                displayMotorPowerKw: rightGaugeWing.displayMotorPowerKw
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Row {
                    spacing: 8
                    Text {
                        id: socValTxt
                        text: "%" + Math.round(rightGaugeWing.displayBatteryPercent)
                        color: "#FFFFFF"
                        font.family: Colors.fontFamily
                        font.pixelSize: 18
                        font.weight: Font.Black
                        font.features: { "tnum": 1 }
                    }

                    Text {
                        anchors.baseline: socValTxt.baseline
                        text: rightGaugeWing.displayPackVoltage.toFixed(1) + " V"
                        color: Qt.rgba(1, 1, 1, 0.85)
                        font.family: Colors.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        font.features: { "tnum": 1 }
                    }
                }

                Text {
                    text: "HÜCRE " + Math.round(rightGaugeWing.batteryTemp1) + "° · " + Math.round(rightGaugeWing.batteryTemp2) + "°C  (≤55°C)"
                    color: Qt.rgba(1, 1, 1, 0.54)
                    font.family: Colors.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 0.4
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(1, 1, 1, 0.14)
        }

        // En alt satır: Fren Kuvveti (%) ve Pnömatik Tank Basıncı (bar)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24

            Column {
                spacing: 0
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "FREN KUVVETİ"
                    color: Qt.rgba(1, 1, 1, 0.58)
                    font.family: Colors.fontFamily
                    font.pixelSize: 8
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "%" + Math.round(rightGaugeWing.displayBrakePercent)
                    color: "#FFFFFF"
                    font.family: Colors.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Black
                    font.features: { "tnum": 1 }
                }
            }

            Rectangle {
                width: 1
                height: 22
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(1, 1, 1, 0.18)
            }

            Column {
                spacing: 0
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "TANK BASINCI"
                    color: Qt.rgba(1, 1, 1, 0.58)
                    font.family: Colors.fontFamily
                    font.pixelSize: 8
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: rightGaugeWing.displayTankBar.toFixed(1) + " bar"
                    color: "#FFFFFF"
                    font.family: Colors.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Black
                    font.features: { "tnum": 1 }
                }
            }
        }
    }
}
