cmake_minimum_required(VERSION 3.16)

project(ParsHyperloop VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS
    Quick
    Quick3D
)

qt_standard_project_setup(REQUIRES 6.8)

# 1. Singleton ve Kaynak Yolu (Alias) Tanımları
# Colors.qml'i tekil nesne yapıp kök dizine bağlar
set_source_files_properties(ui/Colors.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
    QT_RESOURCE_ALIAS "Colors.qml"
)

# Main.qml'in modül kökünden doğrudan çağrılabilmesi için
set_source_files_properties(ui/Main.qml PROPERTIES
    QT_RESOURCE_ALIAS "Main.qml"
)

# 3D modelin bağıl yolunu güvenceye alır
set_source_files_properties(assets/hyperloop3d.glb PROPERTIES
    QT_RESOURCE_ALIAS "assets/hyperloop3d.glb"
)

# Bileşenler ve sayfaların import "components" ve import "views" ile eşleşmesi için:
set_source_files_properties(ui/components/BottomNavBar.qml PROPERTIES
    QT_RESOURCE_ALIAS "components/BottomNavBar.qml"
)
set_source_files_properties(ui/views/OverviewView.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/OverviewView.qml"
)
set_source_files_properties(ui/views/BatteryView.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/BatteryView.qml"
)
set_source_files_properties(ui/views/BrakeView.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/BrakeView.qml"
)
set_source_files_properties(ui/views/CommView.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/CommView.qml"
)
set_source_files_properties(ui/views/AnalyticsView.qml PROPERTIES
    QT_RESOURCE_ALIAS "views/AnalyticsView.qml"
)

# 2. Yürütülebilir Dosya
qt_add_executable(HyperPars
    src/main.cpp
)

# 3. QML Modülü, Ekranlar ve Kaynaklar
qt_add_qml_module(HyperPars
    URI ParsHyperloop
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml/"
    QML_FILES
        ui/Main.qml
        ui/Colors.qml
        ui/components/BottomNavBar.qml
        ui/views/OverviewView.qml
        ui/views/BatteryView.qml
        ui/views/BrakeView.qml
        ui/views/CommView.qml
        ui/views/AnalyticsView.qml
    RESOURCES
        assets/hyperloop3d.glb
        assets/teampars.png
        assets/ikculogo.png


        assets/fonts/Satoshi-Regular.otf
        assets/fonts/Satoshi-Medium.otf
        assets/fonts/Satoshi-Bold.otf
        QML_FILES
        QML_FILES ui/components/ModeSelector.qml
        QML_FILES ui/components/OverviewBottomSection.qml
        QML_FILES ui/components/QuickStatusIndicators.qml
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
