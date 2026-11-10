// ui/views/overview/cockpit/BatteryCellsCanvas.qml
// Sağ kanatta batarya yüzdesinin solunda duran 8 hücreli animasyonlu batarya ikonu.
// Bataryanın doluluk oranına (`displayBatteryPercent`) göre kaç hücrenin dolu
// görüneceğini hesaplar ve `battAnimPhase` fazıyla dolu hücrelerin üzerinden
// sürekli kayan bir parlaklık dalgası geçirir.
import QtQuick

Canvas {
    id: batteryAnimCanvas
    width: 96
    height: 36

    property real battAnimPhase: 0.0
    property real displayBatteryPercent: 98.0
    property real displayMotorPowerKw: 0.0

    onBattAnimPhaseChanged: requestPaint()
    onDisplayBatteryPercentChanged: requestPaint()
    onDisplayMotorPowerKwChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()

        var bx = 2
        var by = 4
        var bw = 82
        var bh = 28
        var ch = 4

        // 1. Batarya Dış Gövdesi:
        // Köşeleri 4px pahlı (chamfered) dikdörtgen çerçeve ve sağdaki (+) kutup başı
        ctx.beginPath()
        ctx.moveTo(bx + ch, by)
        ctx.lineTo(bx + bw - ch, by)
        ctx.lineTo(bx + bw, by + ch)
        ctx.lineTo(bx + bw, by + bh - ch)
        ctx.lineTo(bx + bw - ch, by + bh)
        ctx.lineTo(bx + ch, by + bh)
        ctx.lineTo(bx, by + bh - ch)
        ctx.lineTo(bx, by + ch)
        ctx.closePath()
        ctx.lineWidth = 1.6
        ctx.strokeStyle = "rgba(255, 255, 255, 0.85)"
        ctx.stroke()

        // Sağ kutup başı: motor güç çekerken (`displayMotorPowerKw > 0.5`) sinüs dalgasıyla yanıp söner
        var termAlpha = batteryAnimCanvas.displayMotorPowerKw > 0.5
                        ? (0.45 + 0.55 * Math.sin(batteryAnimCanvas.battAnimPhase * Math.PI * 2))
                        : 0.75
        ctx.fillStyle = "rgba(255, 255, 255, " + termAlpha.toFixed(2) + ")"
        ctx.fillRect(bx + bw + 2, by + 8, 5, 12)

        // 2. İçerideki 8 Adet Eğimli Hücre Dilimi:
        // Doluluk oranına göre dolu hücreleri beyaz (ve üzerlerinden geçen parlama dalgasıyla),
        // boşalmış hücreleri ise sönük çerçeve olarak çizer.
        var cells = 8
        var soc = Math.max(0.0, Math.min(1.0, batteryAnimCanvas.displayBatteryPercent / 100.0))
        var exactCells = soc * cells
        var cellW = 7.0
        var gap = 2.2
        var slant = 2.6
        var startX = bx + 5.5
        var topY = by + 5
        var botY = by + bh - 5

        for (var k = 0; k < cells; k++) {
            var x0 = startX + k * (cellW + gap)
            ctx.beginPath()
            ctx.moveTo(x0 + slant, topY)
            ctx.lineTo(x0 + cellW + slant, topY)
            ctx.lineTo(x0 + cellW, botY)
            ctx.lineTo(x0, botY)
            ctx.closePath()

            if (k < Math.ceil(exactCells)) {
                var cellFill = Math.min(1.0, exactCells - k)
                var wavePos = batteryAnimCanvas.battAnimPhase * cells
                var dist = Math.abs(k - wavePos)
                if (dist > cells * 0.5) dist = cells - dist
                var shimmer = Math.max(0.0, 1.0 - dist * 0.65)
                var alpha = (0.58 + 0.42 * shimmer) * (0.4 + 0.6 * cellFill)
                ctx.fillStyle = "rgba(255, 255, 255, " + Math.min(1.0, alpha).toFixed(3) + ")"
                ctx.fill()
            } else {
                ctx.lineWidth = 1.0
                ctx.strokeStyle = "rgba(255, 255, 255, 0.18)"
                ctx.stroke()
            }
        }

        // 3. Yüksek Akım Şimşek İkonu:
        // LIM motoru 0.5 kW üzerinde güç çektiğinde bataryanın tam ortasında belirir.
        if (batteryAnimCanvas.displayMotorPowerKw > 0.5) {
            var cx = bx + bw * 0.5
            var cy = by + bh * 0.5
            ctx.save()
            ctx.beginPath()
            ctx.moveTo(cx + 2, cy - 8)
            ctx.lineTo(cx - 5, cy + 1)
            ctx.lineTo(cx, cy + 1)
            ctx.lineTo(cx - 2, cy + 8)
            ctx.lineTo(cx + 5, cy - 1)
            ctx.lineTo(cx, cy - 1)
            ctx.closePath()
            ctx.fillStyle = "#000000"
            ctx.lineWidth = 2.4
            ctx.strokeStyle = "#000000"
            ctx.stroke()
            ctx.fillStyle = "#FFFFFF"
            ctx.fill()
            ctx.restore()
        }
    }
}
