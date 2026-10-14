// ui/views/BrakeView.qml
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
                text: "FREN SİSTEMİ (EDDY CURRENT & PNEUMATIC)"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }

            Text {
                text: "STANDBY"
                color: Colors.statusNormal
                font.family: Colors.fontFamily
                font.pixelSize: 32
                font.weight: Font.Bold
            }

            Rectangle { width: parent.width; height: 1; color: Colors.panelBorder }

            Row {
                width: parent.width
                Text { text: "Hava Boşluğu"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "8.5 mm"; color: Colors.textPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Row {
                width: parent.width
                Text { text: "Disk Sıcaklığı"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "34.2 °C"; color: Colors.statusNormal; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Row {
                width: parent.width
                Text { text: "Pnömatik Basınç"; color: Colors.textSecondary; font.pixelSize: 12; width: 150 }
                Text { text: "120 bar"; color: Colors.accentAero; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
        }
    }
}
