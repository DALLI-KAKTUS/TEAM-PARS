// ui/shell/TopControlBar.qml
// Sağ üst köşede tüm sekmelerde sabit duran 3 parçalı komuta konsolu:
// 1. Dinamik Panel: Görev süresini (T+0 | 00:00) ve 2.2 saniyelik anlık durum bildirimlerini gösterir.
// 2. Sistem Kontrol Matrisi: Motor, Bağlantı, Fren ve Uyarı hatlarını açıp kapatan 4 anahtar.
// 3. Taktiksel E-STOP Ünitesi: Yarışma kokpitiyle senkron çalışan acil durdurma butonu.
import QtQuick
import QtQuick.Shapes
import ParsHyperloop

Item {
    id: statusRoot
    width: commandRow.width
    height: 52

    // -------------------------------------------------------------------------
    // DIŞA AÇIK SİSTEM DURUMLARI VE SİNYALLER
    // Main.qml üzerinden Genel Bakış sayfasındaki yarışma kokpitine bağlanır.
    // -------------------------------------------------------------------------
    property int missionSeconds: 0
    property bool isTimerRunning: true

    property bool motorActive: true
    property bool linkActive: true
    property bool brakeActive: true
    property bool warningActive: true
    property bool eStopEngaged: false

    // Bağlantı kesildiğinde sayaç durur ve sol kutu "BAĞLANTI YOK" moduna geçer
    readonly property bool isDisconnected: !linkActive
    property bool isOverlayActive: false
    property string overlayMessage: ""

    signal emergencyStopActivated()
    signal emergencyStopReleased()

    // Saniyede bir artan görev süresi sayacı (bağlantı varken çalışır)
    Timer {
        id: missionTimer
        interval: 1000
        repeat: true
        running: statusRoot.isTimerRunning && !statusRoot.isDisconnected
        onTriggered: statusRoot.missionSeconds++
    }

    // Bir anahtara basıldığında çıkan durum mesajını 2.2 saniye sonra kapatıp sayaca döner
    Timer {
        id: notificationTimer
        interval: 2200
        repeat: false
        onTriggered: statusRoot.isOverlayActive = false
    }

    // Canlı sinyal çubuklarını ve ikaz ışıklarını hareketlendiren 320 ms'lik adım sayacı
    property int animStep: 0
    Timer {
        interval: 320
        repeat: true
        running: true
        onTriggered: statusRoot.animStep = (statusRoot.animStep + 1) % 6
    }

    // Dinamik panelde geçici bildirim mesajı göstermek için çağrılır
    function triggerNotification(msg) {
        if (statusRoot.isDisconnected && msg !== "BAĞLANTI YOK") {
            return
        }
        statusRoot.overlayMessage = msg
        statusRoot.isOverlayActive = true
        notificationTimer.restart()
    }

    // Yarışma kokpitinden E-STOP veya E-START tetiklendiğinde buradaki E-STOP butonunu eşitler
    function setEmergencyStop(engaged, silent) {
        if (statusRoot.eStopEngaged === engaged) {
            return
        }
        statusRoot.eStopEngaged = engaged
        if (!silent) {
            statusRoot.triggerNotification(engaged ? "E-STOP DEVREDE" : "E-STOP BIRAKILDI")
        }
    }

    // Saniye değerini "AA:SS" (örn. 02:15) formatına çevirir
    function formatTime(totalSeconds) {
        const m = Math.floor(totalSeconds / 60)
        const s = totalSeconds % 60
        const mm = m < 10 ? "0" + m : "" + m
        const ss = s < 10 ? "0" + s : "" + s
        return mm + ":" + ss
    }

    // -------------------------------------------------------------------------
    // ALT BİLEŞEN: SİSTEM KANAL ANAHTARI (MOTOR / BAĞLANTI / FREN / UYARI)
    // Ortadaki 4'lü kontrol matrisinde tekrar eden buton yapısı. Aktifken beyaz
    // zemin üzerine siyah ikon, devre dışıyken siyah zemin üzerine üstü çizili
    // soluk ikon çizer.
    // -------------------------------------------------------------------------
    component SystemChannelKey: Item {
        id: keyRoot
        width: 49
        height: 44

        property bool active: true
        property string iconType: ""
        property string titleText: ""
        signal toggled()

        Rectangle {
            id: keySurface
            anchors.fill: parent
            radius: 12

            color: keyRoot.active
                   ? (keyMouse.containsMouse ? "#ECECEF" : "#FFFFFF")
                   : (keyMouse.containsMouse ? "#16181D" : "#000000")
            border.width: keyRoot.active ? 0 : 1.0
            border.color: Qt.rgba(1, 1, 1, 0.20)

            scale: keyMouse.pressed ? 0.93 : (keyMouse.containsMouse ? 1.03 : 1.0)
            Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 180 } }

            // Sağ üst köşedeki küçük aktiflik noktası
            Rectangle {
                x: parent.width - 7
                y: 4
                width: 3.5
                height: 3.5
                radius: 2
                color: keyRoot.active ? "#000000" : "transparent"
                border.width: keyRoot.active ? 0 : 1
                border.color: Qt.rgba(1, 1, 1, 0.35)
            }

            // Butonun ortasındaki vektörel ikon çizim alanı
            Item {
                id: iconBox
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                width: 20
                height: 20
                opacity: keyRoot.active ? 1.0 : 0.45

                readonly property color ink: keyRoot.active ? "#000000" : "#FFFFFF"

                // "motor" tipi için elektrik motoru / soket sembolü
                Shape {
                    anchors.fill: parent
                    visible: keyRoot.iconType === "motor"

                    ShapePath {
                        strokeColor: iconBox.ink
                        strokeWidth: 1.8
                        capStyle: ShapePath.RoundCap
                        startX: 7; startY: 2.2; PathLine { x: 7; y: 6.2 }
                    }
                    ShapePath {
                        strokeColor: iconBox.ink
                        strokeWidth: 1.8
                        capStyle: ShapePath.RoundCap
                        startX: 13; startY: 2.2; PathLine { x: 13; y: 6.2 }
                    }
                    ShapePath {
                        strokeColor: iconBox.ink
                        strokeWidth: 1.7
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin
                        startX: 4.8; startY: 6.2
                        PathLine { x: 15.2; y: 6.2 }
                        PathLine { x: 15.2; y: 12.0 }
                        PathQuad { x: 11.5; y: 15.0; controlX: 14.5; controlY: 15.0 }
                        PathLine { x: 8.5; y: 15.0 }
                        PathQuad { x: 4.8; y: 12.0; controlX: 5.5; controlY: 15.0 }
                        PathLine { x: 4.8; y: 6.2 }
                    }
                    ShapePath {
                        strokeColor: iconBox.ink
                        strokeWidth: 1.8
                        capStyle: ShapePath.RoundCap
                        startX: 10; startY: 15.0; PathLine { x: 10; y: 18.2 }
                    }
                }

                // "wifi" tipi için 3 yaylı kablosuz haberleşme sembolü
                Item {
                    anchors.fill: parent
                    visible: keyRoot.iconType === "wifi"

                    Rectangle {
                        width: 3.4
                        height: 3.4
                        radius: 1.7
                        color: iconBox.ink
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2.2
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Shape {
                        anchors.fill: parent

                        ShapePath {
                            strokeColor: iconBox.ink
                            strokeWidth: 1.7
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 6.8; startY: 13.0
                            PathArc { x: 13.2; y: 13.0; radiusX: 4.5; radiusY: 4.5; useLargeArc: false }
                        }
                        ShapePath {
                            strokeColor: iconBox.ink
                            strokeWidth: 1.7
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 4.2; startY: 9.8
                            PathArc { x: 15.8; y: 9.8; radiusX: 8.2; radiusY: 8.2; useLargeArc: false }
                        }
                        ShapePath {
                            strokeColor: iconBox.ink
                            strokeWidth: 1.7
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 1.8; startY: 6.6
                            PathArc { x: 18.2; y: 6.6; radiusX: 12.0; radiusY: 12.0; useLargeArc: false }
                        }
                    }
                }

                // "brake" tipi için iki yanında fren balatası olan ünlem diski sembolü
                Item {
                    anchors.fill: parent
                    visible: keyRoot.iconType === "brake"

                    Rectangle {
                        anchors.centerIn: parent
                        width: 11
                        height: 11
                        radius: 5.5
                        color: "transparent"
                        border.color: iconBox.ink
                        border.width: 1.6

                        Text {
                            anchors.centerIn: parent
                            text: "!"
                            font.family: Colors.fontFamily
                            font.pixelSize: 8
                            font.weight: Font.Black
                            color: iconBox.ink
                        }
                    }

                    Shape {
                        anchors.fill: parent

                        ShapePath {
                            strokeColor: iconBox.ink
                            strokeWidth: 1.7
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 3.0; startY: 4.8
                            PathQuad { x: 3.0; y: 15.2; controlX: 0.2; controlY: 10.0 }
                        }
                        ShapePath {
                            strokeColor: iconBox.ink
                            strokeWidth: 1.7
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            startX: 17.0; startY: 4.8
                            PathQuad { x: 17.0; y: 15.2; controlX: 19.8; controlY: 10.0 }
                        }
                    }
                }

                // "warning" tipi için üçgen uyarı levhası sembolü
                Shape {
                    anchors.fill: parent
                    visible: keyRoot.iconType === "warning"

                    ShapePath {
                        strokeColor: iconBox.ink
                        strokeWidth: 1.7
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin
                        startX: 10; startY: 2.8
                        PathLine { x: 18.0; y: 16.5 }
                        PathLine { x: 2.0; y: 16.5 }
                        PathLine { x: 10; y: 2.8 }
                    }
                    ShapePath {
                        strokeColor: iconBox.ink
                        strokeWidth: 1.7
                        capStyle: ShapePath.RoundCap
                        startX: 10; startY: 7.8; PathLine { x: 10; y: 11.6 }
                    }
                    ShapePath {
                        strokeColor: iconBox.ink
                        strokeWidth: 1.9
                        capStyle: ShapePath.RoundCap
                        startX: 10; startY: 14.0; PathLine { x: 10; y: 14.2 }
                    }
                }

                // Kanal kapatıldığında ikonun üzerine çekilen çapraz devre dışı çizgisi
                Shape {
                    anchors.fill: parent
                    visible: !keyRoot.active

                    ShapePath {
                        strokeColor: "#000000"
                        strokeWidth: 3.6
                        capStyle: ShapePath.RoundCap
                        startX: 2; startY: 2
                        PathLine { x: 18; y: 18 }
                    }
                    ShapePath {
                        strokeColor: "#FFFFFF"
                        strokeWidth: 1.6
                        capStyle: ShapePath.RoundCap
                        startX: 2; startY: 2
                        PathLine { x: 18; y: 18 }
                    }
                }
            }

            // İkonun altındaki kanal adı ("MOTOR", "BAĞLANTI" vb.)
            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                anchors.horizontalCenter: parent.horizontalCenter
                text: keyRoot.titleText
                color: keyRoot.active ? "#000000" : Qt.rgba(1, 1, 1, 0.48)
                font.family: Colors.fontFamily
                font.pixelSize: 8
                font.weight: Font.Black
                font.letterSpacing: 0.2

                Behavior on color { ColorAnimation { duration: 160 } }
            }

            MouseArea {
                id: keyMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: keyRoot.toggled()
            }
        }
    }

    // =========================================================================
    // ANA KOMUTA SATIRI (SOLDA DİNAMİK PANEL · ORTADA 4'LÜ MATRİS · SAĞDA E-STOP)
    // =========================================================================
    Row {
        id: commandRow
        height: 52
        spacing: 7

        // ---------------------------------------------------------------------
        // 1. MODÜL: DİNAMİK PANEL (GÖREV SAYACI VE DURUM BİLDİRİM EKRANI)
        // Normalde görev süresini sayar. Bir kanala tıklandığında 2.2 saniyeliğine
        // durum mesajını ("MOTOR DURDU", "E-START AKTİF" vb.) gösterir. Bağlantı
        // koptuğunda ise siyah zemine dönerek "BAĞLANTI YOK" uyarısına kilitlenir.
        // ---------------------------------------------------------------------
        Rectangle {
            id: dynamicModule
            width: 130
            height: 52
            radius: 16
            color: statusRoot.isDisconnected ? "#000000" : "#FFFFFF"
            border.width: statusRoot.isDisconnected ? 1.6 : 1.0
            border.color: statusRoot.isDisconnected ? "#FFFFFF" : Qt.rgba(0, 0, 0, 0.08)

            Behavior on color { ColorAnimation { duration: 200 } }

            // Üst satır: Yanıp sönen durum noktası, modül başlığı ve 3'lü sinyal çubuğu
            Item {
                anchors.top: parent.top
                anchors.topMargin: 7
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                height: 11

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 4.5
                        height: 4.5
                        radius: 2.25
                        color: statusRoot.isDisconnected ? "#FFFFFF" : "#000000"
                        opacity: (statusRoot.animStep % 2 === 0) ? 1.0 : 0.32
                        Behavior on opacity { NumberAnimation { duration: 240 } }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: statusRoot.isDisconnected
                              ? "BAĞLANTI KESİK"
                              : (statusRoot.isOverlayActive ? "DURUM BİLDİRİMİ" : "DİNAMİK PANEL")
                        color: statusRoot.isDisconnected ? Qt.rgba(1, 1, 1, 0.65) : Qt.rgba(0, 0, 0, 0.50)
                        font.family: Colors.fontFamily
                        font.pixelSize: 8
                        font.weight: Font.Black
                        font.letterSpacing: 0.6
                    }
                }

                // Sağ üstte hareket eden 3'lü veri akış barı
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1.5
                    visible: !statusRoot.isDisconnected

                    Repeater {
                        model: 3
                        Rectangle {
                            required property int index
                            width: 2
                            height: ((statusRoot.animStep + index) % 3 === 0) ? 8 : (((statusRoot.animStep + index) % 3 === 1) ? 5 : 3)
                            radius: 1
                            anchors.bottom: parent.bottom
                            color: Qt.rgba(0, 0, 0, 0.45)
                            Behavior on height { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }

            // A. Normal Görev Sayacı Görünümü (T+0 | 00:00)
            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 7
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                opacity: (!statusRoot.isDisconnected && !statusRoot.isOverlayActive) ? 1.0 : 0.0
                scale: (!statusRoot.isDisconnected && !statusRoot.isOverlayActive) ? 1.0 : 0.90

                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: 17
                    radius: 5
                    color: "#000000"

                    Text {
                        anchors.centerIn: parent
                        text: "T+0"
                        color: "#FFFFFF"
                        font.family: Colors.fontFamily
                        font.pixelSize: 9
                        font.weight: Font.Black
                        font.letterSpacing: 0.5
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: statusRoot.formatTime(statusRoot.missionSeconds)
                    color: "#000000"
                    font.family: Colors.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Black
                    font.letterSpacing: 0.8
                    font.features: { "tnum": 1 }
                }
            }

            // B. Bildirim veya Bağlantı Kesik Metni Görünümü
            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 14
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight

                text: statusRoot.isDisconnected ? "BAĞLANTI YOK" : statusRoot.overlayMessage
                color: statusRoot.isDisconnected ? "#FFFFFF" : "#000000"
                font.family: Colors.fontFamily
                font.pixelSize: 10
                font.weight: Font.Black
                font.letterSpacing: 0.5

                opacity: (statusRoot.isDisconnected || statusRoot.isOverlayActive) ? 1.0 : 0.0
                scale: (statusRoot.isDisconnected || statusRoot.isOverlayActive) ? 1.0 : 0.90

                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
            }
        }

        // ---------------------------------------------------------------------
        // 2. MODÜL: 4'LÜ SİSTEM KONTROL MATRİSİ
        // Yukarıda tanımladığımız `SystemChannelKey` bileşeninden 4 adet kullanarak
        // Motor, Bağlantı, Fren ve Uyarı kanallarını yan yana dizer.
        // ---------------------------------------------------------------------
        Rectangle {
            id: systemMatrixDock
            width: 215
            height: 52
            radius: 16
            color: "#000000"
            border.color: Qt.rgba(1, 1, 1, 0.42)
            border.width: 1.4

            Row {
                anchors.centerIn: parent
                spacing: 3

                SystemChannelKey {
                    iconType: "motor"
                    titleText: "MOTOR"
                    active: statusRoot.motorActive
                    onToggled: {
                        statusRoot.motorActive = !statusRoot.motorActive
                        statusRoot.triggerNotification(statusRoot.motorActive ? "MOTOR DEVREDE" : "MOTOR DURDU")
                    }
                }

                SystemChannelKey {
                    iconType: "wifi"
                    titleText: "BAĞLANTI"
                    active: statusRoot.linkActive
                    onToggled: {
                        statusRoot.linkActive = !statusRoot.linkActive
                        if (!statusRoot.linkActive) {
                            statusRoot.isTimerRunning = false
                            statusRoot.isOverlayActive = false
                        } else {
                            statusRoot.missionSeconds = 0
                            statusRoot.isTimerRunning = true
                            statusRoot.triggerNotification("BAĞLANTI KURULDU")
                        }
                    }
                }

                SystemChannelKey {
                    iconType: "brake"
                    titleText: "FREN"
                    active: statusRoot.brakeActive
                    onToggled: {
                        statusRoot.brakeActive = !statusRoot.brakeActive
                        statusRoot.triggerNotification(statusRoot.brakeActive ? "FREN DEVREDE" : "FREN DEVRE DIŞI")
                    }
                }

                SystemChannelKey {
                    iconType: "warning"
                    titleText: "UYARI"
                    active: statusRoot.warningActive
                    onToggled: {
                        statusRoot.warningActive = !statusRoot.warningActive
                        statusRoot.triggerNotification(statusRoot.warningActive ? "UYARI AKTİF" : "UYARI KAPATILDI")
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // 3. MODÜL: ACİL DURDURMA (E-STOP) BUTONU
        // Normalde siyah zeminli durur; devreye girdiğinde (`eStopEngaged: true`)
        // tam beyaz zemine dönerek üstteki ikaz çizgisini yanıp söndürür.
        // ---------------------------------------------------------------------
        Rectangle {
            id: estopUnit
            width: 80
            height: 52
            radius: 16
            color: "#000000"
            border.color: "#FFFFFF"
            border.width: 1.8

            scale: estopMouse.pressed ? 0.93 : (estopMouse.containsMouse ? 1.03 : 1.0)
            Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: 12
                color: statusRoot.eStopEngaged
                       ? "#FFFFFF"
                       : (estopMouse.containsMouse ? "#17191E" : "#000000")
                border.color: statusRoot.eStopEngaged ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.35)
                border.width: 1.0

                Behavior on color { ColorAnimation { duration: 170 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    // Üst ikaz çizgisi
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 24
                        height: 2.2
                        radius: 1.1
                        color: statusRoot.eStopEngaged ? "#000000" : "#FFFFFF"
                        opacity: statusRoot.eStopEngaged ? ((statusRoot.animStep % 2 === 0) ? 1.0 : 0.3) : 0.85
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "E-STOP"
                        color: statusRoot.eStopEngaged ? "#000000" : "#FFFFFF"
                        font.family: Colors.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Black
                        font.letterSpacing: 1.0
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: statusRoot.eStopEngaged ? "DEVREDE" : "ACİL STOP"
                        color: statusRoot.eStopEngaged ? "#000000" : Qt.rgba(1, 1, 1, 0.62)
                        font.family: Colors.fontFamily
                        font.pixelSize: 7
                        font.weight: Font.Black
                        font.letterSpacing: 0.6
                    }
                }
            }

            MouseArea {
                id: estopMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    statusRoot.eStopEngaged = !statusRoot.eStopEngaged
                    if (statusRoot.eStopEngaged) {
                        statusRoot.triggerNotification("E-STOP DEVREDE")
                        statusRoot.emergencyStopActivated()
                    } else {
                        statusRoot.triggerNotification("E-STOP BIRAKILDI")
                        statusRoot.emergencyStopReleased()
                    }
                }
            }
        }
    }
}
