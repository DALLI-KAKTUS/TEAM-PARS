// ui/views/overview/cockpit/CockpitBorderFrame.qml
// Yarışma kokpitinin arka planındaki siyah zemini ve ekranın kenarlarını
// dolanan 45 derece kırıklı (pahlı) beyaz kokpit çerçeve çizgilerini çizer.
import QtQuick

Item {
    id: frameOverlay
    anchors.fill: parent

    // Kokpitin tam siyah arka plan zemini
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    // Üst, alt ve dört köşedeki teknik çerçeve hatları
    Canvas {
        id: outerCockpitLines
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var w = width
            var h = height
            var cx = w * 0.5
            var leftX = 20
            var rightX = w - 20
            var wingTopY = 166
            var notchBottomY = 202
            var botY = h - 8
            var chamfer = 18

            // 1. Üst Sınır Çizgisi:
            // Sol ve sağ üstten başlayıp ortadaki "Simülasyon | Yarışma" mod anahtarının
            // altından yamuk bir çentik yaparak geçer.
            ctx.beginPath()
            ctx.moveTo(leftX, wingTopY + chamfer)
            ctx.lineTo(leftX + chamfer, wingTopY)
            ctx.lineTo(cx - 182, wingTopY)
            ctx.lineTo(cx - 150, notchBottomY)
            ctx.lineTo(cx + 150, notchBottomY)
            ctx.lineTo(cx + 182, wingTopY)
            ctx.lineTo(rightX - chamfer, wingTopY)
            ctx.lineTo(rightX, wingTopY + chamfer)
            ctx.lineWidth = 1.2
            ctx.strokeStyle = "rgba(255, 255, 255, 0.24)"
            ctx.stroke()

            // Mod anahtarının tam altında duran daha belirgin yatay vurgu çizgisi
            ctx.beginPath()
            ctx.moveTo(cx - 142, notchBottomY)
            ctx.lineTo(cx + 142, notchBottomY)
            ctx.lineWidth = 1.8
            ctx.strokeStyle = "rgba(255, 255, 255, 0.52)"
            ctx.stroke()

            // 2. Alt Sınır Çizgisi:
            // Alttaki yuvarlak dikey kaydırma butonunun üzerine binmemesi için
            // merkezde (`cx - 56` ile `cx + 56` arasında) açık bir çentik bırakır.
            ctx.beginPath()
            ctx.moveTo(leftX, botY - 38)
            ctx.lineTo(leftX, botY - 12)
            ctx.lineTo(leftX + 12, botY)
            ctx.lineTo(cx - 56, botY)
            ctx.lineTo(cx - 38, botY - 22)

            ctx.moveTo(cx + 38, botY - 22)
            ctx.lineTo(cx + 56, botY)
            ctx.lineTo(rightX - 12, botY)
            ctx.lineTo(rightX, botY - 12)
            ctx.lineTo(rightX, botY - 38)
            ctx.lineWidth = 1.2
            ctx.strokeStyle = "rgba(255, 255, 255, 0.22)"
            ctx.stroke()

            // 3. Dört Köşe Vurgu Braketleri:
            // Kokpitin sol-üst, sağ-üst, sol-alt ve sağ-alt köşelerini kalın beyaz çizgiyle belirginleştirir.
            ctx.lineWidth = 2.2
            ctx.strokeStyle = "#FFFFFF"

            // Sol-üst köşe
            ctx.beginPath()
            ctx.moveTo(leftX, wingTopY + chamfer + 18)
            ctx.lineTo(leftX, wingTopY + chamfer)
            ctx.lineTo(leftX + chamfer, wingTopY)
            ctx.lineTo(leftX + chamfer + 26, wingTopY)
            ctx.stroke()

            // Sağ-üst köşe
            ctx.beginPath()
            ctx.moveTo(rightX, wingTopY + chamfer + 18)
            ctx.lineTo(rightX, wingTopY + chamfer)
            ctx.lineTo(rightX - chamfer, wingTopY)
            ctx.lineTo(rightX - chamfer - 26, wingTopY)
            ctx.stroke()

            // Sol-alt köşe
            ctx.beginPath()
            ctx.moveTo(leftX, botY - 28)
            ctx.lineTo(leftX, botY - 12)
            ctx.lineTo(leftX + 12, botY)
            ctx.lineTo(leftX + 34, botY)
            ctx.stroke()

            // Sağ-alt köşe
            ctx.beginPath()
            ctx.moveTo(rightX, botY - 28)
            ctx.lineTo(rightX, botY - 12)
            ctx.lineTo(rightX - 12, botY)
            ctx.lineTo(rightX - 34, botY)
            ctx.stroke()
        }
    }
}
