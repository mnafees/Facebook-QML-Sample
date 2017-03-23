TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

android {
    QT += androidextras
    SOURCES += android/FacebookQMLAndroid.cpp
    HEADERS += android/FacebookQMLAndroid.h \
        android/AndroidGlobals.h
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android/project
    OTHER_FILES += android/project/AndroidManifest.xml
}

ios {
    QT += gui-private
    CONFIG -= bitcode
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
    OBJECTIVE_SOURCES += ios/FacebookQMLiOS.mm
    HEADERS += ios/FacebookQMLiOS.h
    LIBS += -F$$PWD/ios/FBSDK -framework FBSDKCoreKit -framework FBSDKShareKit -framework Foundation
    LIBS += -framework Bolts -framework FBSDKLoginKit -framework CoreGraphics -lz -framework UIKit
}

DISTFILES += \
    android/project/AndroidManifest.xml \
    android/project/gradle/wrapper/gradle-wrapper.jar \
    android/project/gradlew \
    android/project/res/values/libs.xml \
    android/project/build.gradle \
    android/project/gradle/wrapper/gradle-wrapper.properties \
    android/project/gradlew.bat \
    android/project/src/me/mnafees/FacebookQMLSample/FacebookQMLHelperActivity.java
