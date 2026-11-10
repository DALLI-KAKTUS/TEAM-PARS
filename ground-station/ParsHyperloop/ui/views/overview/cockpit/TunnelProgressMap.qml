// ui/views/overview/cockpit/TunnelProgressMap.qml
// Kokpitin üst kısmında yer alan 208 metrelik doğrusal tünel haritası.
// Üst satırda kapsülün X (ilerleme), Y (yatay sapma), Z (levitasyon boşluğu)
// koordinatlarını ve kalan mesafeyi gösterir. Altındaki bar üzerinde ise 46 adet
// reflektör şeridini, şartname mesafe noktalarını (Son 100 m, Son 48 m, Bitiş 191 m,
// Güvenlik 17 m) ve kapsülün anlık konumda kayan beyaz silüetini çizer.
import QtQuick
import ParsHyperloop

Item {
    id: tunnelNavSection
    height: 54

    // Fizik motorundan gelen tünel sabitleri
    property real totalDistance: 208.0
    property real firstReflectorPos: 11.0
    property real reflectorPitch: 4.0
    property int reflectorTotal: 46
    property real raceFinishPos: 191.0

    // Canlı konum ve ilerleme verileri
    property real displayDistance: 0.0
    property real posYmm: 0.0
    property real posZmm: 12.0
    property real progressRatio: 0.0
    property real remainingDistance: 208.0
    property int litReflectors: 0

    // Kapsül yeni bir reflektör şeridini geçtiğinde alttaki çentik barını yeniden boyar
    onLitReflectorsChanged: reflectorTicks.requestPaint()

    // -------------------------------------------------------------------------
    // 1. ÜST SATIR: SOLDA BAŞLIK, ORTADA 3-EKSEN KONUM, SAĞDA KALAN MESAFE
    // -------------------------------------------------------------------------
    Row {
        anchors {
            left: parent.left
            top: parent.top
        }
        spacing: 6

        Text {
            text: "//"
            color: "#FFFFFF"
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.Black
        }

        Text {
            text: "TÜNEL NAVİGASYONU"
            color: "#FFFFFF"
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 1.5
        }

        Text {
            text: "[PARKUR: 186 m · TÜNEL: 208 m]"
            color: Qt.rgba(1, 1, 1, 0.50)
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.DemiBold
            font.letterSpacing: 0.6
        }
    }

    // Kapsülün tünel içindeki 3-eksen konumu (X metre, Y milimetre, Z levitasyon boşluğu)
    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }
        text: "X: " + tunnelNavSection.displayDistance.toFixed(1) + " m   ·   Y: " +
              (tunnelNavSection.posYmm >= 0 ? "+" : "") + tunnelNavSection.posYmm.toFixed(1) + " mm   ·   Z (GAP): " +
              tunnelNavSection.posZmm.toFixed(1) + " mm"
        color: Qt.rgba(1, 1, 1, 0.68)
        font.family: Colors.fontFamily
        font.pixelSize: 10
        font.weight: Font.Bold
        font.letterSpacing: 0.6
    }

    // Tünel sonuna kalan metre ve tamamlanma yüzdesi
    Row {
        anchors {
            right: parent.right
            top: parent.top
        }
        spacing: 8

        Text {
            text: "KALAN MESAFE: " + Math.round(tunnelNavSection.remainingDistance) + " m"
            color: "#FFFFFF"
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 0.8
        }

        Text {
            text: "|"
            color: Qt.rgba(1, 1, 1, 0.35)
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
        }

        Text {
            text: "%" + (tunnelNavSection.progressRatio * 100.0).toFixed(1)
            color: "#FFFFFF"
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.Black
            font.letterSpacing: 0.6
        }
    }

    // -------------------------------------------------------------------------
    // 2. ALT SATIR: 208 METRELİK TÜNEL BARI, REFLEKTÖRLER VE KAPSÜL SİLÜETİ
    // -------------------------------------------------------------------------
    Item {
        id: tunnelTrackRow
        anchors {
            top: parent.top
            topMargin: 21
            left: parent.left
            right: parent.right
        }
        height: 30

        Text {
            id: startLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "BAŞLANGIÇ (0 m)"
            color: Qt.rgba(1, 1, 1, 0.85)
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 0.6
        }

        Text {
            id: endLabel
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "TÜNEL SONU (208 m)"
            color: Qt.rgba(1, 1, 1, 0.85)
            font.family: Colors.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 0.6
        }

        // Tünel kanalının ana oluğu (12px yüksekliğinde)
        Rectangle {
            id: trackGroove
            anchors {
                left: startLabel.right
                right: endLabel.left
                leftMargin: 14
                rightMargin: 14
                verticalCenter: parent.verticalCenter
            }
            height: 12
            radius: 6
            color: "#000000"
            border.color: Qt.rgba(1, 1, 1, 0.38)
            border.width: 1.2

            // 191. metreden 208. metreye kadar olan son 17 metrelik güvenlik duruş bölgesini
            // eğik çizgilerle (hatch) tarayarak normal yarış parkurundan ayırıyoruz.
            Canvas {
                id: stopZoneHatch
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    margins: 1
                }
                width: Math.max(12, parent.width * ((tunnelNavSection.totalDistance - tunnelNavSection.raceFinishPos) / tunnelNavSection.totalDistance))
                onWidthChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.28)"
                    ctx.lineWidth = 1.2
                    for (var x = -8; x < width + 8; x += 6) {
                        ctx.beginPath()
                        ctx.moveTo(x, height)
                        ctx.lineTo(x + 6, 0)
                        ctx.stroke()
                    }
                }
            }

            // Tünelin altında 11. metreden başlayıp 4 metrede bir dizilen 46 reflektör çentiği.
            // Kapsülün geçtiği şeritler parlak beyaz, henüz geçmedikleri soluk gri çizilir.
            Canvas {
                id: reflectorTicks
                x: 0
                y: parent.height + 2
                width: parent.width
                height: 4
                onWidthChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    for (var k = 0; k < tunnelNavSection.reflectorTotal; k++) {
                        var m = tunnelNavSection.firstReflectorPos + k * tunnelNavSection.reflectorPitch
                        var px = Math.round((m / tunnelNavSection.totalDistance) * width) + 0.5
                        ctx.beginPath()
                        ctx.moveTo(px, 0)
                        ctx.lineTo(px, height)
                        ctx.lineWidth = 1.0
                        ctx.strokeStyle = (k < tunnelNavSection.litReflectors)
                                          ? "rgba(255, 255, 255, 0.9)"
                                          : "rgba(255, 255, 255, 0.18)"
                        ctx.stroke()
                    }
                }
            }

            // Sol altta okunan reflektör sayacı
            Text {
                x: 0
                y: parent.height + 8
                text: "REFLEKTÖR " + tunnelNavSection.litReflectors + " / " + tunnelNavSection.reflectorTotal
                color: Qt.rgba(1, 1, 1, 0.55)
                font.family: Colors.fontFamily
                font.pixelSize: 8
                font.weight: Font.Bold
                font.letterSpacing: 0.6
            }

            // Şartnamedeki önemli mesafe sınırlarını bar üzerinde dikey çizgi ve etiketle gösterir
            Repeater {
                model: [
                    { m: 5.0,   tag: "",              align: "center", strong: false },
                    { m: 91.0,  tag: "SON 100 m",     align: "center", strong: false },
                    { m: 143.0, tag: "SON 48 m",      align: "center", strong: false },
                    { m: 191.0, tag: "BİTİŞ 191 m",   align: "right",  strong: true  },
                    { m: 191.0, tag: "GÜVENLİK 17 m", align: "left",   strong: true  }
                ]

                Item {
                    required property var modelData
                    x: (modelData.m / tunnelNavSection.totalDistance) * trackGroove.width
                    y: 0
                    width: 1
                    height: trackGroove.height
                    z: 3

                    Rectangle {
                        visible: modelData.align !== "left"
                        width: modelData.strong ? 2 : 1
                        height: trackGroove.height + 4
                        y: -2
                        color: modelData.strong ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.50)
                    }

                    Text {
                        visible: modelData.tag.length > 0
                        y: trackGroove.height + 8
                        x: modelData.align === "center" ? -width / 2
                                                        : (modelData.align === "right" ? -width - 4 : 5)
                        text: modelData.tag
                        color: Qt.rgba(1, 1, 1, modelData.strong ? 0.62 : 0.46)
                        font.family: Colors.fontFamily
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        font.letterSpacing: 0.4
                    }
                }
            }

            // Kapsül ilerledikçe arkasında dolan beyaz ilerleme çubuğu
            Rectangle {
                id: trackFill
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: tunnelNavSection.progressRatio <= 0.001
                       ? 0
                       : Math.max(10, parent.width * tunnelNavSection.progressRatio)
                height: parent.height
                radius: 6
                color: "#FFFFFF"
                visible: width > 0
            }

            // Barın üzerinde anlık konuma göre kayan aerodinamik kapsül yan silüeti
            Canvas {
                id: podSilhouette
                width: 66
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(trackGroove.width - width, trackGroove.width * tunnelNavSection.progressRatio - width * 0.5))
                z: 4

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    // Kapsül dış gövde eğrisi
                    ctx.beginPath()
                    ctx.moveTo(4, 18)
                    ctx.quadraticCurveTo(3, 11, 14, 7.5)
                    ctx.bezierCurveTo(27, 3, 45, 4, 60, 12)
                    ctx.quadraticCurveTo(65, 15, 62, 18)
                    ctx.closePath()

                    ctx.fillStyle = "#FFFFFF"
                    ctx.fill()
                    ctx.lineWidth = 1.8
                    ctx.strokeStyle = "#000000"
                    ctx.stroke()

                    // Ön cam / vizör detayı
                    ctx.beginPath()
                    ctx.moveTo(28, 7.5)
                    ctx.quadraticCurveTo(43, 7.5, 54, 13)
                    ctx.lineTo(41, 13)
                    ctx.quadraticCurveTo(34, 10, 28, 7.5)
                    ctx.closePath()
                    ctx.fillStyle = "#000000"
                    ctx.fill()

                    // Alt şasi çizgisi
                    ctx.beginPath()
                    ctx.moveTo(7, 16.5)
                    ctx.lineTo(59, 16.5)
                    ctx.lineWidth = 1.3
                    ctx.strokeStyle = "#000000"
                    ctx.stroke()
                }
            }

            // Kapsül silüetinin tam üstünde onunla birlikte hareket eden anlık metre yazısı
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -14
                x: Math.max(2, Math.min(trackGroove.width - width - 2, podSilhouette.x + podSilhouette.width * 0.5 - width * 0.5))
                text: Math.round(tunnelNavSection.displayDistance) + " m"
                color: "#FFFFFF"
                font.family: Colors.fontFamily
                font.pixelSize: 10
                font.weight: Font.Black
                font.letterSpacing: 0.4
                z: 5
            }
        }
    }
}
