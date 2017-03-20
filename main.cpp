#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>

#if defined(Q_OS_ANDROID)
#include "android/FacebookQMLAndroid.h"
#elif defined(Q_OS_IOS)
#include "ios/FacebookQMLiOS.h"
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
#if defined(Q_OS_ANDROID)
    qmlRegisterType<FacebookQMLAndroid>("me.mnafees", 1, 0, "Facebook");
#elif defined(Q_OS_IOS)
    qmlRegisterType<FacebookQMLiOS>("me.mnafees", 1, 0, "Facebook");
#endif
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
