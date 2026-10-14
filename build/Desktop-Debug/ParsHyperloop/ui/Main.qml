import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils
import ParsHyperloop

Window {
    id: window

    width: 1280
    height: 720
    minimumWidth: 1024
    minimumHeight: 600

    visible: true
    title: "Pars Hyperloop - Operasyon & 3D Telemetri Paneli"
    color: Colors.bgPrimary

    // =========================================================================
    // 1. KATMAN: 3D SAHNE
    // =========================================================================
    View3D {
        id: view3D
        anchors.fill: parent

        environment: SceneEnvironment {
            clearColor: Colors.bgPrimary
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
        }

        DirectionalLight {
            eulerRotation: Qt.vector3d(-45, 45, 0)
            brightness: 0.85
            color: "#E2EDFF"
            castsShadow: true
        }

        DirectionalLight {
            eulerRotation: Qt.vector3d(45, -135, 0)
            brightness: 0.35
            color: "#B0B8C5"
        }

        OrbitCameraController {
            camera: camera
            origin: sceneRoot
        }

        Node {
            id: sceneRoot

            RuntimeLoader {
                id: hyperloopLoader
                source: "qrc:/qt/qml/ParsHyperloop/assets/hyperloop3d.glb"
                scale: Qt.vector3d(1, 1, 1)
                position: Qt.vector3d(0, 0, 0)

                onStatusChanged: {
                    if (status === RuntimeLoader.Success) {
                        console.log("GLB modeli başarıyla yüklendi.")
                    } else if (status === RuntimeLoader.Error) {
                        console.error("GLB yükleme hatası:", errorString)
                    }
                }
            }
        }
    }

    // =========================================================================
    // 2. KATMAN: 2D TELEMETRİ HUD VE KONTROL PANELLERİ
    // =========================================================================

    // --- ÜST DURUM ÇUBUĞU (HEADER) ---
    Rectangle {
        id: topBar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 24
        }
        height: 52
        color: Colors.panelBg
        radius: 12
        border.color: Colors.panelBorder
        border.width: 1

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: Colors.statusNormal
                anchors.verticalCenter: parent.verticalCenter

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    PropertyAnimation { to: 0.3; duration: 900 }
                    PropertyAnimation { to: 1.0; duration: 900 }
                }
            }

            Text {
                text: "PARS HYPERLOOP"
                color: Colors.textPrimary
                font.family: Colors.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                font.letterSpacing: 2.0
            }

            Rectangle {
                width: 1
                height: 16
                color: Colors.panelBorder
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "POD-01 // VAKUM TÜPÜ OPERASYONU"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                font.letterSpacing: 1.0
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Text {
                text: "LEVITATION: ACTIVE"
                color: Colors.accentAero
                font.family: Colors.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
            }

            Text {
                text: "TELEMETRY LINK: 99.8%"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }
    }

    // --- SOL PANEL: HIZ VE İTKİ SİSTEMİ ---
    Rectangle {
        id: speedCard
        width: 290
        height: 190
        anchors {
            top: topBar.bottom
            left: parent.left
            margins: 24
        }
        color: Colors.panelBg
        radius: 14
        border.color: Colors.panelBorder
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                text: "POD VELOCITY"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.5
            }

            Row {
                spacing: 6
                baselineOffset: 34

                Text {
                    text: "1,048"
                    color: Colors.textPrimary
                    font.family: Colors.fontFamily
                    font.pixelSize: 42
                    font.weight: Font.Bold
                }

                Text {
                    text: "km/h"
                    color: Colors.textSecondary
                    font.family: Colors.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.panelBorder
            }

            Row {
                width: parent.width
                spacing: 24

                Column {
                    spacing: 2
                    Text { text: "MACH"; color: Colors.textSecondary; font.pixelSize: 9; font.weight: Font.Medium }
                    Text { text: "0.86"; color: Colors.textPrimary; font.pixelSize: 13; font.weight: Font.DemiBold }
                }

                Column {
                    spacing: 2
                    Text { text: "THRUST"; color: Colors.textSecondary; font.pixelSize: 9; font.weight: Font.Medium }
                    Text { text: "18.4 kN"; color: Colors.accentAero; font.pixelSize: 13; font.weight: Font.DemiBold }
                }

                Column {
                    spacing: 2
                    Text { text: "G-FORCE"; color: Colors.textSecondary; font.pixelSize: 9; font.weight: Font.Medium }
                    Text { text: "+0.42 G"; color: Colors.textPrimary; font.pixelSize: 13; font.weight: Font.DemiBold }
                }
            }
        }
    }

    // --- SAĞ PANEL: ÇEVRE VE MANYETİK TELEMETRİ ---
    Rectangle {
        id: environmentCard
        width: 290
        height: 220
        anchors {
            top: topBar.bottom
            right: parent.right
            margins: 24
        }
        color: Colors.panelBg
        radius: 14
        border.color: Colors.panelBorder
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            Text {
                text: "SYSTEM TELEMETRY"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1.5
            }

            Row {
                width: parent.width
                Text { text: "Tube Pressure"; color: Colors.textSecondary; font.pixelSize: 12; width: 140 }
                Text { text: "98 Pa"; color: Colors.statusNormal; font.pixelSize: 12; font.weight: Font.DemiBold }
            }

            Row {
                width: parent.width
                Text { text: "Air Gap (Levitation)"; color: Colors.textSecondary; font.pixelSize: 12; width: 140 }
                Text { text: "16.2 mm"; color: Colors.textPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
            }

            Row {
                width: parent.width
                Text { text: "Inverter Temp"; color: Colors.textSecondary; font.pixelSize: 12; width: 140 }
                Text { text: "41.6 °C"; color: Colors.textPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
            }

            Row {
                width: parent.width
                Text { text: "Pack Voltage"; color: Colors.textSecondary; font.pixelSize: 12; width: 140 }
                Text { text: "782 V (%94)"; color: Colors.accentAero; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
        }
    }

    // --- ALT KONTROL VE İPUCU ÇUBUĞU ---
    Rectangle {
        height: 38
        width: 380
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 20
        }
        color: Colors.panelBg
        radius: 19
        border.color: Colors.panelBorder
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: "SOL TIK: DÖNDÜR"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 10
                font.weight: Font.Medium
                font.letterSpacing: 1.0
            }

            Text { text: "•"; color: Colors.textMuted; font.pixelSize: 10 }

            Text {
                text: "TEKERLEK: ZOOM"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 10
                font.weight: Font.Medium
                font.letterSpacing: 1.0
            }

            Text { text: "•"; color: Colors.textMuted; font.pixelSize: 10 }

            Text {
                text: "SAĞ TIK: KAYDIR"
                color: Colors.textSecondary
                font.family: Colors.fontFamily
                font.pixelSize: 10
                font.weight: Font.Medium
                font.letterSpacing: 1.0
            }
        }
    }
}
