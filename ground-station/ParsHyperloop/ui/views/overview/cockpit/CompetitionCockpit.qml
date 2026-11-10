// ui/views/overview/cockpit/CompetitionCockpit.qml
// Genel Bakış sayfasında "Yarışma" sekmesine geçildiğinde açılan ana kokpit ekranı.
// Kokpiti oluşturan 5 görsel bölgeyi (`CockpitBorderFrame`, `TunnelProgressMap`,
// `LeftSpeedPanel`, `CenterCommandPanel`, `RightPowerPanel`) ve arka planda çalışan
// fizik motoru (`CockpitPhysicsEngine`) ile animasyon kontrolcüsünü (`CockpitSweepAnimator`)
// birbirine bağlar.
import QtQuick
import ParsHyperloop

Item {
    id: hudRoot
    anchors.fill: parent

    // OverviewPage'den gelen aktiflik ve güvenlik izin durumları
    property bool active: false
    property bool linkOk: true
    property bool motorEnabled: true

    // Üst komuta barında bildirim göstermek için dışarıya yayılan sinyaller
    signal eStartTriggered()
    signal eStopTriggered()
    signal eStartRejected(string reason)
    signal trackReset()

    // -------------------------------------------------------------------------
    // 1. ARKA PLAN FİZİK VE TELEMETRİ MOTORU (30 Hz)
    // Kapsülün hız, ivme, konum, batarya gerilimi ve motor/ray sıcaklıklarını
    // gerçek zamanlı hesaplar. Bir adım tamamlandığında ekran değerlerini eşitler,
    // sıcaklık veya mesafe sınırı aşılırsa otomatik E-STOP tetikler.
    // -------------------------------------------------------------------------
    CockpitPhysicsEngine {
        id: physicsSim
        active: hudRoot.active
        isSweeping: animCtrl.isSweeping

        onPhysicsUpdated: animCtrl.syncDisplayWithSim()
        onSafetyLimitExceeded: hudRoot.triggerEmergencyStop()
    }

    // -------------------------------------------------------------------------
    // 2. KADRAN SELAMLAMA VE 60 FPS GÖRSEL ANİMASYON KONTROLCÜSÜ
    // Yarışma moduna ilk geçildiğinde tüm ibreleri 0 -> Maksimum -> 0 olarak
    // selamlamaya sokar; ayrıca tünel halkalarının ve batarya enerji dalgasının
    // 60 FPS akış fazlarını üretir.
    // -------------------------------------------------------------------------
    CockpitSweepAnimator {
        id: animCtrl
        active: hudRoot.active
        simulator: physicsSim
    }

    // -------------------------------------------------------------------------
    // 3. EKRANDA GÖSTERİLEN TÜRETİLMİŞ HESAPLAMALAR
    // Tünel ilerleme oranı (0..1), kalan metre, motor yük yüzdesi (%0..100),
    // geçilen reflektör şeridi sayısı (0..46) ve 4 adımlı sürüş fazı indeksi.
    // -------------------------------------------------------------------------
    readonly property real progressRatio: Math.max(0.0, Math.min(1.0, animCtrl.displayDistance / physicsSim.totalDistance))
    readonly property real remainingDistance: Math.max(0.0, physicsSim.totalDistance - animCtrl.displayDistance)
    readonly property int displayPowerPercent: Math.round(Math.max(0, Math.min(100, (animCtrl.displayMotorPowerKw / physicsSim.maxMotorPowerKw) * 100)))
    readonly property int litReflectors: animCtrl.displayDistance < physicsSim.firstReflectorPos
                                         ? 0
                                         : Math.min(physicsSim.reflectorTotal,
                                                    Math.floor((animCtrl.displayDistance - physicsSim.firstReflectorPos) / physicsSim.reflectorPitch) + 1)

    // Sol kanattaki "SÜRÜŞ FAZI" adımlarından hangisinin aktif olduğunu belirler:
    // 0: HAZIR | 1: İVMELENME | 2: FRENLEME (veya ACİL FREN) | 3: DURUŞ (veya ACİL DURUŞ)
    readonly property int phaseIndex: {
        if (animCtrl.isSweeping) return 0
        if (physicsSim.runState === "RUNNING") return physicsSim.simDistance < physicsSim.brakingStartPos ? 1 : 2
        if (physicsSim.runState === "ESTOP") return physicsSim.simVelMs > 0.1 ? 2 : 3
        if (physicsSim.runState === "FINISHED") return 3
        return 0
    }

    // -------------------------------------------------------------------------
    // 4. MOD GEÇİŞİ, GÜVENLİK KİLİTLERİ VE KOMUT FONKSİYONLARI
    // -------------------------------------------------------------------------
    // Kokpit görünür olduğunda parkuru sıfırlayıp kadran selamlamasını başlatır
    onActiveChanged: {
        if (active) {
            physicsSim.initHistoryBuffers()
            physicsSim.resetSimulationToStart()
            animCtrl.triggerGaugeSweep()
        } else {
            animCtrl.stopAllAnimations()
            physicsSim.runState = "STANDBY"
        }
    }

    // Sürüş esnasında üst bardan Bağlantı kesilirse otomatik acil duruşa geçer
    onLinkOkChanged: {
        if (!linkOk && (physicsSim.runState === "RUNNING" || physicsSim.simVelMs > 0.1)) {
            triggerEmergencyStop()
        }
    }

    // Sürüş esnasında üst bardan Motor kapatılırsa otomatik acil duruşa geçer
    onMotorEnabledChanged: {
        if (!motorEnabled && physicsSim.runState === "RUNNING") {
            triggerEmergencyStop()
        }
    }

    // E-START butonuna basıldığında güvenlik şartlarını kontrol edip sürüşü başlatır
    function startCompetitionRun() {
        animCtrl.cancelSweepAndSnapLayout()

        if (!linkOk) {
            eStartRejected("BAĞLANTI YOK")
            return
        }

        if (!motorEnabled) {
            eStartRejected("MOTOR DURDU")
            return
        }

        if (physicsSim.runState === "RUNNING") {
            return
        }

        physicsSim.prepareAndStartRun()
        animCtrl.syncDisplayWithSim()
        centerZone.triggerEStartPulse()
        eStartTriggered()
    }

    // E-STOP butonuna basıldığında veya acil bir durum algılandığında frenleri kilitler
    function triggerEmergencyStop() {
        animCtrl.cancelSweepAndSnapLayout()

        if (physicsSim.runState === "ESTOP") {
            return
        }

        physicsSim.engageEmergencyStop()
        animCtrl.syncDisplayWithSim()
        centerZone.triggerEStopPulse()
        eStopTriggered()
    }

    // Kapsül durduktan sonra çıkan "0 m SIFIRLA" butonuna basıldığında her şeyi başa alır
    function resetTrackPosition() {
        animCtrl.cancelSweepAndSnapLayout()
        physicsSim.fullTrackReset()
        animCtrl.syncDisplayWithSim()
        trackReset()
    }

    // -------------------------------------------------------------------------
    // 5. GÖRSEL KATMANLAR: DIŞ ÇERÇEVE, TÜNEL HARİTASI VE 3 KOKPİT BÖLGESİ
    // -------------------------------------------------------------------------

    // En altta siyah zemin ve kokpitin köşe pah çizgileri
    CockpitBorderFrame {
        anchors.fill: parent
    }

    // Üstte 208 metrelik doğrusal tünel haritası ve hareketli kapsül silüeti
    TunnelProgressMap {
        id: tunnelNavSection
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 210
            leftMargin: 44
            rightMargin: 44
        }

        totalDistance: physicsSim.totalDistance
        firstReflectorPos: physicsSim.firstReflectorPos
        reflectorPitch: physicsSim.reflectorPitch
        reflectorTotal: physicsSim.reflectorTotal
        raceFinishPos: physicsSim.raceFinishPos

        displayDistance: animCtrl.displayDistance
        posYmm: physicsSim.posYmm
        posZmm: physicsSim.posZmm
        progressRatio: hudRoot.progressRatio
        remainingDistance: hudRoot.remainingDistance
        litReflectors: hudRoot.litReflectors
    }

    // Tünel haritasının altında kalan 3 bölgeli (Sol Kanat - Merkez - Sağ Kanat) ana alan
    Item {
        id: cockpitMainArea
        anchors {
            top: tunnelNavSection.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            topMargin: 12
            bottomMargin: 18
            leftMargin: 36
            rightMargin: 36
        }

        // Pencere küçüldüğünde kadranların ve yazıların birbirine girmemesi için
        // kokpit alanını orantılı olarak küçülten (`fitScale`) görünüm kutusu
        Item {
            id: cockpitViewport
            readonly property real fitScale: Math.min(1.0,
                                                      Math.max(0.5, cockpitMainArea.width / 1180.0),
                                                      Math.max(0.5, (cockpitMainArea.height - 20) / 310.0))
            width: cockpitMainArea.width / fitScale
            height: cockpitMainArea.height / fitScale
            scale: fitScale
            transformOrigin: Item.TopLeft

            // SOL BÖLGE: Hız kadranı, sürüş fazı adımları, canlı hız grafiği ve ivme barı
            LeftSpeedPanel {
                id: leftGaugeWing
                anchors {
                    left: parent.left
                    leftMargin: -animCtrl.wingSlideOffset
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Math.min(parent.width * 0.30, 356)

                displaySpeedKmh: animCtrl.displaySpeedKmh
                maxSpeedKmh: physicsSim.maxSpeedKmh
                gaugeMaxSpeed: physicsSim.gaugeMaxSpeed
                displayGForce: animCtrl.displayGForce
                gaugeMaxGForce: physicsSim.gaugeMaxGForce
                simAccelMs2: physicsSim.simAccelMs2
                phaseIndex: hudRoot.phaseIndex
                runState: physicsSim.runState
                speedHistory: physicsSim.speedHistory
                gForceHistory: physicsSim.gForceHistory
                historyRevision: physicsSim.historyRevision
            }

            // MERKEZ BÖLGE: 3B perspektif tünel halkaları, E-START/E-STOP ve sıcaklıklar
            CenterCommandPanel {
                id: centerZone
                anchors {
                    left: leftGaugeWing.right
                    right: rightGaugeWing.left
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 12
                    rightMargin: 12
                }
                scale: animCtrl.centerClusterScale

                runState: physicsSim.runState
                isSweeping: animCtrl.isSweeping
                linkOk: hudRoot.linkOk
                motorEnabled: hudRoot.motorEnabled
                simDistance: physicsSim.simDistance
                displaySpeedKmh: animCtrl.displaySpeedKmh
                litReflectors: hudRoot.litReflectors
                reflectorTotal: physicsSim.reflectorTotal
                logRateHz: physicsSim.logRateHz

                rollDeg: physicsSim.rollDeg
                pitchDeg: physicsSim.pitchDeg
                yawDeg: physicsSim.yawDeg

                displayMotorTempC: animCtrl.displayMotorTempC
                displayDriverTempC: animCtrl.displayDriverTempC
                railDeltaT: physicsSim.railDeltaT

                tunnelTravelPhase: animCtrl.tunnelTravelPhase
                tunnelLightWave: animCtrl.tunnelLightWave
                reticleSweepAngle: animCtrl.reticleSweepAngle
                liveOrbitAngle: animCtrl.liveOrbitAngle

                onEStartClicked: hudRoot.startCompetitionRun()
                onEStopClicked: hudRoot.triggerEmergencyStop()
                onResetTrackClicked: hudRoot.resetTrackPosition()
            }

            // SAĞ BÖLGE: LIM motor gücü kadranı, canlı güç grafiği, batarya ve fren/tank basıncı
            RightPowerPanel {
                id: rightGaugeWing
                anchors {
                    right: parent.right
                    rightMargin: -animCtrl.wingSlideOffset
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Math.min(parent.width * 0.30, 356)

                displayMotorPowerKw: animCtrl.displayMotorPowerKw
                maxMotorPowerKw: physicsSim.maxMotorPowerKw
                displayPowerPercent: hudRoot.displayPowerPercent
                peakPowerKw: physicsSim.peakPowerKw
                simCurrentA: physicsSim.simCurrentA
                simEnergyWh: physicsSim.simEnergyWh

                displayBatteryPercent: animCtrl.displayBatteryPercent
                displayPackVoltage: animCtrl.displayPackVoltage
                batteryTemp1: physicsSim.batteryTemp1
                batteryTemp2: physicsSim.batteryTemp2
                battAnimPhase: animCtrl.battAnimPhase

                displayBrakePercent: animCtrl.displayBrakePercent
                displayTankBar: animCtrl.displayTankBar

                powerHistory: physicsSim.powerHistory
                historyRevision: physicsSim.historyRevision
            }
        }
    }
}
