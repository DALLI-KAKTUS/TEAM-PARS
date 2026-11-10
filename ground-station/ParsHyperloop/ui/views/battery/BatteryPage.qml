// ui/views/battery/BatteryPage.qml
// Batarya sekmesinin ana sayfası.
// Batarya Yönetim Sistemi (BMS) verilerini; toplam şarj yüzdesini (SOC %),
// paket sıcaklığını, maksimum hücre voltaj farkını ve anlık çekilen akımı gösterir.
import QtQuick
import ParsHyperloop

Item {
    anchors.fill: parent

    // -------------------------------------------------------------------------
    // BMS ÖZET KARTI
    // -------------------------------------------------------------------------
    Rectangle {
        width: 320
        height: 240
        anchors { top: parent.top; left: parent.left; margins: 24 }
        color: Colors.panelBg
        radius: 14
        border.color: Colors.panelBorder
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Kart başlığı
            Text {
                text: "BATARYA YÖNETİM SİSTEMİ (BMS)"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
            }

            // Ana doluluk yüzdesi (SOC %)
            Text {
                text: "%94.2"
                color: Colors.textPrimary
                font.family: Colors.fontFamily
                font.pixelSize: 36
                font.weight: Font.Bold
            }

            Rectangle { width: parent.width; height: 1; color: Colors.panelBorder }

            // Alt batarya parametre satırları
            Row {
                width: parent.width
                Text { text: "Paket Sıcaklığı"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "28.4 °C"; color: Colors.statusNormal; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Row {
                width: parent.width
                Text { text: "Maks. Hücre Farkı"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "12 mV"; color: Colors.textPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Row {
                width: parent.width
                Text { text: "Anlık Akım Çekişi"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "142.8 A"; color: Colors.accentAero; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
        }
    }
}
