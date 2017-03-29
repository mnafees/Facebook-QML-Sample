#include "FacebookQMLiOS.h"

#include <QGuiApplication>
#include <qpa/qplatformnativeinterface.h>

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <FBSDKCoreKit/FBSDKCoreKit.h>
#include <FBSDKLoginKit/FBSDKLoginKit.h>
#include <FBSDKShareKit/FBSDKShareKit.h>

static FacebookQMLiOS* m_instance{nullptr};

@interface QIOSApplicationDelegate
@end

@interface QIOSApplicationDelegate (FacebookQMLiOSDelegate)
@end

@implementation QIOSApplicationDelegate (FacebookQMLiOSDelegate)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(_updateContent:)
                                          name:FBSDKProfileDidChangeNotification
                                          object:nil];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
        openURL:url
        sourceApplication:sourceApplication
        annotation:annotation
    ];

    return handled;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_updateContent:(NSNotification *)notification
{
    if ([FBSDKAccessToken currentAccessToken]) {
        emit FacebookQMLiOSInstance::instance()->loginSuccess();
    }
}

@end

@interface FBShareDelegate : NSObject<FBSDKSharingDelegate>
@end

@implementation FBShareDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    emit FacebookQMLiOSInstance::instance()->shareSuccess();
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSString *message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?:
    @"There was a problem sharing, please try again later.";

    emit FacebookQMLiOSInstance::instance()->shareError(QString::fromNSString(message));
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    emit FacebookQMLiOSInstance::instance()->shareCancel();
}

@end

NSArray *toNSArray(const QStringList &stringList)
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    foreach (const QString &string, stringList) {
        [array addObject : string.toNSString()];
    }
    return array;
}

FacebookQMLiOS::FacebookQMLiOS(QObject *parent) :
    QObject(parent)
{
    FacebookQMLiOSInstance::setInstance(this);
}

FacebookQMLiOS::~FacebookQMLiOS()
{
}

void FacebookQMLiOS::login()
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    login.loginBehavior = FBSDKLoginBehaviorNative;

    QPlatformNativeInterface* nativeInterface = QGuiApplication::platformNativeInterface();
    UIView *view = static_cast<UIView *>(nativeInterface->nativeResourceForWindow("uiview", qApp->topLevelWindows().at(0)));
    UIViewController *qtController = [[view window] rootViewController];

    [login logInWithReadPermissions:toNSArray(m_readPermissions)
        fromViewController:qtController
        handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            emit loginError(QString::fromNSString(error.localizedDescription));
        } else if (result.isCancelled) {
            emit loginCancel();
        }
    }];

    /*[login logInWithPublishPermissions:toNSArray(m_publishPermissions)
        fromViewController:qtController
        handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            emit loginError(QString::fromNSString(error.localizedDescription));
        } else if (result.isCancelled) {
            emit loginCancel();
        }

        emit loginSuccess();
    }];*/
}

void FacebookQMLiOS::logout()
{
    [[[FBSDKLoginManager alloc] init] logOut];
}

bool FacebookQMLiOS::isLoggedIn()
{
    if ([FBSDKAccessToken currentAccessToken]) {
        return true;
    } else {
        return false;
    }
}

void FacebookQMLiOS::share(const QString &title, const QString &text, const QString &url, const QString &imageUrl)
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:url.toNSString()];
    content.contentTitle = title.toNSString();
    content.imageURL = [NSURL URLWithString:imageUrl.toNSString()];
    content.contentDescription = text.toNSString();

    QPlatformNativeInterface* nativeInterface = QGuiApplication::platformNativeInterface();
    UIView *view = static_cast<UIView *>(nativeInterface->nativeResourceForWindow("uiview", qApp->topLevelWindows().at(0)));
    UIViewController *qtController = [[view window] rootViewController];

    FBShareDelegate *shareDelegate = [[FBShareDelegate alloc] init];
    [FBSDKShareDialog showFromViewController:qtController withContent:content delegate:shareDelegate];
}

QString FacebookQMLiOS::getProfileId()
{
    return QString::fromNSString([FBSDKProfile currentProfile].userID);
}

QString FacebookQMLiOS::getProfileName()
{
    return QString::fromNSString([FBSDKProfile currentProfile].name);
}

QString FacebookQMLiOS::getProfileLinkUri()
{
    return QString::fromNSString([FBSDKProfile currentProfile].linkURL.absoluteString);
}

QString FacebookQMLiOS::getProfilePictureUri(int width, int height)
{
    return QString::fromNSString([[FBSDKProfile currentProfile]
            imageURLForPictureMode:FBSDKProfilePictureModeNormal size:CGSizeMake(width, height)].absoluteString);
}

FacebookQMLiOS *FacebookQMLiOSInstance::instance()
{
    return m_instance;
}

void FacebookQMLiOSInstance::setInstance(FacebookQMLiOS *instance)
{
    m_instance = instance;
}
