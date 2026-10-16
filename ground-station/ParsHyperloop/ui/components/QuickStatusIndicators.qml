// ui/components/QuickStatusIndicators.qml
import QtQuick
import QtQuick.Shapes
import ParsHyperloop

Row {
    id: statusRow
    spacing: 12

    // =========================================================================
    // CANLI GÖREV SÜRESİ / SANİYE SAYACI DURUM YÖNETİMİ
    // =========================================================================
    property int missionSeconds: 0
    property bool isTimerRunning: true

    // Bildirim ve Bağlantı Durumları
    property bool isDisconnected: false
    property bool isOverlayActive: false
    property string overlayMessage: ""

    // Canlı saniye sayacı
    Timer {
        id: missionTimer
        interval: 1000
        repeat: true
        running: statusRow.isTimerRunning
        onTriggered: statusRow.missionSeconds++
    }

    // 2 saniyelik geçici durum bildirim zamanlayıcısı
    Timer {
        id: notificationTimer
        interval: 2000
        repeat: false
        onTriggered: {
            statusRow.isOverlayActive = false
        }
    }

    // Geçici durum mesajı tetikleyici fonksiyon
    function triggerNotification(msg) {
        if (statusRow.isDisconnected) return; // Bağlantı yokken araya mesaj sokulmaz
        statusRow.overlayMessage = msg;
        statusRow.isOverlayActive = true;
        notificationTimer.restart();
    }

    function formatTime(totalSeconds) {
        const m = Math.floor(totalSeconds / 60);
        const s = totalSeconds % 60;
        const mm = m < 10 ? "0" + m : m;
        const ss = s < 10 ? "0" + s : s;
        return mm + ":" + ss;
    }

    // =========================================================================
    // ORTAK BUTON + ALT METİN ŞABLONU
    // =========================================================================
    component StatusItem: Column {
        id: itemCol
        spacing: 6
        width: customWidth

        property bool isActive: true
        property string iconType: ""
        property string labelText: ""
        property real customWidth: 50
        signal customClicked()

        // --- BUTON KUTUSU ---
        Rectangle {
            id: btn
            anchors.horizontalCenter: parent.horizontalCenter
            width: itemCol.customWidth
            height: 52
            radius: height / 2

            // Aktifken beyaz, pasifken mat gri
            color: itemCol.isActive ? (btnMouse.containsMouse ? "#EBEBEB" : "#FFFFFF") : "#CFCFCF"

            scale: btnMouse.pressed ? 0.94 : (btnMouse.containsMouse ? 1.04 : 1.0)
            Behavior on scale { NumberAnimation { duration: 120 } }
            Behavior on color { ColorAnimation { duration: 180 } }

            // =================================================================
            // İÇ İÇERİK
            // =================================================================
            Item {
                id: iconArea
                anchors.fill: parent

                // --- 0. T+0 SAYAÇ & DİNAMİK BİLDİRİM ALANI ---
                Item {
                    anchors.fill: parent
                    visible: itemCol.iconType === "timer"

                    // NORMAL DURUM: T+0 : 00:00 Sayacı
                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        opacity: (!statusRow.isDisconnected && !statusRow.isOverlayActive) ? 1.0 : 0.0
                        scale: (!statusRow.isDisconnected && !statusRow.isOverlayActive) ? 1.0 : 0.85

                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

                        Text {
                            text: "T+0"
                            color: "#000000"
                            font.family: Colors.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Black
                            font.letterSpacing: 0.5
                        }

                        Text {
                            text: ":"
                            color: "#000000"
                            font.family: Colors.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        Text {
                            text: statusRow.formatTime(statusRow.missionSeconds)
                            color: "#000000"
                            font.family: Colors.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            font.letterSpacing: 0.5
                        }
                    }

                    // GEÇİŞ DURUMU: "BAĞLANTI YOK" veya 2 Saniyelik Sistem Mesajı
                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 16
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight

                        text: statusRow.isDisconnected ? "BAĞLANTI YOK" : statusRow.overlayMessage
                        color: statusRow.isDisconnected ? "#D32F2F" : "#000000"
                        font.family: Colors.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Black
                        font.letterSpacing: 0.6

                        opacity: (statusRow.isDisconnected || statusRow.isOverlayActive) ? 1.0 : 0.0
                        scale: (statusRow.isDisconnected || statusRow.isOverlayActive) ? 1.0 : 0.85

                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                    }
                }

                // --- 1. ELEKTRİK MOTORU (FİŞ SEMBOLÜ) ---
                Shape {
                    anchors.centerIn: parent
                    width: 30
                    height: 30
                    visible: itemCol.iconType === "motor"
                    opacity: itemCol.isActive ? 1.0 : 0.35

                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 2.6
                        capStyle: ShapePath.RoundCap
                        startX: 10; startY: 3; PathLine { x: 10; y: 9 }
                    }
                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 2.6
                        capStyle: ShapePath.RoundCap
                        startX: 20; startY: 3; PathLine { x: 20; y: 9 }
                    }

                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 2.4
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin

                        startX: 7; startY: 9
                        PathLine { x: 23; y: 9 }
                        PathLine { x: 23; y: 19 }
                        PathQuad { x: 17; y: 23; controlX: 21; controlY: 23 }
                        PathLine { x: 13; y: 23 }
                        PathQuad { x: 7; y: 19; controlX: 9; controlY: 23 }
                        PathLine { x: 7; y: 9 }
                    }

                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 2.6
                        capStyle: ShapePath.RoundCap
                        startX: 15; startY: 23; PathLine { x: 15; y: 28 }
                    }
                }

                // --- 2. HABERLEŞME / WI-FI ---
                Item {
                    anchors.centerIn: parent
                    width: 30
                    height: 28
                    visible: itemCol.iconType === "wifi"
                    opacity: itemCol.isActive ? 1.0 : 0.35

                    Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: "#000000"
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Shape {
                        anchors.fill: parent

                        ShapePath {
                            strokeColor: "#000000"
                            strokeWidth: 2.4
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 10; startY: 18
                            PathArc { x: 20; y: 18; radiusX: 7; radiusY: 7; useLargeArc: false }
                        }

                        ShapePath {
                            strokeColor: "#000000"
                            strokeWidth: 2.4
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 6; startY: 13
                            PathArc { x: 24; y: 13; radiusX: 13; radiusY: 13; useLargeArc: false }
                        }

                        ShapePath {
                            strokeColor: "#000000"
                            strokeWidth: 2.4
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 2; startY: 8
                            PathArc { x: 28; y: 8; radiusX: 19; radiusY: 19; useLargeArc: false }
                        }
                    }
                }

                // --- 3. FREN SİSTEMİ ---
                Item {
                    anchors.centerIn: parent
                    width: 28
                    height: 28
                    visible: itemCol.iconType === "brake"
                    opacity: itemCol.isActive ? 1.0 : 0.35

                    Rectangle {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        radius: width / 2
                        color: "transparent"
                        border.color: "#000000"
                        border.width: 2.2

                        Text {
                            anchors.centerIn: parent
                            text: "!"
                            font.pixelSize: 11
                            font.weight: Font.Black
                            color: "#000000"
                        }
                    }

                    Shape {
                        anchors.fill: parent

                        ShapePath {
                            strokeColor: "#000000"
                            strokeWidth: 2.4
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 3; startY: 6
                            PathQuad { x: 3; y: 22; controlX: -1; controlY: 14 }
                        }

                        ShapePath {
                            strokeColor: "#000000"
                            strokeWidth: 2.4
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 25; startY: 6
                            PathQuad { x: 25; y: 22; controlX: 29; controlY: 14 }
                        }
                    }
                }

                // --- 4. UYARI / İKAZ ÜÇGENİ ---
                Shape {
                    anchors.centerIn: parent
                    width: 28
                    height: 26
                    visible: itemCol.iconType === "warning"
                    opacity: itemCol.isActive ? 1.0 : 0.35

                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 2.4
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin

                        startX: 14; startY: 2
                        PathLine { x: 27; y: 24 }
                        PathLine { x: 1; y: 24 }
                        PathLine { x: 14; y: 2 }
                    }

                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 2.4
                        capStyle: ShapePath.RoundCap
                        startX: 14; startY: 9; PathLine { x: 14; y: 15.5 }
                    }

                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 2.4
                        capStyle: ShapePath.RoundCap
                        startX: 14; startY: 19.5; PathLine { x: 14; y: 20 }
                    }
                }

                // --- 5. E-STOP METNİ ---
                Text {
                    anchors.centerIn: parent
                    visible: itemCol.iconType === "estop"
                    opacity: itemCol.isActive ? 1.0 : 0.35
                    text: "E-STOP"
                    color: "#000000"
                    font.family: Colors.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Black
                    font.letterSpacing: 1.2
                }
            }

            // --- PASİF DURUMDA ÇIKAN KIRMIZI ÇİZİK (SAYAÇ HARİÇ) ---
            Shape {
                anchors.fill: parent
                visible: !itemCol.isActive && itemCol.iconType !== "timer"
                z: 20

                ShapePath {
                    strokeColor: "#E53935"
                    strokeWidth: 3.2
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    startX: 10
                    startY: 10
                    PathLine { x: btn.width - 10; y: btn.height - 10 }
                }
            }

            MouseArea {
                id: btnMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (itemCol.iconType !== "timer") {
                        itemCol.isActive = !itemCol.isActive
                    }
                    itemCol.customClicked()
                }
            }
        }

        // --- ALT ETİKET METNİ ---
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: itemCol.labelText
            color: itemCol.isActive ? "#FFFFFF" : "#888888"
            font.family: Colors.fontFamily
            font.pixelSize: 12
            font.weight: Font.Bold
            font.letterSpacing: 0.6
        }
    }

    // =========================================================================
    // SIRALAMA VE ETKİLEŞİM TANIMLARI
    // =========================================================================

    // 1. T+0 Saniye Sayacı Kutusu
    StatusItem {
        id: timerItem
        iconType: "timer"
        labelText: "Dinamik Panel"
        customWidth: 190
    }

    // 2. Motor
    StatusItem {
        id: motorItem
        iconType: "motor"
        labelText: "Motor"
        onCustomClicked: {
            statusRow.triggerNotification(motorItem.isActive ? "MOTOR DEVREDE" : "MOTOR DURDU")
        }
    }

    // 3. Bağlantı (Sayaç kontrolcüsü)
    StatusItem {
        id: wifiItem
        iconType: "wifi"
        labelText: "Bağlantı"
        onCustomClicked: {
            if (!wifiItem.isActive) {
                // Bağlantı koptu -> Sayaç durur, "BAĞLANTI YOK" gösterilir
                statusRow.isTimerRunning = false
                statusRow.isDisconnected = true
            } else {
                // Bağlantı geldi -> Sayaç sıfırlanır, baştan başlar
                statusRow.isDisconnected = false
                statusRow.missionSeconds = 0
                statusRow.isTimerRunning = true
            }
        }
    }

    // 4. Fren
    StatusItem {
        id: brakeItem
        iconType: "brake"
        labelText: "Fren"
        onCustomClicked: {
            statusRow.triggerNotification(brakeItem.isActive ? "FREN DEVREYE GİRDİ" : "FREN DEVRE DIŞI")
        }
    }

    // 5. Uyarı
    StatusItem {
        id: warningItem
        iconType: "warning"
        labelText: "Uyarı"
        onCustomClicked: {
            statusRow.triggerNotification(warningItem.isActive ? "UYARI DEVREYE GİRDİ" : "UYARI KAPATILDI")
        }
    }

    // 6. Acil Stop
    StatusItem {
        id: estopItem
        iconType: "estop"
        labelText: "Acil Stop"
        customWidth: 120
        onCustomClicked: {
            statusRow.triggerNotification(estopItem.isActive ? "E-STOP BIRAKILDI" : "E-STOP DEVREDE")
        }
    }
}
