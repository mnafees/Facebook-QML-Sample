#ifndef FacebookQMLiOS_h
#define FacebookQMLiOS_h

#include <QObject>

class FacebookQMLiOS : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList readPermissions MEMBER m_readPermissions)
    Q_PROPERTY(QStringList publishPermissions MEMBER m_publishPermissions)

public:
    explicit FacebookQMLiOS(QObject *parent = 0);
    ~FacebookQMLiOS();

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

class FacebookQMLiOSInstance {
public:
    static FacebookQMLiOS *instance();
    static void setInstance(FacebookQMLiOS* instance);
};

#endif // FacebookQMLiOS_h
