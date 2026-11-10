// ui/views/overview/cockpit/LeftSpeedPanel.qml
// Yarışma kokpitinin sol kanadı. İçerisinde 4 ana bölüm yer alır:
// 1. Pahlı Sol Kanat Çerçevesi: Kanadın dış sınırlarını çizen Canvas.
// 2. Segmanlı Hız Kadranı (`speedGaugeCanvas`): 0 - 140 km/h arası 48 çentikli
//    hız göstergesi ve ulaşılan maksimum hızı işaretleyen tepe çentiği.
// 3. Sürüş Fazı Sütunu: Kadranın sağ boşluğunda "HAZIR -> İVMELENME -> FRENLEME -> DURUŞ"
//    adımlarından hangisinde olunduğunu gösteren dikey durum adımları.
// 4. Canlı Hız Grafiği ve G-Kuvveti Barı: Alt kısımda akan osiloskop grafiği ve
//    10 bölmeli paralelkenar ivme çubuğu.
import QtQuick
import ParsHyperloop

Item {
    id: leftGaugeWing

    // Dışarıdan bağlanan anlık hız, ivme, sürüş fazı ve grafik dizileri
    property real displaySpeedKmh: 0.0
    property real maxSpeedKmh: 0.0
    property real gaugeMaxSpeed: 140.0
    property real displayGForce: 0.0
    property real gaugeMaxGForce: 2.4
    property real simAccelMs2: 0.0

    property int phaseIndex: 0
    property string runState: "STANDBY"

    property var speedHistory: []
    property var gForceHistory: []
    property int historyRevision: 0

    // Hız kadranının yarıçapı (`dialR`) ve merkez koordinatları (`dialCx`, `dialCy`)
    readonly property real dialR: Math.min(width * 0.255, height * 0.268, 88)
    readonly property real dialCx: width * 0.43
    readonly property real dialCy: dialR + 14

    // Sürüş fazı indeksine (0..3) göre ekranda yazacak etiketi döndürür;
    // eğer E-STOP basılıysa normal "FRENLEME / DURUŞ" yerine "ACİL FREN / ACİL DURUŞ" yazar.
    function phaseLabel(i) {
        if (i === 0) return "HAZIR"
        if (i === 1) return "İVMELENME"
        if (i === 2) return runState === "ESTOP" ? "ACİL FREN" : "FRENLEME"
        return runState === "ESTOP" ? "ACİL DURUŞ" : "DURUŞ"
    }

    onDisplaySpeedKmhChanged: speedGaugeCanvas.requestPaint()
    onMaxSpeedKmhChanged: speedGaugeCanvas.requestPaint()
    onDisplayGForceChanged: gForceCanvas.requestPaint()

    // -------------------------------------------------------------------------
    // 1. SOL KANAT DIŞ ÇERÇEVE ÇİZGİLERİ
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
            ctx.moveTo(32, 4)
            ctx.lineTo(w - 6, 4)
            ctx.lineTo(w - 32, 30)
            ctx.lineTo(w - 32, h - 52)
            ctx.lineTo(w - 8, h - 22)
            ctx.lineTo(w - 20, h - 6)
            ctx.lineTo(18, h - 6)
            ctx.lineTo(2, h - 22)
            ctx.lineTo(2, 34)
            ctx.closePath()
            ctx.lineWidth = 1.2
            ctx.strokeStyle = "rgba(255, 255, 255, 0.22)"
            ctx.stroke()

            // Sol üst köşe ve alt tabandaki kalın beyaz vurgu hatları
            ctx.lineWidth = 2.4
            ctx.strokeStyle = "#FFFFFF"

            ctx.beginPath()
            ctx.moveTo(2, 56)
            ctx.lineTo(2, 34)
            ctx.lineTo(32, 4)
            ctx.lineTo(70, 4)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(24, h - 6)
            ctx.lineTo(w - 26, h - 6)
            ctx.stroke()
        }
    }

    // -------------------------------------------------------------------------
    // 2. 48 SEGMANLI HIZ KADRANI (0 - 140 km/h)
    // 134 dereceden 326 dereceye uzanan yay üzerinde 48 çentik çizer. Her 6
    // çentikte bir ana bölmeyi biraz daha uzun ve kalın çiziyoruz. Ayrıca
    // ulaşılan en yüksek hız (`maxSpeedKmh`) yayın dışında beyaz bir tepe
    // işareti olarak kalır.
    // -------------------------------------------------------------------------
    Canvas {
        id: speedGaugeCanvas
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var cx = leftGaugeWing.dialCx
            var cy = leftGaugeWing.dialCy
            var radius = leftGaugeWing.dialR
            var barLen = 16

            var startRad = 134 * Math.PI / 180
            var endRad = 326 * Math.PI / 180
            var totalTicks = 48
            var ratio = Math.max(0.0, Math.min(1.0, leftGaugeWing.displaySpeedKmh / leftGaugeWing.gaugeMaxSpeed))
            var activeTicks = Math.round(ratio * totalTicks)

            // Dış ince kılavuz yayı
            ctx.beginPath()
            ctx.arc(cx, cy, radius + 6, startRad, endRad, false)
            ctx.lineWidth = 1.2
            ctx.strokeStyle = "rgba(255, 255, 255, 0.35)"
            ctx.stroke()

            // İç ince kılavuz yayı
            ctx.beginPath()
            ctx.arc(cx, cy, radius - barLen - 6, startRad + 0.08, endRad - 0.08, false)
            ctx.lineWidth = 1.0
            ctx.strokeStyle = "rgba(255, 255, 255, 0.18)"
            ctx.stroke()

            // 48 adet hız çentiği
            for (var i = 0; i < totalTicks; i++) {
                var t = i / (totalTicks - 1)
                var ang = startRad + t * (endRad - startRad)
                var cosA = Math.cos(ang)
                var sinA = Math.sin(ang)
                var isMajor = (i % 6 === 0)
                var innerOffset = isMajor ? barLen + 2 : barLen

                ctx.beginPath()
                ctx.moveTo(cx + (radius - innerOffset) * cosA, cy + (radius - innerOffset) * sinA)
                ctx.lineTo(cx + radius * cosA, cy + radius * sinA)
                ctx.lineWidth = isMajor ? 2.9 : 2.2
                ctx.strokeStyle = (i < activeTicks) ? "#FFFFFF" : "rgba(255, 255, 255, 0.13)"
                ctx.stroke()
            }

            // Maksimum hız (Peak Hold) dış çentiği
            if (leftGaugeWing.maxSpeedKmh > 0.5) {
                var peakRatio = Math.max(0.0, Math.min(1.0, leftGaugeWing.maxSpeedKmh / leftGaugeWing.gaugeMaxSpeed))
                var peakAng = startRad + peakRatio * (endRad - startRad)
                ctx.beginPath()
                ctx.moveTo(cx + (radius + 8) * Math.cos(peakAng), cy + (radius + 8) * Math.sin(peakAng))
                ctx.lineTo(cx + (radius + 14) * Math.cos(peakAng), cy + (radius + 14) * Math.sin(peakAng))
                ctx.lineWidth = 2.4
                ctx.strokeStyle = "#FFFFFF"
                ctx.stroke()
            }
        }
    }

    // Kadranın tam ortasındaki sayısal hız, birim ve maksimum hız yazıları
    Column {
        x: leftGaugeWing.dialCx - width / 2
        y: leftGaugeWing.dialCy - height / 2 + 2
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "HIZ"
            color: Qt.rgba(1, 1, 1, 0.68)
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 2.0
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(leftGaugeWing.displaySpeedKmh).toString()
            color: "#FFFFFF"
            font.family: Colors.fontFamily
            font.pixelSize: 38
            font.weight: Font.Black
            font.features: { "tnum": 1 }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "km/h"
            color: "#FFFFFF"
            font.family: Colors.fontFamily
            font.pixelSize: 12
            font.weight: Font.Bold
            font.letterSpacing: 0.8
        }

        Item { width: 1; height: 2 }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "MAKS. " + Math.round(leftGaugeWing.maxSpeedKmh) + " km/h"
            color: Qt.rgba(1, 1, 1, 0.56)
            font.family: Colors.fontFamily
            font.pixelSize: 9
            font.weight: Font.Bold
            font.letterSpacing: 0.5
        }
    }

    // -------------------------------------------------------------------------
    // 3. KADRAN SAĞ SEKTÖRÜ: 4 ADIMLI DİKEY SÜRÜŞ FAZI GÖSTERGESİ
    // Aktif olan adım 45 derece dönük elmas (karo) şeklinde parlak beyaz yanar,
    // geçilmiş adımlar dolu daire, gelecek adımlar ise sönük çember olarak durur.
    // -------------------------------------------------------------------------
    Column {
        x: leftGaugeWing.width - 42 - width
        y: leftGaugeWing.dialCy - 28
        spacing: 3

        Text {
            text: "SÜRÜŞ FAZI"
            color: Qt.rgba(1, 1, 1, 0.45)
            font.family: Colors.fontFamily
            font.pixelSize: 8
            font.weight: Font.Bold
            font.letterSpacing: 1.0
            bottomPadding: 2
        }

        Repeater {
            model: 4

            Row {
                required property int index
                readonly property bool isCurrent: leftGaugeWing.phaseIndex === index
                readonly property bool isPast: leftGaugeWing.phaseIndex > index
                spacing: 6
                height: 14

                Item {
                    width: 8
                    height: 14

                    // Adımları birbirine bağlayan dikey çizgi
                    Rectangle {
                        visible: index < 3
                        x: 3.5; y: 10; width: 1; height: 10
                        color: Qt.rgba(1, 1, 1, isPast ? 0.55 : 0.16)
                    }

                    // Adım işaretçisi
                    Rectangle {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -1
                        width: isCurrent ? 8 : 6
                        height: width
                        radius: isCurrent ? 1 : width / 2
                        rotation: isCurrent ? 45 : 0
                        color: (isCurrent || isPast) ? "#FFFFFF" : "transparent"
                        border.color: "#FFFFFF"
                        border.width: 1
                        opacity: isCurrent ? 1.0 : (isPast ? 0.6 : 0.3)

                        Behavior on width { NumberAnimation { duration: 180 } }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -1
                    text: leftGaugeWing.phaseLabel(index)
                    color: "#FFFFFF"
                    opacity: isCurrent ? 1.0 : (isPast ? 0.55 : 0.30)
                    font.family: Colors.fontFamily
                    font.pixelSize: 9
                    font.weight: isCurrent ? Font.Black : Font.Bold
                    font.letterSpacing: 0.5
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // 4. ALT BÖLÜM: CANLI HIZ GRAFİĞİ, 10 SEGMANLI G-KUVVETİ BARI VE 3-EKSEN İVME
    // -------------------------------------------------------------------------
    Column {
        anchors {
            bottom: parent.bottom
            bottomMargin: 15
            left: parent.left
            right: parent.right
            leftMargin: 18
            rightMargin: 44
        }
        spacing: 6

        // Grafik üst başlığı ve m/s cinsinden anlık hız
        Item {
            width: parent.width
            height: 12

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "// CANLI HIZ & İVME GRAFİĞİ"
                color: Qt.rgba(1, 1, 1, 0.55)
                font.family: Colors.fontFamily
                font.pixelSize: 8
                font.weight: Font.Bold
                font.letterSpacing: 0.9
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "Vx " + (leftGaugeWing.displaySpeedKmh / 3.6).toFixed(1) + " m/s"
                color: Qt.rgba(1, 1, 1, 0.80)
                font.family: Colors.fontFamily
                font.pixelSize: 9
                font.weight: Font.Black
                font.features: { "tnum": 1 }
            }
        }

        // Osiloskop grafik kutusu: düz beyaz çizgi hızı, kesikli çizgi G-kuvvetini gösterir
        OscilloscopeGraph {
            width: parent.width
            height: 52
            primaryHistory: leftGaugeWing.speedHistory
            secondaryHistory: leftGaugeWing.gForceHistory
            showSecondaryCurve: true
            historyRevision: leftGaugeWing.historyRevision
            horizontalDivisions: 4
            primaryLineWidth: 1.8
            trackingDotRadius: 2.4
            padTop: 4
            padBottom: 3
        }

        // Sayısal G-Kuvveti ve 10 adet eğimli paralelkenar segman çubuğu
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "İVME"
                color: Qt.rgba(1, 1, 1, 0.65)
                font.family: Colors.fontFamily
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 1.6
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: leftGaugeWing.displayGForce.toFixed(2) + " G"
                color: "#FFFFFF"
                font.family: Colors.fontFamily
                font.pixelSize: 19
                font.weight: Font.Black
                font.features: { "tnum": 1 }
            }

            Canvas {
                id: gForceCanvas
                anchors.verticalCenter: parent.verticalCenter
                width: 120
                height: 15
                onWidthChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var count = 10
                    var lit = Math.round(Math.max(0, Math.min(count, (leftGaugeWing.displayGForce / leftGaugeWing.gaugeMaxGForce) * count)))
                    var segW = 8.0
                    var gap = 3.0
                    var slant = 4.0

                    for (var i = 0; i < count; i++) {
                        var x0 = 2 + i * (segW + gap)
                        ctx.beginPath()
                        ctx.moveTo(x0 + slant, 1)
                        ctx.lineTo(x0 + segW + slant, 1)
                        ctx.lineTo(x0 + segW, 14)
                        ctx.lineTo(x0, 14)
                        ctx.closePath()

                        if (i < lit) {
                            ctx.fillStyle = "#FFFFFF"
                            ctx.fill()
                        } else {
                            ctx.lineWidth = 1.0
                            ctx.strokeStyle = "rgba(255, 255, 255, 0.22)"
                            ctx.stroke()
                        }
                    }
                }
            }
        }

        // En altta 3-eksen ivme bileşenleri (Ax, Ay, Az)
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Ax " + leftGaugeWing.simAccelMs2.toFixed(1) + "   ·   Ay 0.0   ·   Az 9.8 m/s²"
            color: Qt.rgba(1, 1, 1, 0.45)
            font.family: Colors.fontFamily
            font.pixelSize: 9
            font.weight: Font.DemiBold
            font.letterSpacing: 0.4
        }
    }
}
