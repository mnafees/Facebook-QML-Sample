#ifndef FacebookQMLAndroid_h
#define FacebookQMLAndroid_h

#include <QObject>
#include <QStringList>
#include <QtAndroid>

class FacebookQMLAndroid : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList readPermissions MEMBER m_readPermissions)
    Q_PROPERTY(QStringList publishPermissions MEMBER m_publishPermissions)

public:
    explicit FacebookQMLAndroid(QObject *parent = 0);
    ~FacebookQMLAndroid();

    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool isLoggedIn();
    Q_INVOKABLE void share(const QString& title, const QString& text, const QString& url, const QString& imageUrl);
    Q_INVOKABLE QString getProfileId();
    Q_INVOKABLE QString getProfileName();
    Q_INVOKABLE QString getProfileLinkUri();
    Q_INVOKABLE QString getProfilePictureUri(int width, int height);

signals:
    void loginSuccess();
    void loginCancel();
    void loginError(QString error);
    void shareSuccess();
    void shareCancel();
    void shareError(QString error);

private:
    QStringList m_readPermissions;
    QStringList m_publishPermissions;
};

class FacebookQMLAndroidInstance {
public:
    static FacebookQMLAndroid* instance();
    static void setInstance(FacebookQMLAndroid* instance);
};

#endif // FacebookQMLAndroid_h
