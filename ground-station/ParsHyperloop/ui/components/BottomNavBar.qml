// ui/components/BottomNavBar.qml
import QtQuick
import ParsHyperloop

Rectangle {
    id: navRoot

    property int currentIndex: 0
    signal tabSelected(int index)

    // İlk açılışta yarım kalmayı önleyen animasyon kilidi
    property bool readyToAnimate: false

    readonly property var items: [
        "Genel Bakış",
        "Güvenlik",
        "Batarya",
        "Fren",
        "Haberleşme"
    ]

    width: rowContainer.width + 20
    height: 56
    radius: height / 2
    color: Colors.panelBg
    border.color: Colors.panelBorder
    border.width: 1

    Item {
        id: rowContainer
        anchors.centerIn: parent
        height: 44
        width: rowLayout.width

        // =====================================================================
        // KAYAN SİYAH HAP GÖSTERGESİ
        // =====================================================================
        Rectangle {
            id: activeIndicator
            height: 44
            radius: 22
            color: Colors.textPrimary
            z: 0

            // Sadece ilk açılış tamamlandıktan sonra kayma animasyonu çalışır
            Behavior on x {
                enabled: navRoot.readyToAnimate
                NumberAnimation {
                    duration: 340
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on width {
                enabled: navRoot.readyToAnimate
                NumberAnimation {
                    duration: 340
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            id: rowLayout
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            z: 1

            // Butonların toplam genişliği değiştikçe hapı güncelle
            onWidthChanged: {
                navRoot.updateIndicator()
            }

            Repeater {
                id: rowRepeater
                model: navRoot.items

                Item {
                    id: tabItem
                    required property string modelData
                    required property int index

                    width: tabText.implicitWidth + 32
                    height: 44

                    // Butonun genişliği veya konumu netleştiğinde göstergeyi oturt
                    onWidthChanged: {
                        if (index === navRoot.currentIndex) {
                            navRoot.updateIndicator()
                        }
                    }

                    onXChanged: {
                        if (index === navRoot.currentIndex) {
                            navRoot.updateIndicator()
                        }
                    }

                    Text {
                        id: tabText
                        anchors.centerIn: parent
                        text: tabItem.modelData
                        font.family: Colors.fontFamily
                        font.pixelSize: 13
                        font.weight: navRoot.currentIndex === tabItem.index ? Font.Bold : Font.Medium
                        font.letterSpacing: 0.5
                        color: navRoot.currentIndex === tabItem.index
                               ? "#FFFFFF"
                               : (mouseArea.containsMouse ? Colors.textPrimary : Colors.textSecondary)

                        Behavior on color {
                            ColorAnimation { duration: 180 }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            navRoot.currentIndex = tabItem.index
                            navRoot.tabSelected(tabItem.index)
                        }
                    }
                }
            }
        }
    }

    // Göstergeyi aktif butonun tam koordinat ve genişliğine kilitler
    function updateIndicator() {
        if (rowRepeater && rowRepeater.count > navRoot.currentIndex) {
            var target = rowRepeater.itemAt(navRoot.currentIndex)
            if (target && target.width > 0) {
                activeIndicator.x = target.x
                activeIndicator.width = target.width
            }
        }
    }

    // Sekme tıklandığında kaymayı tetikle
    onCurrentIndexChanged: {
        updateIndicator()
    }

    // İlk açılış kurulumu
    Component.onCompleted: {
        updateIndicator()
        // Render oturunca animasyon kilidini aç
        Qt.callLater(function() {
            updateIndicator()
            readyToAnimate = true
        })
    }
}
