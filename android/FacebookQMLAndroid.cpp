#include "FacebookQMLAndroid.h"
#include "AndroidGlobals.h"

#include <QAndroidJniEnvironment>
#include <QtDebug>

static FacebookQMLAndroid* m_instance{nullptr};

FacebookQMLAndroid::FacebookQMLAndroid(QObject *parent) :
    QObject(parent)
{
    FacebookQMLAndroidInstance::setInstance(this);
}

FacebookQMLAndroid::~FacebookQMLAndroid()
{
}

static jobjectArray createJavaStringArray(QAndroidJniEnvironment &env, const QStringList &stringList)
{
    jclass stringClass = env->FindClass("java/lang/String");

    if (!stringClass) {
        qWarning() << "Can not get string class";
        return nullptr;
    }

    jobjectArray stringArray = env->NewObjectArray(stringList.size(), stringClass, nullptr);

    for (int i = 0; i < stringList.size(); ++i) {
        env->SetObjectArrayElement(stringArray,
                                   i,
                                   QAndroidJniObject::fromString(stringList.at(i))
                                   .object<jstring>());
    }

    return stringArray;
}

void FacebookQMLAndroid::login()
{
    QAndroidJniEnvironment env;
    QAndroidJniObject::callStaticMethod<void>(QString(javaPackage + "FacebookQMLHelperActivity").toUtf8().data(),
                                              "login", "([Ljava/lang/String;[Ljava/lang/String;)V",
                                              createJavaStringArray(env, m_readPermissions),
                                              createJavaStringArray(env, m_publishPermissions));
}

void FacebookQMLAndroid::logout()
{
    QAndroidJniObject::callStaticMethod<void>(QString(javaPackage + "FacebookQMLHelperActivity").toUtf8().data(),
                                              "logout", "()V");
}

bool FacebookQMLAndroid::isLoggedIn()
{
    return QAndroidJniObject::callStaticMethod<jboolean>(QString(javaPackage + "FacebookQMLHelperActivity").toUtf8().data(),
                                                         "isLoggedIn", "()Z");
}

void FacebookQMLAndroid::share(const QString &title, const QString &text, const QString &url, const QString &imageUrl)
{
    QAndroidJniObject::callStaticMethod<void>(QString(javaPackage + "FacebookQMLHelperActivity").toUtf8().data(), "share",
                                              "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                              QAndroidJniObject::fromString(text).object<jstring>(),
                                              QAndroidJniObject::fromString(imageUrl).object<jstring>(),
                                              QAndroidJniObject::fromString(url).object<jstring>(),
                                              QAndroidJniObject::fromString(title).object<jstring>());
}

QString FacebookQMLAndroid::getProfileId()
{
    const QAndroidJniObject id = QAndroidJniObject::callStaticObjectMethod(QString(javaPackage + "FacebookQMLHelperActivity")
                                                                           .toUtf8().data(),
                                                                           "getProfileId",
                                                                           "()Ljava/lang/String;");
    return id.toString();
}

QString FacebookQMLAndroid::getProfileName()
{
    const QAndroidJniObject name = QAndroidJniObject::callStaticObjectMethod(QString(javaPackage + "FacebookQMLHelperActivity")
                                                                             .toUtf8().data(), "getProfileName",
                                                                             "()Ljava/lang/String;");
    return name.toString();
}

QString FacebookQMLAndroid::getProfileLinkUri()
{
    const QAndroidJniObject uri = QAndroidJniObject::callStaticObjectMethod(QString(javaPackage + "FacebookQMLHelperActivity")
                                                                            .toUtf8().data(), "getProfileLinkUri",
                                                                            "()Ljava/lang/String;");
    return uri.toString();
}

QString FacebookQMLAndroid::getProfilePictureUri(int width, int height)
{
    const QAndroidJniObject uri = QAndroidJniObject::callStaticObjectMethod(QString(javaPackage + "FacebookQMLHelperActivity")
                                                                            .toUtf8().data(), "getProfilePictureUri",
                                                                            "(II)Ljava/lang/String;",
                                                                            width, height);
    return uri.toString();
}

static void onLoginSuccess(JNIEnv */*env*/, jobject /*obj*/);
static void onLoginCancel(JNIEnv */*env*/, jobject /*obj*/);
static void onLoginError(JNIEnv */*env*/, jobject /*obj*/, jstring error);
static void onShareSuccess(JNIEnv */*env*/, jobject /*obj*/);
static void onShareCancel(JNIEnv */*env*/, jobject /*obj*/);
static void onShareError(JNIEnv */*env*/, jobject /*obj*/, jstring error);

static JNINativeMethod methods[] = {
    {
        "onLoginSuccess",
        "()V",
        (void*)onLoginSuccess
    },
    {
        "onLoginCancel",
        "()V",
        (void*)onLoginCancel
    },
    {
        "onLoginError",
        "(Ljava/lang/String;)V",
        (void*)onLoginError
    },
    {
        "onShareSuccess",
        "()V",
        (void*)onShareSuccess
    },
    {
        "onShareCancel",
        "()V",
        (void*)onShareCancel
    },
    {
        "onShareError",
        "(Ljava/lang/String;)V",
        (void*)onShareError
    }
};

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* /*reserved*/)
{
    JNIEnv* env;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    jclass callbackClass = env->FindClass(QString(javaPackage + "FacebookQMLCallbacks").toUtf8().data());
    if (!callbackClass) {
        return JNI_ERR;
    }

    if (env->RegisterNatives(callbackClass, methods, sizeof(methods) / sizeof(methods[0])) < 0) {
        return JNI_ERR;
    }

    return JNI_VERSION_1_6;
}

static void onLoginSuccess(JNIEnv */*env*/, jobject /*obj*/)
{
    emit FacebookQMLAndroidInstance::instance()->loginSuccess();
}

static void onLoginCancel(JNIEnv */*env*/, jobject /*obj*/)
{
    emit FacebookQMLAndroidInstance::instance()->loginCancel();
}

static void onLoginError(JNIEnv */*env*/, jobject /*obj*/, jstring error)
{
    const QAndroidJniObject qserror(error);
    emit FacebookQMLAndroidInstance::instance()->loginError(qserror.toString());
}

static void onShareSuccess(JNIEnv */*env*/, jobject /*obj*/)
{
    emit FacebookQMLAndroidInstance::instance()->shareSuccess();
}

static void onShareCancel(JNIEnv */*env*/, jobject /*obj*/)
{
    emit FacebookQMLAndroidInstance::instance()->shareCancel();
}

static void onShareError(JNIEnv */*env*/, jobject /*obj*/, jstring error)
{
    const QAndroidJniObject qserror(error);
    emit FacebookQMLAndroidInstance::instance()->shareError(qserror.toString());
}

FacebookQMLAndroid *FacebookQMLAndroidInstance::instance()
{
    return m_instance;
}

void FacebookQMLAndroidInstance::setInstance(FacebookQMLAndroid *instance)
{
    m_instance = instance;
}
