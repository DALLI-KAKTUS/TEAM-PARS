// ui/components/ModeSelector.qml
import QtQuick
import ParsHyperloop

Rectangle {
    id: selectorRoot
    width: 270
    height: 42
    radius: height / 2
    color: "transparent"
    clip: true

    // Dışarıdan okunabilir ve atanabilir mod durumu
    property bool isSimulationMode: true

    Row {
        anchors.fill: parent

        // Sol Buton: Simülasyon
        Item {
            id: simBtn
            width: parent.width / 2
            height: parent.height

            Rectangle {
                id: simBg
                anchors.fill: parent
                radius: parent.height / 2
                color: selectorRoot.isSimulationMode ? "#000000" : "#FFFFFF"

                Rectangle {
                    anchors.right: parent.right
                    width: parent.radius
                    height: parent.height
                    color: simBg.color
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 600
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Simülasyon"
                color: selectorRoot.isSimulationMode ? "#FFFFFF" : "#000000"
                font.family: Colors.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                font.letterSpacing: 0.5

                Behavior on color {
                    ColorAnimation {
                        duration: 600
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: selectorRoot.isSimulationMode = true
            }
        }

        // Sağ Buton: Yarışma
        Item {
            id: compBtn
            width: parent.width / 2
            height: parent.height

            Rectangle {
                id: compBg
                anchors.fill: parent
                radius: parent.height / 2
                color: !selectorRoot.isSimulationMode ? "#000000" : "#FFFFFF"

                Rectangle {
                    anchors.left: parent.left
                    width: parent.radius
                    height: parent.height
                    color: compBg.color
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 600
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Yarışma"
                color: !selectorRoot.isSimulationMode ? "#FFFFFF" : "#000000"
                font.family: Colors.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                font.letterSpacing: 0.5

                Behavior on color {
                    ColorAnimation {
                        duration: 600
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: selectorRoot.isSimulationMode = false
            }
        }
    }

    // Ortadaki Düz Beyaz Ayraç Çizgisi
    Rectangle {
        width: 2
        height: parent.height
        anchors.centerIn: parent
        color: "#FFFFFF"
        z: 16
    }

    // Dış Beyaz Çerçeve
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: "#FFFFFF"
        border.width: 2
        z: 15
    }
}
