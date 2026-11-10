// ui/views/communication/CommunicationPage.qml
// Haberleşme sekmesinin ana sayfası.
// Yer istasyonu ile kapsül arasındaki kablosuz telemetri linkinin gecikme süresini (ms),
// sinyal gücünü (RSSI dBm), paket kayıp oranını ve çalışma frekansını gösterir.
import QtQuick
import ParsHyperloop

Item {
    // -------------------------------------------------------------------------
    // HABERLEŞME LİNKİ ÖZET KARTI
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
                text: "HABERLEŞME & KONTROL LİNKİ"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }

            // Anlık uçtan uca gecikme süresi (Latency)
            Text {
                text: "2.4 ms"
                color: Colors.textPrimary
                font.family: Colors.fontFamily
                font.pixelSize: 36
                font.weight: Font.Bold
            }

            Rectangle { width: parent.width; height: 1; color: Colors.panelBorder }

            // Alt haberleşme parametre satırları
            Row {
                width: parent.width
                Text { text: "Sinyal Gücü (RSSI)"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "-48 dBm"; color: Colors.statusNormal; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Row {
                width: parent.width
                Text { text: "Paket Kaybı"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "%0.01"; color: Colors.statusNormal; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Row {
                width: parent.width
                Text { text: "Ana Frekans"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "5.8 GHz"; color: Colors.accentAero; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
        }
    }
}
