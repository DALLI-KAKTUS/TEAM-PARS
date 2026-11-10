// ui/Colors.qml
// Uygulama genelinde kullanılan renk paletini ve ana yazı tipini (Satoshi)
// tek bir merkezden yönetmek için kullandığımız Singleton dosya.
pragma Singleton
import QtQuick

QtObject {
    id: root

    // -------------------------------------------------------------------------
    // 1. SAHNE ZEMİN RENKLERİ
    // 3B kapsül modelinin ve monokrom yarışma kokpitinin yüksek kontrastla
    // öne çıkması için arka planda tam siyah kullanıyoruz.
    // -------------------------------------------------------------------------
    readonly property color bgPrimary: "#000000"
    readonly property color bgSecondary: "#0A0C0F"

    // -------------------------------------------------------------------------
    // 2. KART VE PANEL YÜZEYLERİ
    // Bilgi kartlarında hafif şeffaf (%94 opaklık) seramik beyazı kullanarak
    // arkadaki 3B sahnenin derinlik hissini koruyoruz.
    // -------------------------------------------------------------------------
    readonly property color panelBg: Qt.rgba(0.98, 0.98, 0.99, 0.94) // #FAFAFC
    readonly property color panelBgHover: "#FFFFFF"

    // Kartların dış sınır çizgileri ve aktif odak rengi
    readonly property color panelBorder: Qt.rgba(0.0, 0.0, 0.0, 0.06)
    readonly property color panelBorderActive: "#0066FF"

    // -------------------------------------------------------------------------
    // 3. METİN VE TİPOGRAFİ TONLARI
    // Beyaz kartların üzerinde okunabilirliği artırmak için ana değerlerde
    // mürekkep siyahı, birimlerde ve alt etiketlerde gri tonları seçtik.
    // -------------------------------------------------------------------------
    readonly property color textPrimary: "#0D0F12"
    readonly property color textSecondary: "#5E6573"
    readonly property color textMuted: "#9CA3AF"

    // -------------------------------------------------------------------------
    // 4. DURUM VE VURGU RENKLERİ
    // X-Ray inceleme çizgileri için elektrik mavisi; telemetri durumları için
    // yeşil (normal), kehribar (uyarı) ve kırmızı (acil durum) tonları.
    // -------------------------------------------------------------------------
    readonly property color accentAero: "#0062FF"
    readonly property color statusNormal: "#059669"
    readonly property color statusWarning: "#D97706"
    readonly property color statusCritical: "#DC2626"

    // -------------------------------------------------------------------------
    // 5. VARSAYILAN FONT AİLESİ
    // main.cpp içinde qrc kaynaklarından yüklenen Satoshi fontu.
    // -------------------------------------------------------------------------
    readonly property string fontFamily: "Satoshi"
}
