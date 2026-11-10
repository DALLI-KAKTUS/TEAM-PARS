// ui/views/overview/OverviewModeSwitch.qml
// Genel Bakış sayfasının üst ortasında duran "Simülasyon | Yarışma" mod anahtarı.
// Hangi mod seçiliyse o tarafın arka planı siyah, yazısı beyaz olur; pasif olan
// taraf ise beyaz arka plan üzerine siyah yazı olarak kalır.
import QtQuick
import ParsHyperloop

Rectangle {
    id: selectorRoot
    width: 270
    height: 42
    radius: height / 2
    color: "transparent"
    clip: true

    // true: Simülasyon (3B Model), false: Yarışma (Kokpit HUD)
    property bool isSimulationMode: true

    Row {
        anchors.fill: parent

        // ---------------------------------------------------------------------
        // 1. SOL YARI: SİMÜLASYON MODU BUTONU
        // ---------------------------------------------------------------------
        Item {
            id: simBtn
            width: parent.width / 2
            height: parent.height

            Rectangle {
                id: simBg
                anchors.fill: parent
                radius: parent.height / 2
                color: selectorRoot.isSimulationMode ? "#000000" : "#FFFFFF"

                // Sol dış kenar yuvarlak kalırken orta birleşim yerinin düz inmesi için
                // sağ yarıçap kadar alanı düz dikdörtgenle kapatıyoruz.
                Rectangle {
                    anchors.right: parent.right
                    width: parent.radius
                    height: parent.height
                    color: simBg.color
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 600
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Simülasyon"
                color: selectorRoot.isSimulationMode ? "#FFFFFF" : "#000000"
                font.family: Colors.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                font.letterSpacing: 0.5

                Behavior on color {
                    ColorAnimation {
                        duration: 600
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: selectorRoot.isSimulationMode = true
            }
        }

        // ---------------------------------------------------------------------
        // 2. SAĞ YARI: YARIŞMA MODU BUTONU
        // ---------------------------------------------------------------------
        Item {
            id: compBtn
            width: parent.width / 2
            height: parent.height

            Rectangle {
                id: compBg
                anchors.fill: parent
                radius: parent.height / 2
                color: !selectorRoot.isSimulationMode ? "#000000" : "#FFFFFF"

                // Orta birleşim yerini dik tutmak için sol kenarı düz dikdörtgenle tamamlıyoruz
                Rectangle {
                    anchors.left: parent.left
                    width: parent.radius
                    height: parent.height
                    color: compBg.color
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 600
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Yarışma"
                color: !selectorRoot.isSimulationMode ? "#FFFFFF" : "#000000"
                font.family: Colors.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                font.letterSpacing: 0.5

                Behavior on color {
                    ColorAnimation {
                        duration: 600
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: selectorRoot.isSimulationMode = false
            }
        }
    }

    // İki mod butonunu tam ortadan bölen 2px beyaz dikey çizgi
    Rectangle {
        width: 2
        height: parent.height
        anchors.centerIn: parent
        color: "#FFFFFF"
        z: 16
    }

    // Kapsül anahtarın etrafını saran 2px beyaz dış çerçeve
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: "#FFFFFF"
        border.width: 2
        z: 15
    }
}
