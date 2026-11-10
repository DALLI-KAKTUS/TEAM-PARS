// ui/Main.qml
// Uygulamanın ana penceresi. Ekranın üst kısmındaki sabit logoları, bildirim çekmecesini
// ve komuta barını; ortadaki 5 sekmeli kayan sayfa alanını ve alttaki navigasyon
// barını tek bir çatı altında toplar.
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import ParsHyperloop
import "shell"
import "views/overview"
import "views/battery"
import "views/brake"
import "views/communication"
import "views/safety"

Window {
    id: window

    // Pencere başlangıç ve minimum çözünürlük sınırları
    width: 1280
    height: 720
    minimumWidth: 1024
    minimumHeight: 600

    visible: true
    title: "Pars Hyperloop - Operasyon & Telemetri Paneli"
    color: Colors.bgPrimary

    // -------------------------------------------------------------------------
    // ÜST SABİT KATMAN 1: MERKEZDEKİ TAKIM LOGOSU
    // Sayfalar yatayda kaysa bile üst merkezde sabit kalır. Görseldeki boşluğu
    // dengelemek için üstten -60px ofset verdik.
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    // ÜST SABİT KATMAN 2: SAĞ ÜST KOMUTA VE DURUM BARI
    // Görev sayacını, Motor/Bağlantı/Fren/Uyarı anahtarlarını ve E-STOP butonunu
    // tutar. Buradan E-STOP'a basıldığında doğrudan Genel Bakış'taki yarışma
    // kokpitine acil durdurma emri gönderiyoruz.
    // -------------------------------------------------------------------------
    TopControlBar {
        id: topStatusIndicators
        anchors {
            right: parent.right
            rightMargin: 16
            verticalCenter: teamLogo.verticalCenter
        }
        z: 50
        onEmergencyStopActivated: overviewPage.triggerCompetitionEmergencyStop()
    }

    // -------------------------------------------------------------------------
    // ÜST SABİT KATMAN 3: SOL ÜSTTEKİ İKÇÜ LOGOSU
    // Sağdaki komuta barı ile aynı yatay hizada durması için dikey merkezini
    // komuta barının üst kenarına referansladık.
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    // ÜST SABİT KATMAN 4: AÇILIR-KAPANIR BİLDİRİM VE LOG PANELİ
    // İKÇÜ logosunun hemen sağında yer alır. Tıklandığında aşağı doğru uzayarak
    // son CAN-Bus ve alt sistem loglarını gösterir (z: 60 ile sahnenin üstüne açılır).
    // -------------------------------------------------------------------------
    NotificationLogPanel {
        id: notificationPanel
        anchors {
            left: ikcuLogo.right
            leftMargin: 16
            top: topStatusIndicators.top
        }
        z: 60
    }

    // -------------------------------------------------------------------------
    // ORTA SAHNE: 5 SAYFALIK YATAY KAYAN GÖRÜNÜM RAYI (SLIDING TRACK)
    // Sekmeler arasında geçiş yaparken sayfaları yok edip yeniden oluşturmak yerine,
    // 5 ekran genişliğinde tek bir şerit (`slidingTrack`) içinde yan yana dizdik.
    // Alt navigasyon barındaki `currentIndex` değiştikçe şeridin `x` koordinatını
    // kaydırarak pürüzsüz bir geçiş elde ediyoruz ve 3B sahne/simülasyon durumunu
    // hiç kaybetmiyoruz.
    // -------------------------------------------------------------------------
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

            // Seçili sekmenin indeksine göre şeridi sola doğru kaydırır
            x: -bottomNav.currentIndex * pageViewport.width

            Behavior on x {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutCubic
                }
            }

            // 1. Sayfa (İndeks 0): Genel Bakış (3B Kapsül Simülasyonu + Yarışma Kokpiti)
            // Üst komuta barındaki Bağlantı ve Motor anahtarlarını buraya bağlıyoruz ki
            // yarışma kokpitindeki E-START kilitleri ve bildirimleri çift yönlü çalışsın.
            Item {
                x: 0 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                OverviewPage {
                    id: overviewPage
                    linkOk: topStatusIndicators.linkActive
                    motorEnabled: topStatusIndicators.motorActive
                    onCompetitionEStartTriggered: {
                        topStatusIndicators.setEmergencyStop(false, true)
                        topStatusIndicators.triggerNotification("E-START AKTİF")
                    }
                    onCompetitionEStopTriggered: {
                        topStatusIndicators.setEmergencyStop(true, true)
                        topStatusIndicators.triggerNotification("E-STOP DEVREDE")
                    }
                    onCompetitionEStartRejected: (reason) => topStatusIndicators.triggerNotification(reason)
                    onCompetitionTrackReset: {
                        topStatusIndicators.setEmergencyStop(false, true)
                        topStatusIndicators.triggerNotification("PARKUR 0 m SIFIRLANDI")
                    }
                }
            }

            // 2. Sayfa (İndeks 1): Batarya Yönetim Sistemi (BMS)
            Item {
                x: 1 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                BatteryPage {}
            }

            // 3. Sayfa (İndeks 2): Eddy Current & Pnömatik Fren Sistemi
            Item {
                x: 2 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                BrakePage {}
            }

            // 4. Sayfa (İndeks 3): Haberleşme & Kontrol Linki
            Item {
                x: 3 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                CommunicationPage {}
            }

            // 5. Sayfa (İndeks 4): Güvenlik & Görev Analizi
            Item {
                x: 4 * pageViewport.width
                width: pageViewport.width
                height: pageViewport.height
                SafetyPage {}
            }
        }
    }

    // -------------------------------------------------------------------------
    // ALT SABİT KATMAN: SEKME NAVİGASYON BARI
    // Ekranın alt ortasında yer alır; tıklanan sekmeye göre `currentIndex`
    // değerini güncelleyerek yukarıdaki `slidingTrack` şeridini hareket ettirir.
    // -------------------------------------------------------------------------
    BottomNavigationBar {
        id: bottomNav
        currentIndex: 0
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 24
        }
    }
}
