cmake_minimum_required(VERSION 3.16)

project(ParsHyperloop VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS
    Quick
    Quick3D
)

qt_standard_project_setup(REQUIRES 6.8)

# -----------------------------------------------------------------------------
# 1. KAYNAK YOLLARI (QT_RESOURCE_ALIAS) VE SINGLETON TANIMLARI
# Main.qml'den içeri doğru ilerleyen sayfa odaklı klasör yapısını (shell,
# views/overview, views/safety, views/battery, views/brake, views/communication)
# QML import yollarıyla birebir eşleştiriyoruz.
# -----------------------------------------------------------------------------

# Colors.qml'i tüm dosyalardan doğrudan erişilebilen Singleton yapar
set_source_files_properties(ui/Colors.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
    QT_RESOURCE_ALIAS "Colors.qml"
)

# Ana pencere (Main.qml)
set_source_files_properties(ui/Main.qml PROPERTIES
    QT_RESOURCE_ALIAS "Main.qml"
)

# 3B kapsül modeli
set_source_files_properties(assets/hyperloop3d.glb PROPERTIES
    QT_RESOURCE_ALIAS "assets/hyperloop3d.glb"
)

# --- Ana Pencere Sabit Kabuk Bileşenleri (ui/shell) ---
set_source_files_properties(ui/shell/TopControlBar.qml PROPERTIES
    QT_RESOURCE_ALIAS "shell/TopControlBar.qml"
)
set_source_files_properties(ui/shell/NotificationLogPanel.qml PROPERTIES
    QT_RESOURCE_ALIAS "shell/NotificationLogPanel.qml"
)
set_source_files_properties(ui/shell/BottomNavigationBar.qml PROPERTIES
    QT_RESOURCE_ALIAS "shell/BottomNavigationBar.qml"
)

# --- 1. Sayfa: Genel Bakış (ui/views/overview) ---
set_source_files_properties(ui/views/overview/OverviewPage.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/OverviewPage.qml"
)
set_source_files_properties(ui/views/overview/OverviewModeSwitch.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/OverviewModeSwitch.qml"
)
set_source_files_properties(ui/views/overview/OverviewDetailSection.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/OverviewDetailSection.qml"
)

# Genel Bakış -> 3B Kapsül ve X-Ray İnceleme Sahnesi (ui/views/overview/pod3d)
set_source_files_properties(ui/views/overview/pod3d/Pod3DInspectionScene.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/pod3d/Pod3DInspectionScene.qml"
)

# Genel Bakış -> Yarışma Kokpiti ve Alt Parçaları (ui/views/overview/cockpit)
set_source_files_properties(ui/views/overview/cockpit/CompetitionCockpit.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/CompetitionCockpit.qml"
)
set_source_files_properties(ui/views/overview/cockpit/CockpitPhysicsEngine.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/CockpitPhysicsEngine.qml"
)
set_source_files_properties(ui/views/overview/cockpit/CockpitSweepAnimator.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/CockpitSweepAnimator.qml"
)
set_source_files_properties(ui/views/overview/cockpit/CockpitBorderFrame.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/CockpitBorderFrame.qml"
)
set_source_files_properties(ui/views/overview/cockpit/TunnelProgressMap.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/TunnelProgressMap.qml"
)
set_source_files_properties(ui/views/overview/cockpit/LeftSpeedPanel.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/LeftSpeedPanel.qml"
)
set_source_files_properties(ui/views/overview/cockpit/CenterCommandPanel.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/CenterCommandPanel.qml"
)
set_source_files_properties(ui/views/overview/cockpit/RightPowerPanel.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/RightPowerPanel.qml"
)
set_source_files_properties(ui/views/overview/cockpit/Tunnel3DRingsCanvas.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/Tunnel3DRingsCanvas.qml"
)
set_source_files_properties(ui/views/overview/cockpit/BatteryCellsCanvas.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/BatteryCellsCanvas.qml"
)
set_source_files_properties(ui/views/overview/cockpit/OscilloscopeGraph.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/overview/cockpit/OscilloscopeGraph.qml"
)

# --- 2. Sayfa: Güvenlik (ui/views/safety) ---
set_source_files_properties(ui/views/safety/SafetyPage.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/safety/SafetyPage.qml"
)

# --- 3. Sayfa: Batarya (ui/views/battery) ---
set_source_files_properties(ui/views/battery/BatteryPage.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/battery/BatteryPage.qml"
)

# --- 4. Sayfa: Fren (ui/views/brake) ---
set_source_files_properties(ui/views/brake/BrakePage.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/brake/BrakePage.qml"
)

# --- 5. Sayfa: Haberleşme (ui/views/communication) ---
set_source_files_properties(ui/views/communication/CommunicationPage.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/communication/CommunicationPage.qml"
)

# -----------------------------------------------------------------------------
# 2. YÜRÜTÜLEBİLİR HEDEF
# -----------------------------------------------------------------------------
qt_add_executable(HyperPars
    src/main.cpp
)

# -----------------------------------------------------------------------------
# 3. QML MODÜLÜ VE KAYNAK LİSTESİ
# -----------------------------------------------------------------------------
qt_add_qml_module(HyperPars
    URI ParsHyperloop
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml/"
    QML_FILES
        ui/Main.qml
        ui/Colors.qml
        # Sabit Kabuk Bileşenleri
        ui/shell/TopControlBar.qml
        ui/shell/NotificationLogPanel.qml
        ui/shell/BottomNavigationBar.qml
        # 1. Sayfa: Genel Bakış ve Alt Modülleri
        ui/views/overview/OverviewPage.qml
        ui/views/overview/OverviewModeSwitch.qml
        ui/views/overview/OverviewDetailSection.qml
        ui/views/overview/pod3d/Pod3DInspectionScene.qml
        ui/views/overview/cockpit/CompetitionCockpit.qml
        ui/views/overview/cockpit/CockpitPhysicsEngine.qml
        ui/views/overview/cockpit/CockpitSweepAnimator.qml
        ui/views/overview/cockpit/CockpitBorderFrame.qml
        ui/views/overview/cockpit/TunnelProgressMap.qml
        ui/views/overview/cockpit/LeftSpeedPanel.qml
        ui/views/overview/cockpit/CenterCommandPanel.qml
        ui/views/overview/cockpit/RightPowerPanel.qml
        ui/views/overview/cockpit/Tunnel3DRingsCanvas.qml
        ui/views/overview/cockpit/BatteryCellsCanvas.qml
        ui/views/overview/cockpit/OscilloscopeGraph.qml
        # Diğer 4 Ana Sayfa
        ui/views/safety/SafetyPage.qml
        ui/views/battery/BatteryPage.qml
        ui/views/brake/BrakePage.qml
        ui/views/communication/CommunicationPage.qml
    RESOURCES
        assets/hyperloop3d.glb
        assets/teampars.png
        assets/ikculogo.png
        assets/fonts/Satoshi-Regular.otf
        assets/fonts/Satoshi-Medium.otf
        assets/fonts/Satoshi-Bold.otf
        .gitignore
)

target_link_libraries(HyperPars
    PRIVATE
        Qt6::Quick
        Qt6::Quick3D
)

set_target_properties(HyperPars PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
    MACOSX_BUNDLE_SHORT_VERSION_STRING
        "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}"
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)

install(TARGETS HyperPars
    BUNDLE DESTINATION .
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)
