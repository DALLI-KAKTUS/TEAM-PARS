// ui/shell/NotificationLogPanel.qml
// Sol üstte İKÇÜ logosunun yanında duran açılır-kapanır bildirim çekmecesi.
// Kapalıyken 52px yüksekliğinde kompakt bir bar olarak durur; üzerine tıklanınca
// 245px yüksekliğe açılarak alt sistemlerden gelen zaman damgalı mesajları listeler.
import QtQuick
import QtQuick.Shapes
import ParsHyperloop

Rectangle {
    id: notificationPanel
    width: 310
    height: isExpanded ? 245 : 52
    radius: 16
    color: "#FFFFFF"
    clip: true

    // Panelin açık (true) veya kapalı (false) olma durumu
    property bool isExpanded: false

    // Yükseklik değiştiğinde 340 ms'de yumuşakça açılıp kapanmasını sağlar
    Behavior on height {
        NumberAnimation {
            duration: 340
            easing.type: Easing.OutCubic
        }
    }

    Column {
        anchors.fill: parent

        // ---------------------------------------------------------------------
        // 1. ÜST BAŞLIK SATIRI (HER ZAMAN GÖRÜNÜR - 52px)
        // Çan ikonu, "BİLDİRİM PANELİ" başlığı, bildirim sayısı rozeti ve sağ
        // kenardaki dönen ok (chevron) ikonunu içerir.
        // ---------------------------------------------------------------------
        Item {
            width: parent.width
            height: 52

            Row {
                anchors.centerIn: parent
                spacing: 10

                // Vektörel çan ikonu çizimi
                Shape {
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter

                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 2.0
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin

                        startX: 10; startY: 3
                        PathLine { x: 14; y: 7 }
                        PathLine { x: 16; y: 13 }
                        PathLine { x: 4; y: 13 }
                        PathLine { x: 6; y: 7 }
                        PathLine { x: 10; y: 3 }
                    }

                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 2.0
                        capStyle: ShapePath.RoundCap
                        startX: 8; startY: 16
                        PathLine { x: 12; y: 16 }
                    }
                }

                Text {
                    text: "BİLDİRİM PANELİ"
                    color: "#000000"
                    font.family: Colors.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Black
                    font.letterSpacing: 0.8
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Siyah daire içinde aktif bildirim adedi
                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: "#000000"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "4"
                        color: "#FFFFFF"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }
                }
            }

            // Sağ kenardaki ok ikonu; panel açıldığında 180 derece dönerek yukarı bakar
            Shape {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                height: 8

                rotation: notificationPanel.isExpanded ? 180 : 0
                Behavior on rotation {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                ShapePath {
                    strokeColor: "#000000"
                    strokeWidth: 2.2
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin

                    startX: 1; startY: 1
                    PathLine { x: 6; y: 6 }
                    PathLine { x: 11; y: 1 }
                }
            }

            // Başlık satırının tamamı tıklanabilir alanı oluşturur
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: notificationPanel.isExpanded = !notificationPanel.isExpanded
            }
        }

        // Başlık ile log listesini ayıran ince gri çizgi (yalnızca panel açıkken görünür)
        Rectangle {
            width: parent.width - 24
            height: 1
            color: "#E5E5E5"
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: notificationPanel.isExpanded ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        // ---------------------------------------------------------------------
        // 2. AŞAĞI AÇILAN KAYDIRILABİLİR LOG LİSTESİ
        // Kayıt sayısı arttığında taşmaması için `Flickable` içine aldık. Her
        // satırda durum rengini belirten nokta, saat bilgisi ve mesaj yer alır.
        // ---------------------------------------------------------------------
        Flickable {
            width: parent.width
            height: 180
            contentHeight: logColumn.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            opacity: notificationPanel.isExpanded ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            Column {
                id: logColumn
                width: parent.width - 28
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                spacing: 8

                Repeater {
                    model: [
                        { time: "12:38:02", msg: "CAN-Bus telemetri senkronize edildi.", type: "#2E7D32" },
                        { time: "12:38:14", msg: "Manyetik levitasyon kalibre edildi.", type: "#000000" },
                        { time: "12:38:29", msg: "Pnömatik fren hattı hazır (140 bar).", type: "#0288D1" },
                        { time: "12:38:40", msg: "Pod bekleme modundan çıkarıldı.", type: "#2E7D32" }
                    ]

                    Row {
                        width: parent.width
                        spacing: 8

                        // Mesaj tipine göre renklendirilen durum noktası
                        Rectangle {
                            width: 5
                            height: 5
                            radius: 2.5
                            color: modelData.type
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Zaman damgası
                        Text {
                            text: "[" + modelData.time + "]"
                            color: "#888888"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Log mesaj metni
                        Text {
                            width: parent.width - 80
                            text: modelData.msg
                            color: "#222222"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
