// ui/shell/BottomNavigationBar.qml
// Ekranın alt ortasında duran 5 sekmeli navigasyon barı.
// Hangi sekmeye tıklanırsa arkasındaki siyah hap (`activeIndicator`) o yazının
// genişliğini ve konumunu hesaplayarak oraya doğru kayar.
import QtQuick
import ParsHyperloop

Rectangle {
    id: navRoot

    // Seçili olan sekmenin indeksi (Main.qml'deki sayfa şeridi bu değeri dinler)
    property int currentIndex: 0
    signal tabSelected(int index)

    // Uygulama ilk açılırken yazı genişlikleri henüz hesaplanmadığı için siyah hapın
    // sol köşeden kayarak gelmesini engelleyen kilit. İlk çizim bitince true olur.
    property bool readyToAnimate: false

    // Menüde gösterilen 5 ana sayfa başlığı
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

        // ---------------------------------------------------------------------
        // 1. ARKADA KAYAN SİYAH HAP GÖSTERGESİ
        // Seçili sekmenin x konumuna ve genişliğine kilitlenir.
        // ---------------------------------------------------------------------
        Rectangle {
            id: activeIndicator
            height: 44
            radius: 22
            color: Colors.textPrimary
            z: 0

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

        // ---------------------------------------------------------------------
        // 2. YAN YANA DİZİLEN SEKME BUTONLARI
        // Her sekmenin genişliği içindeki yazının uzunluğuna + 32px iç boşluğa göre
        // otomatik ayarlanır.
        // ---------------------------------------------------------------------
        Row {
            id: rowLayout
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            z: 1

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

                    // Sekme adı: seçiliyse siyah hapın üstünde beyaz, değilse koyu gri görünür
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

    // Aktif sekme öğesini bulup siyah hapın x ve width değerlerini ona eşitler
    function updateIndicator() {
        if (rowRepeater && rowRepeater.count > navRoot.currentIndex) {
            var target = rowRepeater.itemAt(navRoot.currentIndex)
            if (target && target.width > 0) {
                activeIndicator.x = target.x
                activeIndicator.width = target.width
            }
        }
    }

    onCurrentIndexChanged: {
        updateIndicator()
    }

    // Bileşen ekrana yerleştiğinde hapı ilk sekmeye oturtup animasyon kilidini açar
    Component.onCompleted: {
        updateIndicator()
        Qt.callLater(function() {
            updateIndicator()
            readyToAnimate = true
        })
    }
}
