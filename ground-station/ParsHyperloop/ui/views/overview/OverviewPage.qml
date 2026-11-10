// ui/views/overview/OverviewPage.qml
// Genel Bakış sekmesinin ana sayfası.
// Kendi içinde dikey olarak kayabilen 2 katlı bir yapıya sahiptir:
// - Üst Kat (`topSection`): Ortadaki mod anahtarına (`OverviewModeSwitch`) göre
//   ya 3B Kapsül İnceleme Sahnesini (`Pod3DInspectionScene`) ya da Yarışma
//   Kokpitini (`CompetitionCockpit`) gösterir.
// - Alt Kat (`OverviewDetailSection`): Ekranın altındaki yuvarlak ok butonuna
//   tıklandığında yukarı kayarak açılan detay bölümüdür.
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import ParsHyperloop
import "pod3d"
import "cockpit"

Item {
    id: overviewRoot
    anchors.fill: parent
    clip: true

    // Dikey sayfa durumu (false: Üst Sahne görünür, true: Alt Detay bölümü görünür)
    property bool isDownView: false

    // Çalışma Modu (true: 3B Simülasyon Modu [Varsayılan], false: Yarışma Kokpiti Modu)
    property bool isSimulationMode: true

    // Main.qml'deki üst komuta barından gelen canlı Bağlantı ve Motor izin durumları
    property bool linkOk: true
    property bool motorEnabled: true

    // Yarışma kokpitindeki olayları Main.qml'deki üst bildirim barına ileten sinyaller
    signal competitionEStartTriggered()
    signal competitionEStopTriggered()
    signal competitionEStartRejected(string reason)
    signal competitionTrackReset()

    function startCompetitionRun() {
        competitionHud.startCompetitionRun()
    }

    function triggerCompetitionEmergencyStop() {
        competitionHud.triggerEmergencyStop()
    }

    // -------------------------------------------------------------------------
    // 2 KATLI DİKEY KAYAN SAHNE ŞERİDİ
    // Yüksekliği ekranın 2 katıdır (`parent.height * 2`). Alt ok butonuna
    // basıldığında `y` koordinatı `-overviewRoot.height` değerine kayarak
    // alt bölümü ekrana getirir.
    // -------------------------------------------------------------------------
    Item {
        id: verticalSlideTrack
        width: parent.width
        height: parent.height * 2

        y: overviewRoot.isDownView ? -overviewRoot.height : 0

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // =====================================================================
        // 1. DİKEY KAT (ÜST): 3B SİMÜLASYON VEYA YARIŞMA KOKPİTİ
        // =====================================================================
        Item {
            id: topSection
            width: overviewRoot.width
            height: overviewRoot.height

            // A. 3B Kapsül Simülasyon ve X-Ray İnceleme Sahnesi (`isSimulationMode: true` iken görünür)
            Pod3DInspectionScene {
                id: simulationScene
                isSimulationMode: overviewRoot.isSimulationMode
                isDownView: overviewRoot.isDownView
            }

            // B. Yarışma Operasyon & Telemetri Kokpiti (`isSimulationMode: false` iken görünür)
            CompetitionCockpit {
                id: competitionHud
                active: !overviewRoot.isSimulationMode && !overviewRoot.isDownView
                linkOk: overviewRoot.linkOk
                motorEnabled: overviewRoot.motorEnabled
                opacity: !overviewRoot.isSimulationMode ? 1.0 : 0.0
                scale: !overviewRoot.isSimulationMode ? 1.0 : 0.97
                visible: opacity > 0.01

                Behavior on opacity {
                    NumberAnimation { duration: 360; easing.type: Easing.OutCubic }
                }
                Behavior on scale {
                    NumberAnimation { duration: 360; easing.type: Easing.OutCubic }
                }

                onEStartTriggered: overviewRoot.competitionEStartTriggered()
                onEStopTriggered: overviewRoot.competitionEStopTriggered()
                onEStartRejected: (reason) => overviewRoot.competitionEStartRejected(reason)
                onTrackReset: overviewRoot.competitionTrackReset()
            }

            // C. Simülasyon / Yarışma Mod Seçici Anahtar (Üstten 140px aşağıda sabit durur)
            OverviewModeSwitch {
                id: modeSelector
                z: 30
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    topMargin: 140
                }
                isSimulationMode: overviewRoot.isSimulationMode
                onIsSimulationModeChanged: {
                    if (overviewRoot.isSimulationMode !== isSimulationMode) {
                        overviewRoot.isSimulationMode = isSimulationMode
                    }
                }
            }
        }

        // =====================================================================
        // 2. DİKEY KAT (ALT): AŞAĞI KAYDIRINCA AÇILAN DETAY BÖLÜMÜ
        // =====================================================================
        OverviewDetailSection {
            id: bottomSection
            y: overviewRoot.height
            width: overviewRoot.width
            height: overviewRoot.height
        }
    }

    // -------------------------------------------------------------------------
    // DİKEY GEÇİŞ OK BUTONU
    // Sayfanın alt ortasında durur; tıklandığında `isDownView` değerini tersine
    // çevirerek üst sahne ile alt detay sayfası arasında dikey geçiş yapar ve
    // içindeki ok ikonunu 180 derece döndürür.
    // -------------------------------------------------------------------------
    Rectangle {
        id: verticalSlideBtn
        width: 44
        height: 44
        radius: 22

        color: btnMouse.containsMouse ? "#E5E5E5" : "#FFFFFF"
        border.width: 0

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 10
        }
        z: 25

        scale: btnMouse.pressed ? 0.92 : (btnMouse.containsMouse ? 1.08 : 1.0)
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on color { ColorAnimation { duration: 180 } }

        Shape {
            anchors.centerIn: parent
            width: 14
            height: 8

            rotation: overviewRoot.isDownView ? 180 : 0
            Behavior on rotation {
                NumberAnimation { duration: 380; easing.type: Easing.OutCubic }
            }

            ShapePath {
                strokeColor: "#000000"
                strokeWidth: 2.2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                startX: 1; startY: 1
                PathLine { x: 7; y: 7 }
                PathLine { x: 13; y: 1 }
            }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                overviewRoot.isDownView = !overviewRoot.isDownView
            }
        }
    }
}
