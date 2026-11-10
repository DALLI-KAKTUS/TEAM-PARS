// ui/views/overview/cockpit/CockpitSweepAnimator.qml
// Yarışma kokpitindeki iki temel animasyon sürecini yöneten kontrolcü:
// 1. Kadran Selamlama (`gaugeSweepAnim`): Yarışma moduna ilk geçildiğinde tüm
//    kadranları, barları ve sayaçları 0 -> Tam Skala -> 0 m Başlangıç değerine
//    tarayarak sistemin tüm göstergelerini test eder.
// 2. 60 FPS Görsel Akış Döngüsü (`visualAnimTimer`): Ortadaki 3B tünelin halka/ışık
//    akışını, sağdaki bataryanın hücre dalgasını ve canlı grafiklerin örneklemesini
//    saniyede 60 kare hızında günceller.
import QtQuick

Item {
    id: animController

    property bool active: false
    property var simulator: null

    // Selamlama animasyonu devam ederken true olur
    property bool isSweeping: false

    // -------------------------------------------------------------------------
    // 1. EKRANDA GÖSTERİLEN (`display*`) DEĞERLER
    // Selamlama sırasında bu değerler animasyonla 0'dan maksimuma çıkarılıp indirilir;
    // selamlama bittiğinde ise `CockpitPhysicsEngine` içindeki gerçek fiziksel
    // değerlere (`sim*`) eşitlenir.
    // -------------------------------------------------------------------------
    property real displayDistance: 0.0
    property real displaySpeedKmh: 0.0
    property real displayGForce: 0.0
    property real displayMotorPowerKw: 0.0
    property real displayBatteryPercent: 98.0
    property real displayPackVoltage: 110.8
    property real displayMotorTempC: 27.0
    property real displayDriverTempC: 29.0
    property real displayBrakePercent: 100.0
    property real displayTankBar: 8.2

    // Kokpit açılışında kanatların kayma mesafesi, merkez ölçeği ve nişangah açısı
    property real wingSlideOffset: 0.0
    property real centerClusterScale: 1.0
    property real reticleSweepAngle: 0.0
    property real liveOrbitAngle: 0.0

    // 60 FPS güncellenen tünel halka ilerlemesi, ışık dalgası ve batarya akış fazları (0.0 .. 1.0)
    property real tunnelTravelPhase: 0.0
    property real tunnelLightWave: 0.0
    property real battAnimPhase: 0.0
    property int graphTickCounter: 0

    // Kapsül sürüş halindeyken E-START etrafındaki nişangah halkasını sürekli döndürür
    NumberAnimation on liveOrbitAngle {
        from: 0
        to: 360
        duration: 24000
        loops: Animation.Infinite
        running: animController.active && animController.simulator !== null && animController.simulator.runState === "RUNNING"
    }

    // -------------------------------------------------------------------------
    // 2. SENKRONİZASYON VE KONTROL FONKSİYONLARI
    // -------------------------------------------------------------------------
    // Fizik motorundaki anlık değerleri ekran değişkenlerine kopyalar
    function syncDisplayWithSim() {
        if (!simulator) return
        displayDistance = simulator.simDistance
        displaySpeedKmh = simulator.simSpeedKmh
        displayGForce = simulator.simGForce
        displayMotorPowerKw = simulator.simMotorPowerKw
        displayBatteryPercent = simulator.simBatteryPercent
        displayPackVoltage = simulator.simPackVoltage
        displayMotorTempC = simulator.simMotorTempC
        displayDriverTempC = simulator.simDriverTempC
        displayBrakePercent = simulator.simBrakePercent
        displayTankBar = simulator.simTankBar
    }

    // Selamlama bitmeden kullanıcı E-START veya E-STOP'a basarsa selamlamayı anında
    // kesip kadranları gerçek fizik değerlerine oturtur.
    function cancelSweepAndSnapLayout() {
        if (isSweeping) {
            gaugeSweepAnim.stop()
            isSweeping = false
        }
        wingSlideOffset = 0.0
        centerClusterScale = 1.0
        reticleSweepAngle = 0.0
        syncDisplayWithSim()
    }

    // Tüm göstergeleri sıfırlayıp 2 aşamalı kadran selamlama animasyonunu başlatır
    function triggerGaugeSweep() {
        gaugeSweepAnim.stop()
        isSweeping = true

        displayDistance = 0.0
        displaySpeedKmh = 0.0
        displayGForce = 0.0
        displayMotorPowerKw = 0.0
        displayBatteryPercent = 0.0
        displayPackVoltage = 0.0
        displayMotorTempC = 0.0
        displayDriverTempC = 0.0
        displayBrakePercent = 0.0
        displayTankBar = 0.0

        wingSlideOffset = 24.0
        centerClusterScale = 0.94
        reticleSweepAngle = -75.0

        gaugeSweepAnim.start()
    }

    function stopAllAnimations() {
        gaugeSweepAnim.stop()
        isSweeping = false
    }

    // -------------------------------------------------------------------------
    // 3. 60 FPS GÖRSEL ANİMASYON DÖNGÜSÜ (`interval: 16 ms`)
    // -------------------------------------------------------------------------
    Timer {
        id: visualAnimTimer
        interval: 16
        repeat: true
        running: animController.active

        onTriggered: {
            if (!animController.simulator) return
            const dt = 0.016
            const maxSpd = animController.simulator.gaugeMaxSpeed
            const maxG = animController.simulator.gaugeMaxGForce
            const maxPwr = animController.simulator.maxMotorPowerKw

            // A. Ortadaki 3B tünelin halka ve ışık dalgası hızını güncelle
            if (animController.isSweeping) {
                const sweepSpeedFactor = 0.4 + 3.4 * (animController.displaySpeedKmh / maxSpd)
                animController.tunnelTravelPhase = (animController.tunnelTravelPhase + sweepSpeedFactor * dt) % 1.0
                animController.tunnelLightWave = (animController.tunnelLightWave + 1.8 * dt) % 1.0
            } else if (animController.displaySpeedKmh > 0.4) {
                // Kapsül ilerlerken halkaların geliş hızı kapsülün gerçek hızıyla (m/s) doğru orantılıdır
                const vMs = animController.displaySpeedKmh / 3.6
                const ringRate = Math.min(4.8, (vMs / 4.0) * 0.58)
                animController.tunnelTravelPhase = (animController.tunnelTravelPhase + ringRate * dt) % 1.0
                animController.tunnelLightWave = (animController.tunnelLightWave + (0.7 + ringRate * 0.45) * dt) % 1.0
            } else {
                // Kapsül dururken halkalar sabit kalır, yalnızca reflektör ışıkları arkadan öne akar
                animController.tunnelLightWave = (animController.tunnelLightWave + 0.48 * dt) % 1.0
            }

            // B. Sağ kanattaki batarya hücrelerinin parlama dalgasını ilerlet (motor güç çekerken hızlanır)
            const battSpeed = animController.displayMotorPowerKw > 0.5 ? 1.65 : 0.42
            animController.battAnimPhase = (animController.battAnimPhase + battSpeed * dt) % 1.0

            // C. Her 3 karede bir (~20 Hz) sol ve sağdaki osiloskop grafiklerine yeni veri noktası ekle
            animController.graphTickCounter = (animController.graphTickCounter + 1) % 3
            if (animController.graphTickCounter === 0) {
                animController.simulator.pushTelemetrySample(
                    animController.displaySpeedKmh / maxSpd,
                    animController.displayGForce / maxG,
                    animController.displayMotorPowerKw / maxPwr
                )
            }
        }
    }

    // -------------------------------------------------------------------------
    // 4. KADRAN SELAMLAMA ANİMASYONU (0 -> MAKSİMUM -> 0 m HAZIR)
    // -------------------------------------------------------------------------
    SequentialAnimation {
        id: gaugeSweepAnim

        // 1. AŞAMA (520 ms): Kanatlar yerine otururken tüm ibreler tam skalaya (208 m, 140 km/h, 80 kW) vurur
        ParallelAnimation {
            NumberAnimation { target: animController; property: "wingSlideOffset"; to: 0.0; duration: 420; easing.type: Easing.OutExpo }
            NumberAnimation { target: animController; property: "centerClusterScale"; to: 1.0; duration: 460; easing.type: Easing.OutBack }
            NumberAnimation { target: animController; property: "reticleSweepAngle"; to: 18.0; duration: 520; easing.type: Easing.OutCubic }

            NumberAnimation { target: animController; property: "displayDistance"; to: animController.simulator ? animController.simulator.totalDistance : 208.0; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: animController; property: "displaySpeedKmh"; to: animController.simulator ? animController.simulator.gaugeMaxSpeed : 140.0; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: animController; property: "displayGForce"; to: animController.simulator ? animController.simulator.gaugeMaxGForce : 2.4; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: animController; property: "displayMotorPowerKw"; to: animController.simulator ? animController.simulator.maxMotorPowerKw : 80.0; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: animController; property: "displayBatteryPercent"; to: 100.0; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: animController; property: "displayPackVoltage"; to: 120.0; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: animController; property: "displayMotorTempC"; to: 55.0; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: animController; property: "displayDriverTempC"; to: 55.0; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: animController; property: "displayBrakePercent"; to: 100.0; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: animController; property: "displayTankBar"; to: 10.0; duration: 520; easing.type: Easing.OutCubic }
        }

        // Tepe noktasında 90 ms kısa bekleme
        PauseAnimation { duration: 90 }

        // 2. AŞAMA (620 ms): İbreler tepe noktadan 0 m başlangıç ve gerçek sensör değerlerine geri döner
        ParallelAnimation {
            NumberAnimation { target: animController; property: "reticleSweepAngle"; to: 0.0; duration: 600; easing.type: Easing.OutQuart }

            NumberAnimation { target: animController; property: "displayDistance"; to: 0.0; duration: 620; easing.type: Easing.OutQuart }
            NumberAnimation { target: animController; property: "displaySpeedKmh"; to: 0.0; duration: 620; easing.type: Easing.OutQuart }
            NumberAnimation { target: animController; property: "displayGForce"; to: 0.0; duration: 620; easing.type: Easing.OutQuart }
            NumberAnimation { target: animController; property: "displayMotorPowerKw"; to: 0.0; duration: 620; easing.type: Easing.OutQuart }
            NumberAnimation { target: animController; property: "displayBatteryPercent"; to: animController.simulator ? animController.simulator.simBatteryPercent : 98.0; duration: 620; easing.type: Easing.OutQuart }
            NumberAnimation { target: animController; property: "displayPackVoltage"; to: animController.simulator ? animController.simulator.simPackVoltage : 110.8; duration: 620; easing.type: Easing.OutQuart }
            NumberAnimation { target: animController; property: "displayMotorTempC"; to: animController.simulator ? animController.simulator.simMotorTempC : 27.0; duration: 620; easing.type: Easing.OutQuart }
            NumberAnimation { target: animController; property: "displayDriverTempC"; to: animController.simulator ? animController.simulator.simDriverTempC : 29.0; duration: 620; easing.type: Easing.OutQuart }
            NumberAnimation { target: animController; property: "displayBrakePercent"; to: animController.simulator ? animController.simulator.simBrakePercent : 100.0; duration: 620; easing.type: Easing.OutQuart }
            NumberAnimation { target: animController; property: "displayTankBar"; to: animController.simulator ? animController.simulator.simTankBar : 8.2; duration: 620; easing.type: Easing.OutQuart }
        }

        // Selamlama bittiğinde grafik geçmişini temizleyip kontrolü canlı fizik motoruna devreder
        ScriptAction {
            script: {
                animController.isSweeping = false
                if (animController.simulator) {
                    animController.simulator.initHistoryBuffers()
                }
                animController.syncDisplayWithSim()
            }
        }
    }
}
