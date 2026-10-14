#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QFontDatabase>
#include <QFont>
#include <QDebug>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 1. Satoshi fontlarını qrc kaynaklarından belleğe yükle
    const QStringList fontPaths = {
        QStringLiteral(":/qt/qml/ParsHyperloop/assets/fonts/Satoshi-Regular.otf"),
        QStringLiteral(":/qt/qml/ParsHyperloop/assets/fonts/Satoshi-Medium.otf"),
        QStringLiteral(":/qt/qml/ParsHyperloop/assets/fonts/Satoshi-Bold.otf")
    };

    for (const QString &fontPath : fontPaths) {
        int fontId = QFontDatabase::addApplicationFont(fontPath);
        if (fontId == -1) {
            qWarning() << "Font yuklenemedi:" << fontPath;
        }
    }

    // 2. Satoshi'yi tüm uygulamanın varsayılan fontu yap
    QFont appFont(QStringLiteral("Satoshi"));
    appFont.setStyleStrategy(QFont::PreferAntialias); // Kenar yumuşatma (antialiasing)
    app.setFont(appFont);

    QQmlApplicationEngine engine;

    // 3. Qt 6.8 modern modül yükleme ve hata yakalama yapısı
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
        );

    // QML modülü üzerinden Main.qml'i başlat
    engine.loadFromModule("ParsHyperloop", "Main");

    return app.exec();
}
