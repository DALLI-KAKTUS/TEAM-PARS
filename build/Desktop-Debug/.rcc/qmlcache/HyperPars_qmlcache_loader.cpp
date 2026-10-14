#include <QtQml/qqmlprivate.h>
#include <QtCore/qdir.h>
#include <QtCore/qurl.h>
#include <QtCore/qhash.h>
#include <QtCore/qstring.h>

namespace QmlCacheGeneratedCode {
namespace _qt_qml_ParsHyperloop_Main_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_Colors_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_components_BottomNavBar_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_views_OverviewView_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_views_BatteryView_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_views_BrakeView_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_views_CommView_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_views_AnalyticsView_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_ui_components_ModeSelector_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_ui_components_OverviewBottomSection_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_ParsHyperloop_ui_components_QuickStatusIndicators_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}

}
namespace {
struct Registry {
    Registry();
    ~Registry();
    QHash<QString, const QQmlPrivate::CachedQmlUnit*> resourcePathToCachedUnit;
    static const QQmlPrivate::CachedQmlUnit *lookupCachedUnit(const QUrl &url);
};

Q_GLOBAL_STATIC(Registry, unitRegistry)


Registry::Registry() {
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/Main.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_Main_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/Colors.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_Colors_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/components/BottomNavBar.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_components_BottomNavBar_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/views/OverviewView.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_views_OverviewView_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/views/BatteryView.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_views_BatteryView_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/views/BrakeView.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_views_BrakeView_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/views/CommView.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_views_CommView_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/views/AnalyticsView.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_views_AnalyticsView_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/ui/components/ModeSelector.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_ui_components_ModeSelector_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/ui/components/OverviewBottomSection.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_ui_components_OverviewBottomSection_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/ParsHyperloop/ui/components/QuickStatusIndicators.qml"), &QmlCacheGeneratedCode::_qt_qml_ParsHyperloop_ui_components_QuickStatusIndicators_qml::unit);
    QQmlPrivate::RegisterQmlUnitCacheHook registration;
    registration.structVersion = 0;
    registration.lookupCachedQmlUnit = &lookupCachedUnit;
    QQmlPrivate::qmlregister(QQmlPrivate::QmlUnitCacheHookRegistration, &registration);
}

Registry::~Registry() {
    QQmlPrivate::qmlunregister(QQmlPrivate::QmlUnitCacheHookRegistration, quintptr(&lookupCachedUnit));
}

const QQmlPrivate::CachedQmlUnit *Registry::lookupCachedUnit(const QUrl &url) {
    if (url.scheme() != QLatin1String("qrc"))
        return nullptr;
    QString resourcePath = QDir::cleanPath(url.path());
    if (resourcePath.isEmpty())
        return nullptr;
    if (!resourcePath.startsWith(QLatin1Char('/')))
        resourcePath.prepend(QLatin1Char('/'));
    return unitRegistry()->resourcePathToCachedUnit.value(resourcePath, nullptr);
}
}
int QT_MANGLE_NAMESPACE(qInitResources_qmlcache_HyperPars)() {
    ::unitRegistry();
    return 1;
}
Q_CONSTRUCTOR_FUNCTION(QT_MANGLE_NAMESPACE(qInitResources_qmlcache_HyperPars))
int QT_MANGLE_NAMESPACE(qCleanupResources_qmlcache_HyperPars)() {
    return 1;
}
