// ui/views/AnalyticsView.qml
import QtQuick
import ParsHyperloop

Item {
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

            Text {
                text: "GÖREV ANALİZİ & LOGLAR"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }

            Text {
                text: "4,250 m"
                color: Colors.textPrimary
                font.family: Colors.fontFamily
                font.pixelSize: 36
                font.weight: Font.Bold
            }

            Rectangle { width: parent.width; height: 1; color: Colors.panelBorder }

            Row {
                width: parent.width
                Text { text: "Kalan Mesafe"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "1,750 m"; color: Colors.textPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Row {
                width: parent.width
                Text { text: "Tepe Hız"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "1,082 km/h"; color: Colors.accentAero; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Row {
                width: parent.width
                Text { text: "Ortalama İvme"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "+1.15 G"; color: Colors.statusNormal; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
        }
    }
}
