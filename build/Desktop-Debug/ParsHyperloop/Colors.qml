// ui/Colors.qml
pragma Singleton
import QtQuick

QtObject {
    id: root

    // =========================================================================
    // 1. ZEMİN (ZİFİRİ SİYAH SAHNE)
    // =========================================================================
    // 3D modelin bir elmas gibi parlaması için saf siyah derinlik
    readonly property color bgPrimary: "#000000"
    readonly property color bgSecondary: "#0A0C0F"

    // =========================================================================
    // 2. PANELLER (SERAMİK LÜKS BEYAZ)
    // =========================================================================
    // Kireç beyazı değil; fırçalanmış seramik beyazı (%94 opaklık)
    // 3D model arkasından geçerken derinliği hafifçe hissettirir
    readonly property color panelBg: Qt.rgba(0.98, 0.98, 0.99, 0.94) // #FAFAFC
    readonly property color panelBgHover: "#FFFFFF"

    // Panel kenarlığı: Paneli havada hissettiren zarif sınır çizgisi
    readonly property color panelBorder: Qt.rgba(0.0, 0.0, 0.0, 0.06)
    readonly property color panelBorderActive: "#0066FF"

    // =========================================================================
    // 3. TİPOGRAFİ (YÜKSEK KONTRASTLI MÜREKKEP SİYAHI)
    // =========================================================================
    // Birincil metin: Hız ve ana rakamlar için tok, derin siyah
    readonly property color textPrimary: "#0D0F12"

    // İkincil metin: Birimler (km/h, Pa), etiketler için dengeli kurşuni gri
    readonly property color textSecondary: "#5E6573"

    // Pasif metin: Ayraç noktaları ve alt bilgiler
    readonly property color textMuted: "#9CA3AF"

    // =========================================================================
    // 4. RAFİNE FONKSİYONEL VURGULAR
    // =========================================================================
    // Kobalt Elektrik Mavisi (Beyaz panellerin üzerinde inanılmaz şık durur)
    readonly property color accentAero: "#0062FF"

    // Güvenli Operasyon: Canlı zümrüt yeşili
    readonly property color statusNormal: "#059669"

    // Uyarı: Sıcak kehribar
    readonly property color statusWarning: "#D97706"

    // Acil durum
    readonly property color statusCritical: "#DC2626"

    // =========================================================================
    // 5. TİPOGRAFİ SABİTİ
    // =========================================================================
    readonly property string fontFamily: "Satoshi"
}
