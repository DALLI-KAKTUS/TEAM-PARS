// ui/Main.qml
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Shapes
import ParsHyperloop
import "components"
import "views"

Window {
    id: window

    width: 1280
    height: 720
    minimumWidth: 1024
    minimumHeight: 600

    visible: true
    title: "Pars Hyperloop - Operasyon & Telemetri Paneli"
    color: Colors.bgPrimary

    // =========================================================================
    // SABİT ÜST KATMAN: TAKIM LOGOSU (MERKEZDE)
    // =========================================================================
    Image {
        id: teamLogo
        source: "qrc:/qt/qml/ParsHyperloop/assets/teampars.png"
        height: 270
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: true

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: -60
        }
        z: 50
    }

    // =========================================================================
    // SABİT ÜST KATMAN: LOGONUN SAĞINDAKİ HIZLI DURUM GÖSTERGELERİ
    // =========================================================================
    QuickStatusIndicators {
        id: topStatusIndicators
        anchors {
            right: parent.right
            rightMargin: 16
            verticalCenter: teamLogo.verticalCenter
        }
        z: 50
    }

    // =========================================================================
    // SABİT ÜST KATMAN: EN SOLDAKİ İKÇÜ LOGOSU
    // =========================================================================
    Image {
        id: ikcuLogo
        source: "qrc:/qt/qml/ParsHyperloop/assets/ikculogo.png"
        height: 120
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: true

        anchors {
            left: parent.left
            leftMargin: 24
            verticalCenter: topStatusIndicators.top
            verticalCenterOffset: 26
        }
        z: 50
    }

    // =========================================================================
    // SABİT ÜST KATMAN: İKÇÜ LOGOSUNUN SAĞINDAKİ AÇILIR-KAPANIR BİLDİRİM PANELİ
    // =========================================================================
    Rectangle {
        id: notificationPanel
        width: 310
        height: isExpanded ? 245 : 52
        radius: 16
        color: "#FFFFFF"
        clip: true
        z: 60

        property bool isExpanded: false

        anchors {
            left: ikcuLogo.right
            leftMargin: 16
            top: topStatusIndicators.top
        }

        // Açılma ve kapanma için akıcı dikey animasyon
        Behavior on height {
            NumberAnimation {
                duration: 340
                easing.type: Easing.OutCubic
            }
        }

        Column {
            anchors.fill: parent

            // --- PANEL BAŞLIK SATIRI (HER ZAMAN GÖRÜNÜR) ---
            Item {
                width: parent.width
                height: 52

                // KUTUYA TAM ORTALANAN BAŞLIK VE İKON GRUBU
                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    // Çan / Bildirim İkonu
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

                    // Aktif Bildirim Sayısı Rozeti
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

                // Açma / Kapama Ok İkonu (Chevron) - Sağ Kenarda Sabit
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

                // Tıklama Alanı
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notificationPanel.isExpanded = !notificationPanel.isExpanded
                }
            }

            // İnce Ayraç Çizgisi
            Rectangle {
                width: parent.width - 24
                height: 1
                color: "#E5E5E5"
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: notificationPanel.isExpanded ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // --- AŞAĞI AÇILAN LOG KAYITLARI LİSTESİ ---
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

                            Rectangle {
                                width: 5
                                height: 5
                                radius: 2.5
                                color: modelData.type
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "[" + modelData.time + "]"
                                color: "#888888"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                anchors.verticalCenter: parent.verticalCenter
                            }

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

    // =========================================================================
    // 1. KATMAN: TAM EKRAN KAYARAK GEÇEN SAYFA RAYI
    // =========================================================================
    Item {
        id: pageViewport
        anchors {
            top: parent.top
            bottom: bottomNav.top
            left: parent.left
            right: parent.right
            bottomMargin: 16
        }
        clip: true

        Item {
            id: slidingTrack
            width: pageViewport.width * 5
            height: pageViewport.height

            x: -bottomNav.currentIndex * pageViewport.width

            Behavior on x {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutCubic
                }
            }

            // Sekme 0: Genel Bakış
            Item {
                x: 0 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                OverviewView {}
            }

            // Sekme 1: Batarya
            Item {
                x: 1 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                BatteryView {}
            }

            // Sekme 2: Fren
            Item {
                x: 2 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                BrakeView {}
            }

            // Sekme 3: Haberleşme
            Item {
                x: 3 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                CommView {}
            }

            // Sekme 4: Analiz
            Item {
                x: 4 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                AnalyticsView {}
            }
        }
    }

    // =========================================================================
    // 2. KATMAN: ALT NAVİGASYON BARI
    // =========================================================================
    BottomNavBar {
        id: bottomNav
        currentIndex: 0
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 24
        }
    }
}
