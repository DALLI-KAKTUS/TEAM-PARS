// assets/Colors.qml
pragma Singleton
import QtQuick

QtObject {
    id: root

    // =========================================================================
    // 1. ZEMİN & PANEL KATMANLARI (AEROSPACE TITANIUM)
    // =========================================================================
    // Ana arka plan: Saf siyah (#000000) yerine derin, gözü yormayan titanyum füme
    readonly property color bgPrimary: "#0D0F12"
    readonly property color bgSecondary: "#12151B"

    // Yarı saydam yüzen panel zeminleri (Buzlu cam / HUD efekti için %70 opaklık)
    readonly property color panelBg: Qt.rgba(0.086, 0.100, 0.130, 0.70)
    readonly property color panelBgHover: Qt.rgba(0.120, 0.140, 0.180, 0.85)

    // Zarif panel kenarlıkları ve ayraç çizgileri
    readonly property color panelBorder: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    readonly property color panelBorderHover: Qt.rgba(1.0, 1.0, 1.0, 0.18)
    readonly property color panelBorderActive: Qt.rgba(0.176, 0.498, 0.976, 0.45)

    // =========================================================================
    // 2. TİPOGRAFİ (METİN RENKLERİ)
    // =========================================================================
    // Birincil metin: Parlamayan temiz titanyum beyazı (Hız ve ana rakamlar)
    readonly property color textPrimary: "#F1F3F5"

    // İkincil metin: Soğuk gri (Birimler, etiketler ve ikincil açıklamalar)
    readonly property color textSecondary: "#7E8695"

    // Pasif / sönük metin: Ayraç noktaları, devre dışı veya arka plan etiketleri
    readonly property color textMuted: "#4B515D"

    // =========================================================================
    // 3. VURGU & FONKSİYONEL DURUM RENKLERİ
    // =========================================================================
    // Havacılık mavisi: Neon patlaması yapmayan tok aero mavi (Aktif hatlar, seçimler)
    readonly property color accentAero: "#2D7FF9"
    readonly property color accentAeroGlow: Qt.rgba(0.176, 0.498, 0.976, 0.20)

    // Nominal / Güvenli operasyon: Zümrüt yeşili (Normal basınç, aktif levitasyon)
    readonly property color statusNormal: "#10B981"

    // Dikkat / Uyarı: Kehribar (Sıcaklık artışı, tüp basınç dalgalanması)
    readonly property color statusWarning: "#F59E0B"

    // Acil durum: Havacılık kırmızısı (Acil fren, hat düşmesi)
    readonly property color statusCritical: "#EF4444"

    // =========================================================================
    // 4. TİPOGRAFİ SABİTLERİ
    // =========================================================================
    readonly property string fontFamily: "Satoshi"
}
