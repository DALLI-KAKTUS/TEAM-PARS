// ui/views/overview/cockpit/Tunnel3DRingsCanvas.qml
// Merkez komuta alanında E-START ve E-STOP butonlarının arkasında çalışan
// 3 boyutlu perspektif tünel ve reflektör ışık animasyonu.
// 1/z derinlik formülüyle içten dışa doğru büyüyen 8 adet eliptik tünel halkası çizer.
import QtQuick
import ParsHyperloop

Item {
    id: tunnelAnimRoot

    // Animasyon kontrolcüsünden gelen faz ve hız değerleri
    property real tunnelTravelPhase: 0.0
    property real tunnelLightWave: 0.0
    property real displaySpeedKmh: 0.0
    property bool isSweeping: false
    property int litReflectors: 0
    property int reflectorTotal: 46

    // Tünelin kaçış noktası (vanishing point) E-START ve E-STOP butonlarının tam ortasına hizalanır
    property real ringsCenterY: height * 0.5
    property real ringDiameter: 134

    onTunnelTravelPhaseChanged: tunnelPerspectiveCanvas.requestPaint()
    onTunnelLightWaveChanged: tunnelPerspectiveCanvas.requestPaint()
    onDisplaySpeedKmhChanged: tunnelPerspectiveCanvas.requestPaint()

    // -------------------------------------------------------------------------
    // 1. 3B PERSPEKTİF TÜNEL HALKALARI VE KILAVUZ RAYLARI ÇİZİMİ
    // -------------------------------------------------------------------------
    Canvas {
        id: tunnelPerspectiveCanvas
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: Math.min(parent.height - 42,
                         tunnelAnimRoot.ringsCenterY + tunnelAnimRoot.ringDiameter * 0.5 + 38)

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width
            var h = height
            if (w < 20 || h < 20) return

            var vx = w * 0.5
            var vy = tunnelAnimRoot.ringsCenterY
            var maxRx = w * 0.48
            var maxRy = Math.min(h * 0.56, 142)

            // A. Perspektif Tünel Kılavuz Rayları:
            // Kaçış noktasından dışa doğru açılan 4 alt ray çizgisi ve 1 üst tavan hattı
            var railAngles = [
                72 * Math.PI / 180,
                108 * Math.PI / 180,
                84 * Math.PI / 180,
                96 * Math.PI / 180,
                270 * Math.PI / 180
            ]
            for (var rIdx = 0; rIdx < railAngles.length; rIdx++) {
                var ra = railAngles[rIdx]
                var innerF = 0.16
                var outerF = 1.05
                ctx.beginPath()
                ctx.moveTo(vx + Math.cos(ra) * maxRx * innerF, vy + Math.sin(ra) * maxRy * innerF)
                ctx.lineTo(vx + Math.cos(ra) * maxRx * outerF, vy + Math.sin(ra) * maxRy * outerF)
                ctx.lineWidth = (rIdx < 2) ? 1.3 : 0.9
                ctx.strokeStyle = (rIdx < 2) ? "rgba(255, 255, 255, 0.18)" : "rgba(255, 255, 255, 0.09)"
                ctx.stroke()
            }

            // B. 8 Adet Eliptik Tünel Halkası ve Reflektör Işık Kemerleri:
            // Kapsül hareket halindeyken (`isMoving`) halkalar `tunnelTravelPhase` ile kameraya
            // doğru büyüyerek gelir; kapsül dururken ise halkalar sabit durur ve sadece
            // üstlerindeki parlak reflektör yayları `tunnelLightWave` ile arkadan öne doğru akar.
            var ringCount = 8
            var zFar = 5.4
            var zNear = 0.88
            var isMoving = tunnelAnimRoot.isSweeping || tunnelAnimRoot.displaySpeedKmh > 0.4

            for (var i = 0; i < ringCount; i++) {
                var depthProgress = isMoving
                                    ? ((i + tunnelAnimRoot.tunnelTravelPhase) / ringCount)
                                    : ((i + 0.35) / ringCount)
                var z = zFar - depthProgress * (zFar - zNear)
                var persp = 1.0 / z
                var rx = maxRx * persp
                var ry = maxRy * persp

                // En uzaktaki ve en öndeki halkaların sert kesilmemesi için sinüs zarfıyla
                // opaklıklarını yumuşatıyoruz.
                var envAlpha = Math.sin(depthProgress * Math.PI)
                envAlpha = Math.max(0.0, Math.min(1.0, envAlpha))

                // Işık dalgasının o an hangi halkada olduğunu hesaplayan parlaklık çarpanı
                var waveDist = Math.abs(depthProgress - tunnelAnimRoot.tunnelLightWave)
                if (waveDist > 0.5) waveDist = 1.0 - waveDist
                var waveBoost = Math.max(0.0, 1.0 - waveDist * 4.2)

                var baseRingAlpha = envAlpha * (0.12 + 0.18 * depthProgress + 0.34 * waveBoost)
                var reflectorAlpha = envAlpha * (isMoving
                                                 ? (0.35 + 0.55 * depthProgress)
                                                 : (0.16 + 0.68 * waveBoost))

                ctx.save()
                ctx.translate(vx, vy)
                ctx.scale(1.0, ry / Math.max(1.0, rx))

                // Halkanın 360 derece tam gövde çemberi
                ctx.beginPath()
                ctx.arc(0, 0, rx, 0, Math.PI * 2, false)
                ctx.lineWidth = (0.8 + 1.1 * depthProgress)
                ctx.strokeStyle = "rgba(255, 255, 255, " + baseRingAlpha.toFixed(3) + ")"
                ctx.stroke()

                // Halka üzerindeki 3 parlak reflektör şeridi (Tavan, Sol Yan ve Sağ Yan)
                var lw = 1.4 + 1.8 * depthProgress + 0.8 * waveBoost
                ctx.lineWidth = lw
                ctx.strokeStyle = "rgba(255, 255, 255, " + Math.min(0.92, reflectorAlpha).toFixed(3) + ")"

                // Tavan reflektörü
                ctx.beginPath()
                ctx.arc(0, 0, rx, 242 * Math.PI / 180, 298 * Math.PI / 180, false)
                ctx.stroke()

                // Sol yan reflektör
                ctx.beginPath()
                ctx.arc(0, 0, rx, 152 * Math.PI / 180, 208 * Math.PI / 180, false)
                ctx.stroke()

                // Sağ yan reflektör
                ctx.beginPath()
                ctx.arc(0, 0, rx, -28 * Math.PI / 180, 28 * Math.PI / 180, false)
                ctx.stroke()

                ctx.restore()
            }

            // C. Alt Siyah Geçiş (Vinyet):
            // Tünelin alt halkalarının aşağıdaki Roll/Pitch/Yaw ve sıcaklık yazılarıyla
            // üst üste binmemesi için alt 42 piksellik alanı yumuşakça siyaha gömüyoruz.
            var botFade = ctx.createLinearGradient(0, h - 42, 0, h)
            botFade.addColorStop(0.0, "rgba(0, 0, 0, 0.0)")
            botFade.addColorStop(1.0, "rgba(0, 0, 0, 1.0)")
            ctx.fillStyle = botFade
            ctx.fillRect(0, h - 42, w, 42)
        }
    }

    // -------------------------------------------------------------------------
    // 2. ÜST TÜNEL OPTİK DURUM ETİKETİ
    // Kapsül dururken "TÜNEL KILAVUZ OPTİĞİ · HAZIR", hareket ederken ise
    // o an kaçıncı reflektör şeridinde olduğunu gösterir.
    // -------------------------------------------------------------------------
    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        width: tunnelBadgeTxt.implicitWidth + 18
        height: 18
        radius: 9
        color: "#000000"
        border.color: Qt.rgba(1, 1, 1, 0.24)
        border.width: 1

        Text {
            id: tunnelBadgeTxt
            anchors.centerIn: parent
            text: tunnelAnimRoot.displaySpeedKmh > 0.4
                  ? ("TÜNEL AKIŞI  ·  ŞERİT " + tunnelAnimRoot.litReflectors + " / " + tunnelAnimRoot.reflectorTotal)
                  : "TÜNEL KILAVUZ OPTİĞİ  ·  HAZIR"
            color: Qt.rgba(1, 1, 1, 0.72)
            font.family: Colors.fontFamily
            font.pixelSize: 8
            font.weight: Font.Bold
            font.letterSpacing: 0.9
        }
    }
}
