// ui/views/overview/cockpit/OscilloscopeGraph.qml
// Sol kanatta Hız & G-Kuvveti, sağ kanatta ise Motor Gücü eğrisini çizmek için
// kullandığımız osiloskop tarzı canlı grafik kutusu.
import QtQuick

Rectangle {
    id: graphBox
    radius: 4
    color: "#000000"
    border.color: Qt.rgba(1, 1, 1, 0.22)
    border.width: 1

    // Çizilecek 0.0 .. 1.0 arası normalize veri dizileri
    property var primaryHistory: []
    property var secondaryHistory: []
    property bool showSecondaryCurve: false
    property int historyRevision: 0

    // Izgara bölme sayısı, çizgi kalınlığı ve uç nokta yarıçapı ayarları
    property int horizontalDivisions: 4
    property real primaryLineWidth: 1.8
    property real trackingDotRadius: 2.4
    property real padTop: 4
    property real padBottom: 3

    onPrimaryHistoryChanged: plotCanvas.requestPaint()
    onHistoryRevisionChanged: plotCanvas.requestPaint()

    Canvas {
        id: plotCanvas
        anchors.fill: parent
        anchors.margins: 3
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width
            var h = height

            // 1. Arka Plan Kılavuz Izgarası (yatay ve dikey soluk referans çizgileri)
            ctx.strokeStyle = "rgba(255, 255, 255, 0.08)"
            ctx.lineWidth = 1.0
            for (var r = 1; r < graphBox.horizontalDivisions; r++) {
                var gy = Math.round((h * r) / graphBox.horizontalDivisions) + 0.5
                ctx.beginPath()
                ctx.moveTo(0, gy)
                ctx.lineTo(w, gy)
                ctx.stroke()
            }
            for (var c = 1; c <= 5; c++) {
                var gx = Math.round((w * c) / 6) + 0.5
                ctx.beginPath()
                ctx.moveTo(gx, 0)
                ctx.lineTo(gx, h)
                ctx.stroke()
            }

            var pArr = graphBox.primaryHistory
            if (!pArr || pArr.length < 2) return
            var n = pArr.length

            var pTop = graphBox.padTop
            var pBot = graphBox.padBottom
            var plotH = h - pTop - pBot

            // 2. İkincil Kesikli Eğri (Sol kanatta G-Kuvvetini hız eğrisinin arkasında göstermek için)
            var sArr = graphBox.secondaryHistory
            if (graphBox.showSecondaryCurve && sArr && sArr.length === n) {
                ctx.save()
                ctx.setLineDash([3, 3])
                ctx.beginPath()
                for (var j = 0; j < n; j++) {
                    var xj = (j / (n - 1)) * (w - 4)
                    var yj = pTop + (1.0 - sArr[j]) * plotH
                    if (j === 0) ctx.moveTo(xj, yj)
                    else ctx.lineTo(xj, yj)
                }
                ctx.strokeStyle = "rgba(255, 255, 255, 0.36)"
                ctx.lineWidth = 1.1
                ctx.stroke()
                ctx.restore()
            }

            // 3. Ana Beyaz Eğri ve Altındaki Yarı Saydam Gradyan Dolgu
            var grad = ctx.createLinearGradient(0, 0, 0, h)
            grad.addColorStop(0.0, "rgba(255, 255, 255, 0.22)")
            grad.addColorStop(1.0, "rgba(255, 255, 255, 0.0)")

            ctx.beginPath()
            for (var i = 0; i < n; i++) {
                var xi = (i / (n - 1)) * (w - 4)
                var yi = pTop + (1.0 - pArr[i]) * plotH
                if (i === 0) ctx.moveTo(xi, yi)
                else ctx.lineTo(xi, yi)
            }
            var lastX = w - 4
            var lastY = pTop + (1.0 - pArr[n - 1]) * plotH

            ctx.strokeStyle = "#FFFFFF"
            ctx.lineWidth = graphBox.primaryLineWidth
            ctx.stroke()

            ctx.lineTo(lastX, h)
            ctx.lineTo(0, h)
            ctx.closePath()
            ctx.fillStyle = grad
            ctx.fill()

            // 4. Sağ Uçtaki Canlı Nokta (En güncel değeri işaretler)
            ctx.beginPath()
            ctx.arc(lastX, lastY, graphBox.trackingDotRadius, 0, Math.PI * 2)
            ctx.fillStyle = "#FFFFFF"
            ctx.fill()
        }
    }
}
