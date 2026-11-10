# TEAM PARS — Hyperloop Yer İstasyonu (Operasyon & Telemetri Paneli)

TEKNOFEST 2026 Hyperloop Geliştirme Yarışması kapsamında **Team Pars** tarafından geliştirilen, **Qt 6.8 (QtQuick & QtQuick3D)** tabanlı yer kontrol istasyonu ve telemetri arayüzü.

---

## Sayfa Odaklı Klasör Yapısı

Arayüz dosyaları `Main.qml` penceresinden içeriye doğru **sayfa odaklı (page-first)** olarak gruplandırılmıştır:

```text
ground-station/ParsHyperloop/
├── CMakeLists.txt
├── src/
│   └── main.cpp                                    # Uygulama başlangıcı ve Satoshi font yükleyicisi
├── assets/
│   ├── hyperloop3d.glb                             # 3B kapsül modeli
│   ├── teampars.png                                # Team Pars logosu
│   ├── ikculogo.png                                # İKÇÜ kurumsal logosu
│   └── fonts/                                      # Satoshi yazı tipi dosyaları
└── ui/
    ├── Main.qml                                    # Ana pencere: sabit üst/alt barlar ve 5 sayfalık kayan şerit
    ├── Colors.qml                                  # Uygulama genelindeki renk ve font sabitleri (Singleton)
    │
    ├── shell/                                      # [ANA PENCEREDE SABİT KALAN ÜST VE ALT BARLAR]
    │   ├── TopControlBar.qml                       # Sağ üstteki görev sayacı, 4'lü sistem matrisi ve E-STOP
    │   ├── NotificationLogPanel.qml                # Sol üstteki açılır-kapanır bildirim ve CAN-Bus log çekmecesi
    │   └── BottomNavigationBar.qml                 # Alttaki 5 sekmeli kayan hap (pill) navigasyon barı
    │
    └── views/                                      # [5 ANA SEKME VE ALT MODÜLLERİ]
        │
        ├── overview/                               # 1. GENEL BAKIŞ SEKMESİ
        │   ├── OverviewPage.qml                    # Genel Bakış ana sayfası (Üst sahne + Alt detay bölümü)
        │   ├── OverviewModeSwitch.qml              # "Simülasyon | Yarışma" mod geçiş anahtarı
        │   ├── OverviewDetailSection.qml           # Aşağı kaydırınca açılan alt detay sayfası
        │   │
        │   ├── pod3d/                              # Simülasyon Modu (3B Model & X-Ray İnceleme)
        │   │   └── Pod3DInspectionScene.qml        # 3B GLB kapsül sahnesi, odak halkası ve teknik özet kartı
        │   │
        │   └── cockpit/                            # Yarışma Modu (Yarışma Kokpiti & Alt Parçaları)
        │       ├── CompetitionCockpit.qml          # Yarışma kokpiti ana sahnesi
        │       ├── CockpitPhysicsEngine.qml        # 30 Hz fizik, batarya, sıcaklık ve şartname sınır motoru
        │       ├── CockpitSweepAnimator.qml        # İlk açılış kadran selamlaması ve 60 FPS görsel akış kontrolcüsü
        │       ├── CockpitBorderFrame.qml          # Zifiri siyah zemin ve pahlı beyaz kokpit çerçeve çizgileri
        │       ├── TunnelProgressMap.qml           # Üstteki 208 m tünel haritası, 46 reflektör ve kapsül silüeti
        │       ├── LeftSpeedPanel.qml              # Sol kanat: 48 çentikli hız kadranı, sürüş fazı ve ivme barı
        │       ├── CenterCommandPanel.qml          # Merkez: E-START/E-STOP halkaları, yapay ufuk ve sıcaklıklar
        │       ├── RightPowerPanel.qml             # Sağ kanat: 41 çentikli LIM güç kadranı, akım/enerji ve fren
        │       ├── Tunnel3DRingsCanvas.qml         # Merkezde arkadan öne akan 3B perspektif tünel halkaları
        │       ├── BatteryCellsCanvas.qml          # Sağ kanattaki 8 hücreli canlı enerji akışı ve şimşek ikonu
        │       └── OscilloscopeGraph.qml           # Sol ve sağ kanattaki canlı kayan osiloskop grafik kutusu
        │
        ├── safety/                                 # 2. GÜVENLİK SEKMESİ
        │   └── SafetyPage.qml                      # Güvenlik ve görev analizi sayfası
        │
        ├── battery/                                # 3. BATARYA SEKMESİ
        │   └── BatteryPage.qml                     # Batarya Yönetim Sistemi (BMS) sayfası
        │
        ├── brake/                                  # 4. FREN SEKMESİ
        │   └── BrakePage.qml                       # Eddy Current ve Pnömatik fren sistemi sayfası
        │
        └── communication/                          # 5. HABERLEŞME SEKMESİ
            └── CommunicationPage.qml               # Haberleşme ve kontrol linki sayfası
```
