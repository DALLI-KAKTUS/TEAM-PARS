// ui/views/overview/cockpit/CockpitPhysicsEngine.qml
// Yarışma kokpitinin arka planında 30 Hz hızında çalışan fizik ve telemetri motoru.
// Tünel ölçülerini, kapsülün hızlanma ve frenleme hareketini, batarya tüketimini,
// motor/sürücü/ray ısınmasını ve osiloskop grafiklerinin veri dizilerini yönetir.
import QtQuick

Item {
    id: simRoot

    // -------------------------------------------------------------------------
    // 1. TÜNEL VE PARKUR SABİTLERİ (TEKNOFEST ŞARTNAMESİ ÖLÇÜLERİ)
    // Tünelin toplam boyu 208 m'dir. İlk 5 m kapsül başlangıç alanı, 11. metreden
    // 191. metreye kadar her 4 metrede bir (toplam 46 adet) reflektör şeridi vardır.
    // Kapsül 136. metrede frenlemeye başlayıp 191. metredeki yarış bitişinden önce durur.
    // -------------------------------------------------------------------------
    readonly property real totalDistance: 208.0
    readonly property real launchZoneEnd: 5.0
    readonly property real firstReflectorPos: 11.0
    readonly property real reflectorPitch: 4.0
    readonly property int reflectorTotal: 46
    readonly property real marker100mPos: 91.0
    readonly property real marker48mPos: 143.0
    readonly property real brakingStartPos: 136.0
    readonly property real raceFinishPos: 191.0

    // Kadranların maksimum skala değerleri ve güvenlik sıcaklık sınırları
    readonly property real gaugeMaxSpeed: 140.0
    readonly property real gaugeMaxGForce: 2.4
    readonly property real maxMotorPowerKw: 80.0
    readonly property real battTempLimit: 55.0
    readonly property real railDeltaTLimit: 30.0
    readonly property int logRateHz: 30

    // -------------------------------------------------------------------------
    // 2. SÜRÜŞ DURUMU VE ANLIK FİZİKSEL DEĞİŞKENLER
    // `runState` dört değer alabilir:
    // - "STANDBY"  : 0 metrede başlangıç için hazır bekliyor
    // - "RUNNING"  : E-START verildi, kapsül tünelde ilerliyor
    // - "ESTOP"    : Acil durdurma tetiklendi, tam frenle duruyor
    // - "FINISHED" : Parkur tamamlandı ve kapsül güvenli bölgede durdu
    // -------------------------------------------------------------------------
    property bool active: false
    property bool isSweeping: false
    property string runState: "STANDBY"

    // Hareket (Mesafe, Hız, İvme ve G-kuvveti) değişkenleri
    property real simDistance: 0.0
    property real simVelMs: 0.0
    property real simVyMs: 0.0
    property real simVzMs: 0.0
    property real simSpeedKmh: 0.0
    property real maxSpeedKmh: 0.0
    property real simAccelMs2: 0.0
    property real simGForce: 0.0

    // Elektrik ve Batarya (Güç, Akım, Harcanan Enerji, SOC %, Voltaj ve Hücre Sıcaklıkları)
    property real simMotorPowerKw: 0.0
    property real simCurrentA: 0.0
    property real simEnergyWh: 0.0
    property real peakPowerKw: 0.0
    property real simBatteryPercent: 98.0
    property real simPackVoltage: 110.8
    property real batteryTemp1: 28.0
    property real batteryTemp2: 29.0

    // Termal ve Pnömatik Fren (Motor/Sürücü sıcaklığı, Ray ısınması, Fren % ve Tank barı)
    property real simMotorTempC: 27.0
    property real simDriverTempC: 29.0
    property real railDeltaT: 0.0
    property real simBrakePercent: 100.0
    property real simTankBar: 8.2

    // 3-Eksen Konum (Y yatay sapma, Z ray boşluğu) ve Yönelim (Roll, Pitch, Yaw açıları)
    property real posYmm: 0.0
    property real posZmm: 12.0
    property real rollDeg: 0.0
    property real pitchDeg: 0.0
    property real yawDeg: 0.0
    property real linkLatencyMs: 3.2

    readonly property real maxBatteryTemp: Math.max(batteryTemp1, batteryTemp2)

    // -------------------------------------------------------------------------
    // 3. CANLI GRAFİK GEÇMİŞ DİZİLERİ (56 ÖRNEKLİ KAYAN TAMPON)
    // Sol ve sağ kanattaki osiloskop grafiklerinin çizdiği son 56 noktalık
    // normalize (0.0 ile 1.0 arası) Hız, G-Kuvveti ve Güç verilerini tutar.
    // -------------------------------------------------------------------------
    readonly property int historyCapacity: 56
    property var speedHistory: []
    property var gForceHistory: []
    property var powerHistory: []
    property int historyRevision: 0

    signal physicsUpdated()
    signal safetyLimitExceeded()

    // Grafik dizilerini sıfırlarla doldurarak ilk haline getirir
    function initHistoryBuffers() {
        var s = []
        var g = []
        var p = []
        for (var i = 0; i < historyCapacity; i++) {
            s.push(0.0)
            g.push(0.0)
            p.push(0.0)
        }
        speedHistory = s
        gForceHistory = g
        powerHistory = p
        historyRevision++
    }

    // Grafiklere yeni bir örnek ekler; en eski (sol uçtaki) örneği diziden çıkarır
    function pushTelemetrySample(spdRatio, gRatio, pwrRatio) {
        if (speedHistory.length < historyCapacity) {
            initHistoryBuffers()
        }
        speedHistory.shift()
        speedHistory.push(Math.max(0.0, Math.min(1.0, spdRatio)))

        gForceHistory.shift()
        gForceHistory.push(Math.max(0.0, Math.min(1.0, gRatio)))

        powerHistory.shift()
        powerHistory.push(Math.max(0.0, Math.min(1.0, pwrRatio)))

        historyRevision++
    }

    // -------------------------------------------------------------------------
    // 4. DURUM GEÇİŞ VE SIFIRLAMA YARDIMCILARI
    // -------------------------------------------------------------------------
    // Kapsülü 0 metreye ve bekleme değerlerine alır
    function resetSimulationToStart() {
        runState = "STANDBY"
        simDistance = 0.0
        simVelMs = 0.0
        simVyMs = 0.0
        simVzMs = 0.0
        simSpeedKmh = 0.0
        simAccelMs2 = 0.0
        simGForce = 0.0
        simMotorPowerKw = 0.0
        simCurrentA = 0.0
        simEnergyWh = 0.0
        peakPowerKw = 0.0
        simBrakePercent = 100.0
        simPackVoltage = 100.8 + (simBatteryPercent / 100.0) * 10.2
        posYmm = 0.0
        posZmm = 12.0
        rollDeg = 0.0
        pitchDeg = 0.0
        yawDeg = 0.0
    }

    // E-START'a basıldığında eğer kapsül önceki sürüşü bitirmişse 0 metreye çekip başlatır
    function prepareAndStartRun() {
        if (simDistance >= brakingStartPos - 4.0 || runState === "FINISHED") {
            simDistance = 0.0
            simVelMs = 0.0
            simSpeedKmh = 0.0
            simAccelMs2 = 0.0
            simGForce = 0.0
            simMotorPowerKw = 0.0
            simEnergyWh = 0.0
            if (simBatteryPercent < 25.0) {
                simBatteryPercent = 98.0
            }
            simTankBar = 8.2
        }
        runState = "RUNNING"
    }

    // E-STOP verildiğinde pnömatik tanktan fren basıncı harcayıp acil duruş moduna sokar
    function engageEmergencyStop() {
        if (simTankBar > 7.3) {
            simTankBar = Math.max(7.2, simTankBar - 0.15)
        }
        runState = "ESTOP"
    }

    // "0 m SIFIRLA" butonuna basıldığında sıcaklıkları, bataryayı ve tepe hızı da sıfırlar
    function fullTrackReset() {
        maxSpeedKmh = 0.0
        simBatteryPercent = 98.0
        simTankBar = 8.2
        simMotorTempC = 27.0
        simDriverTempC = 29.0
        railDeltaT = 0.0
        initHistoryBuffers()
        resetSimulationToStart()
    }

    Component.onCompleted: {
        initHistoryBuffers()
    }

    // -------------------------------------------------------------------------
    // 5. 30 Hz GERÇEK ZAMANLI FİZİK DÖNGÜSÜ (`interval: 33 ms`)
    // Kadran selamlaması (`isSweeping`) bittikten sonra her 33 milisaniyede bir
    // çalışarak kapsülün bir sonraki konumunu ve telemetri değerlerini hesaplar.
    // -------------------------------------------------------------------------
    Timer {
        id: physicsTimer
        interval: 33
        repeat: true
        running: simRoot.active && !simRoot.isSweeping

        onTriggered: {
            const dt = 0.033
            var targetAccel = 0.0
            var targetPower = 0.0
            var targetBrake = 100.0

            // A. HAREKET VE FRENLEME KİNEMATİĞİ
            if (simRoot.runState === "RUNNING") {
                if (simRoot.simDistance < simRoot.brakingStartPos) {
                    // 0 m -> 136 m arası: LIM motoru devrede, frenler açık (%0).
                    // Kapsül ~114.5 km/h (31.8 m/s) tepe hıza yaklaşırken ivme kademeli azalır.
                    const vMaxMs = 31.8
                    const speedFactor = Math.max(0.0, 1.0 - (simRoot.simVelMs / vMaxMs) * 0.72)
                    targetAccel = simRoot.simVelMs < vMaxMs ? (11.6 * speedFactor) : 0.2
                    targetPower = Math.min(72.0, 9.5 + (simRoot.simVelMs / vMaxMs) * 60.5)
                    targetBrake = 0.0
                } else {
                    // 136 m sonrası: Motor gücü kesilir, 188.5 m noktasında durmak için
                    // gereken yavaşlama ivmesi `a = v² / (2 * Δx)` formülüyle hesaplanır.
                    const stopTargetPos = 188.5
                    const remStopDist = Math.max(0.4, stopTargetPos - simRoot.simDistance)
                    const neededDecel = (simRoot.simVelMs * simRoot.simVelMs) / (2.0 * remStopDist)
                    targetAccel = -Math.min(15.5, Math.max(2.5, neededDecel))
                    targetPower = 0.0
                    targetBrake = 92.0
                }

                // İvmeyi yumuşak filtreyle güncelleyip hızı (v = v0 + a*dt) ve konumu (x = x0 + v*dt) ilerletiyoruz
                simRoot.simAccelMs2 += (targetAccel - simRoot.simAccelMs2) * 0.24
                simRoot.simVelMs = Math.max(0.0, simRoot.simVelMs + simRoot.simAccelMs2 * dt)
                simRoot.simDistance = Math.min(simRoot.totalDistance, simRoot.simDistance + simRoot.simVelMs * dt)

                // Fren bölgesinde hız sıfıra indiğinde sürüşü "FINISHED" olarak tamamla
                if (simRoot.simDistance >= simRoot.brakingStartPos && simRoot.simVelMs <= 0.12) {
                    simRoot.simVelMs = 0.0
                    simRoot.simAccelMs2 = 0.0
                    simRoot.simMotorPowerKw = 0.0
                    simRoot.simBrakePercent = 100.0
                    if (simRoot.simTankBar > 7.3) {
                        simRoot.simTankBar = Math.max(7.2, simRoot.simTankBar - 0.12)
                    }
                    simRoot.runState = "FINISHED"
                }
            } else if (simRoot.runState === "ESTOP") {
                // Acil durdurma modunda motor kesilir, fren %100 kilitlenir ve -16.2 m/s² ile durulur
                targetPower = 0.0
                targetBrake = 100.0

                if (simRoot.simVelMs > 0.08) {
                    targetAccel = -16.2
                    simRoot.simAccelMs2 += (targetAccel - simRoot.simAccelMs2) * 0.32
                    simRoot.simVelMs = Math.max(0.0, simRoot.simVelMs + simRoot.simAccelMs2 * dt)
                    simRoot.simDistance = Math.min(simRoot.totalDistance, simRoot.simDistance + simRoot.simVelMs * dt)
                } else {
                    simRoot.simVelMs = 0.0
                    simRoot.simAccelMs2 += (0.0 - simRoot.simAccelMs2) * 0.35
                    if (Math.abs(simRoot.simAccelMs2) < 0.05) {
                        simRoot.simAccelMs2 = 0.0
                    }
                }
            } else {
                // Bekleme veya bitiş durumunda hız 0, fren %100 basılıdır
                targetPower = 0.0
                targetBrake = 100.0
                simRoot.simVelMs = 0.0
                simRoot.simAccelMs2 += (0.0 - simRoot.simAccelMs2) * 0.30
                if (Math.abs(simRoot.simAccelMs2) < 0.04) {
                    simRoot.simAccelMs2 = 0.0
                }
            }

            // B. HIZ (km/h), G-KUVVETİ VE MOTOR GÜCÜ HESABI
            simRoot.simSpeedKmh = simRoot.simVelMs * 3.6
            if (simRoot.simSpeedKmh > simRoot.maxSpeedKmh) {
                simRoot.maxSpeedKmh = simRoot.simSpeedKmh
            }

            simRoot.simGForce = Math.abs(simRoot.simAccelMs2) / 9.81
            simRoot.simMotorPowerKw += (targetPower - simRoot.simMotorPowerKw) * 0.25
            if (simRoot.simMotorPowerKw < 0.15) {
                simRoot.simMotorPowerKw = 0.0
            }
            if (simRoot.simMotorPowerKw > simRoot.peakPowerKw) {
                simRoot.peakPowerKw = simRoot.simMotorPowerKw
            }

            simRoot.simBrakePercent += (targetBrake - simRoot.simBrakePercent) * 0.28

            // C. BATARYA TÜKETİMİ, VOLTAJ ÇÖKMESİ (SAG) VE AKIM (I = P / V) HESABI
            if (simRoot.simMotorPowerKw > 0.1) {
                const usedSoc = (simRoot.simMotorPowerKw * dt / 3600.0) / 1.8 * 100.0
                simRoot.simBatteryPercent = Math.max(15.0, simRoot.simBatteryPercent - usedSoc)
                simRoot.simEnergyWh += simRoot.simMotorPowerKw * 1000.0 * dt / 3600.0
            }
            const openCircuitV = 100.8 + (simRoot.simBatteryPercent / 100.0) * 10.2
            const targetV = openCircuitV - simRoot.simMotorPowerKw * 0.055
            simRoot.simPackVoltage += (targetV - simRoot.simPackVoltage) * 0.20
            simRoot.simCurrentA = simRoot.simPackVoltage > 1.0
                                  ? (simRoot.simMotorPowerKw * 1000.0) / simRoot.simPackVoltage
                                  : 0.0

            // D. MOTOR, SÜRÜCÜ, BATARYA HÜCRESİ VE RAY ΔT SICAKLIK DEĞİŞİMLERİ
            const motorHeat = (simRoot.simMotorPowerKw * 0.042 - (simRoot.simMotorTempC - 27.0) * 0.08) * dt
            const driverHeat = (simRoot.simMotorPowerKw * 0.034 - (simRoot.simDriverTempC - 29.0) * 0.08) * dt
            simRoot.simMotorTempC = Math.min(52.0, Math.max(27.0, simRoot.simMotorTempC + motorHeat))
            simRoot.simDriverTempC = Math.min(51.0, Math.max(29.0, simRoot.simDriverTempC + driverHeat))

            const battHeat = (simRoot.simMotorPowerKw * 0.015 - (simRoot.batteryTemp1 - 28.0) * 0.06) * dt
            simRoot.batteryTemp1 = Math.min(48.0, Math.max(28.0, simRoot.batteryTemp1 + battHeat))
            simRoot.batteryTemp2 = Math.min(49.0, Math.max(29.0, simRoot.batteryTemp1 + 1.0))

            const railHeat = simRoot.simMotorPowerKw * 0.004
                           + (simRoot.simBrakePercent / 100.0) * simRoot.simVelMs * 0.012
            simRoot.railDeltaT = Math.min(simRoot.railDeltaTLimit,
                                          Math.max(0.0, simRoot.railDeltaT + (railHeat - simRoot.railDeltaT * 0.05) * dt))

            // E. KAPSÜL 3-EKSEN KONUM (Y, Z) VE YÖNELİM (ROLL, PITCH, YAW) SALINIMLARI
            // İvmelenirken burun hafif kalkar (+pitch), frenlerken hafif öne eğilir (-pitch)
            const prevY = simRoot.posYmm
            const prevZ = simRoot.posZmm
            const targetPitch = (simRoot.simAccelMs2 / 12.0) * 0.45
            simRoot.pitchDeg += (targetPitch - simRoot.pitchDeg) * 0.22
            if (simRoot.simVelMs > 0.5) {
                const phase = simRoot.simDistance * 0.35
                simRoot.rollDeg = Math.sin(phase) * 0.12
                simRoot.yawDeg = Math.cos(phase * 0.7) * 0.08
                simRoot.posYmm = Math.sin(phase * 0.5) * 0.4
                simRoot.posZmm = 12.0 + Math.cos(phase * 0.8) * 0.2
                simRoot.linkLatencyMs = 3.1 + Math.abs(Math.sin(phase * 0.3)) * 1.4
            } else {
                simRoot.rollDeg += (0.0 - simRoot.rollDeg) * 0.25
                simRoot.yawDeg += (0.0 - simRoot.yawDeg) * 0.25
                simRoot.posYmm += (0.0 - simRoot.posYmm) * 0.25
                simRoot.posZmm += (12.0 - simRoot.posZmm) * 0.25
                simRoot.linkLatencyMs = 3.2
            }
            simRoot.simVyMs = (simRoot.posYmm - prevY) / 1000.0 / dt
            simRoot.simVzMs = (simRoot.posZmm - prevZ) / 1000.0 / dt

            // F. GÜVENLİK SINIRI AŞIMI KONTROLÜ (55°C sıcaklık veya 191 m yarış sonu aşımı)
            if (simRoot.runState === "RUNNING"
                    && (simRoot.maxBatteryTemp >= simRoot.battTempLimit
                        || simRoot.simMotorTempC >= simRoot.battTempLimit
                        || simRoot.simDistance > simRoot.raceFinishPos)) {
                simRoot.safetyLimitExceeded()
            }

            simRoot.physicsUpdated()
        }
    }
}
