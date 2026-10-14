// ui/views/OverviewView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils
import ParsHyperloop
import "../components"

Item {
    id: overviewRoot
    anchors.fill: parent
    clip: true

    // Dikey sayfa durumu (false: 3D Model, true: Alt Detay Sekmesi)
    property bool isDownView: false

    // Çalışma Modu (true: Simülasyon, false: Yarışma)
    property bool isSimulationMode: true

    // X-Ray inceleme durumu
    readonly property bool inspectionActive: modelHoverArea.isOverPod && !isDownView

    // =========================================================================
    // DİKEY KAYAN SAYFA RAYI
    // =========================================================================
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
        // 1. DİKEY SAYFA (ÜST): 3D MODEL, PODYUM & X-RAY İNCELEME
        // =====================================================================
        Item {
            id: topSection
            width: overviewRoot.width
            height: overviewRoot.height

            View3D {
                id: view3D
                anchors.fill: parent
                opacity: overviewRoot.inspectionActive ? 0.45 : 1.0

                Behavior on opacity {
                    NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
                }

                environment: SceneEnvironment {
                    clearColor: "#000000"
                    backgroundMode: SceneEnvironment.Color
                    antialiasingMode: SceneEnvironment.MSAA
                    antialiasingQuality: SceneEnvironment.High
                }

                PerspectiveCamera {
                    id: camera
                    position: Qt.vector3d(0, 120, 650)
                    eulerRotation: Qt.vector3d(-10, 0, 0)
                    clipNear: 0.1
                    clipFar: 10000

                    onPositionChanged: {
                        if (position.x !== 0 || position.y !== 120 || position.z !== 650) {
                            position = Qt.vector3d(0, 120, 650)
                        }
                    }
                }

                DirectionalLight {
                    eulerRotation: Qt.vector3d(-45, 45, 0)
                    brightness: overviewRoot.inspectionActive ? 0.50 : 0.85
                    color: "#E2EDFF"
                    castsShadow: true

                    Behavior on brightness { NumberAnimation { duration: 300 } }
                }

                DirectionalLight {
                    eulerRotation: Qt.vector3d(45, -135, 0)
                    brightness: 0.35
                    color: "#B0B8C5"
                }

                OrbitCameraController {
                    id: orbitController
                    anchors.fill: parent
                    camera: camera
                    origin: sceneRoot
                    enabled: !overviewRoot.isDownView

                    WheelHandler {
                        target: null
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        onWheel: (event) => event.accepted = true
                    }
                }

                Node {
                    id: sceneRoot

                    Node {
                        id: turntableNode
                        property real currentRotationY: 0
                        eulerRotation: Qt.vector3d(0, currentRotationY, 0)

                        NumberAnimation on currentRotationY {
                            id: turntableAnim
                            from: 0
                            to: 360
                            duration: 24000
                            loops: Animation.Infinite
                            running: hyperloopLoader.status === RuntimeLoader.Success
                            paused: overviewRoot.inspectionActive || overviewRoot.isDownView
                        }

                        RuntimeLoader {
                            id: hyperloopLoader
                            source: "qrc:/qt/qml/ParsHyperloop/assets/hyperloop3d.glb"
                            scale: Qt.vector3d(1, 1, 1)
                            position: Qt.vector3d(0, 0, 0)

                            onStatusChanged: {
                                if (status === RuntimeLoader.Success) {
                                    console.log("GLB modeli Genel Bakış sayfasına başarıyla yüklendi.")
                                    fitTimer.attempts = 0
                                    fitTimer.start()
                                } else if (status === RuntimeLoader.Error) {
                                    console.error("GLB yükleme hatası:", errorString)
                                }
                            }
                        }
                    }
                }
            }

            Timer {
                id: fitTimer
                interval: 150
                repeat: true
                running: false
                property int attempts: 0

                onTriggered: {
                    attempts++
                    const min = hyperloopLoader.bounds.minimum
                    const max = hyperloopLoader.bounds.maximum
                    const sx = max.x - min.x
                    const sy = max.y - min.y
                    const sz = max.z - min.z
                    const maxSize = Math.max(sx, sy, sz)

                    if (isFinite(maxSize) && maxSize > 0.001) {
                        stop()
                        const targetSize = 580.0
                        const factor = targetSize / maxSize
                        const cx = (min.x + max.x) / 2
                        const cy = (min.y + max.y) / 2
                        const cz = (min.z + max.z) / 2

                        hyperloopLoader.scale = Qt.vector3d(factor, factor, factor)
                        hyperloopLoader.position = Qt.vector3d(-cx * factor, -cy * factor, -cz * factor)
                    } else if (attempts >= 10) {
                        stop()
                    }
                }
            }

            // --- AYRI BİLEŞENE TAŞINAN MOD SEÇİCİ ---
            ModeSelector {
                id: modeSelector
                z: 20
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

            // --- MODEL HOVER ALANI ---
            MouseArea {
                id: modelHoverArea
                width: Math.min(parent.width * 0.36, 400)
                height: Math.min(parent.height * 0.14, 96)
                x: parent.width * 0.50 - width / 2
                y: parent.height * 0.52 - height / 2

                hoverEnabled: true
                acceptedButtons: Qt.NoButton

                readonly property bool isOverPod: {
                    if (!containsMouse) return false
                    const rx = width / 2
                    const ry = height / 2
                    const dx = (mouseX - rx) / rx
                    const dy = (mouseY - ry) / ry
                    return (dx * dx + dy * dy) <= 1.0
                }

                cursorShape: isOverPod ? Qt.CrossCursor : Qt.ArrowCursor
            }

            // --- GÖVDE ODAK NOKTASI ---
            Item {
                id: targetPoint
                x: parent.width * 0.50 - 15
                y: parent.height * 0.52
                width: 30
                height: 30

                opacity: overviewRoot.inspectionActive ? 1.0 : 0.0
                scale: overviewRoot.inspectionActive ? 1.0 : 0.6

                Behavior on opacity { NumberAnimation { duration: 280 } }
                Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }

                Rectangle {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: 12
                    color: "transparent"
                    border.color: Colors.accentAero
                    border.width: 1.5

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        PropertyAnimation { to: 1.5; duration: 900 }
                        PropertyAnimation { to: 1.0; duration: 900 }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: 4
                    color: Colors.accentAero
                }

                Text {
                    anchors.top: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 4
                    text: "PARS POD-01"
                    color: Colors.accentAero
                    font.family: Colors.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 1.2
                }
            }

            // --- KILAVUZ ÇİZGİSİ ---
            Shape {
                id: leaderLine
                anchors.fill: parent
                opacity: overviewRoot.inspectionActive ? 1.0 : 0.0

                Behavior on opacity { NumberAnimation { duration: 280 } }

                ShapePath {
                    strokeColor: Colors.accentAero
                    strokeWidth: 1.5
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin

                    startX: targetPoint.x + targetPoint.width / 2
                    startY: targetPoint.y + targetPoint.height / 2

                    PathLine {
                        x: targetPoint.x + 85
                        y: targetPoint.y - 80
                    }

                    PathLine {
                        x: specDetailCard.x
                        y: targetPoint.y - 80
                    }
                }
            }

            // --- GENEL BİLGİ & TELEMETRİ KARTI ---
            Rectangle {
                id: specDetailCard
                width: 350
                height: 380
                radius: 18
                color: Colors.panelBg
                border.color: Colors.panelBorderActive
                border.width: 1

                anchors.verticalCenter: parent.verticalCenter
                x: overviewRoot.inspectionActive ? (parent.width - width - 36) : (parent.width - width + 20)
                opacity: overviewRoot.inspectionActive ? 1.0 : 0.0

                Behavior on x {
                    NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 280 }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 12

                    Row {
                        width: parent.width
                        spacing: 8

                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: Colors.statusNormal
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "SİSTEM ÖZETİ // PARS POD-01"
                            color: Colors.accentAero
                            font.family: Colors.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.letterSpacing: 1.4
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 24

                        Column {
                            spacing: 2
                            Text { text: "HIZ GÖSTERGESİ"; color: Colors.textSecondary; font.pixelSize: 10; font.weight: Font.DemiBold }
                            Row {
                                spacing: 4
                                baselineOffset: 24
                                Text { text: "1,048"; color: Colors.textPrimary; font.pixelSize: 28; font.weight: Font.Bold }
                                Text { text: "km/h"; color: Colors.textSecondary; font.pixelSize: 13; font.weight: Font.Medium }
                            }
                        }

                        Column {
                            spacing: 2
                            Text { text: "BATARYA DURUMU"; color: Colors.textSecondary; font.pixelSize: 10; font.weight: Font.DemiBold }
                            Row {
                                spacing: 4
                                baselineOffset: 24
                                Text { text: "%94.2"; color: Colors.textPrimary; font.pixelSize: 28; font.weight: Font.Bold }
                                Text { text: "SOC"; color: Colors.statusNormal; font.pixelSize: 13; font.weight: Font.Bold }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Colors.panelBorder
                    }

                    Column {
                        width: parent.width
                        spacing: 9

                        Row {
                            width: parent.width
                            Text { text: "Tüp Basıncı (Vakum)"; color: Colors.textSecondary; font.pixelSize: 12; width: 165 }
                            Text { text: "98 Pa (Nominal)"; color: Colors.statusNormal; font.pixelSize: 12; font.weight: Font.DemiBold }
                        }

                        Row {
                            width: parent.width
                            Text { text: "Manyetik Boşluk (Lev.)"; color: Colors.textSecondary; font.pixelSize: 12; width: 165 }
                            Text { text: "16.2 mm"; color: Colors.textPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
                        }

                        Row {
                            width: parent.width
                            Text { text: "İtki & Aerodinamik"; color: Colors.textSecondary; font.pixelSize: 12; width: 165 }
                            Text { text: "18.4 kN // Mach 0.86"; color: Colors.accentAero; font.pixelSize: 12; font.weight: Font.DemiBold }
                        }

                        Row {
                            width: parent.width
                            Text { text: "G-Kuvveti / İvme"; color: Colors.textSecondary; font.pixelSize: 12; width: 165 }
                            Text { text: "+0.42 G (Konforlu)"; color: Colors.textPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
                        }

                        Row {
                            width: parent.width
                            Text { text: "Güç Paketi Voltajı"; color: Colors.textSecondary; font.pixelSize: 12; width: 165 }
                            Text { text: "782 V // LFP Prizmatik"; color: Colors.textPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
                        }

                        Row {
                            width: parent.width
                            Text { text: "Gövde Kompoziti"; color: Colors.textSecondary; font.pixelSize: 12; width: 165 }
                            Text { text: "Karbon-Aramid Monokok"; color: Colors.textPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
                        }

                        Row {
                            width: parent.width
                            Text { text: "Pod Boş Ağırlığı"; color: Colors.textSecondary; font.pixelSize: 12; width: 165 }
                            Text { text: "385 kg"; color: Colors.textSecondary; font.pixelSize: 12; font.weight: Font.Medium }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 2. DİKEY SAYFA (ALT): AYRI BİLEŞENE TAŞINMIŞ ALT PANEL
        // =====================================================================
        OverviewBottomSection {
            id: bottomSection
            y: overviewRoot.height
            width: overviewRoot.width
            height: overviewRoot.height
        }
    }

    // =========================================================================
    // DİKEY KAYDIRMA OK BUTONU
    // =========================================================================
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
