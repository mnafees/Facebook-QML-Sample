#include "FacebookQMLiOS.h"

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <FBSDKCoreKit/FBSDKCoreKit.h>
#include <FBSDKShareKit/FBSDKShareKit.h>

static FacebookQMLiOS* m_instance{nullptr};

@interface QIOSApplicationDelegate
@end

@interface QIOSApplicationDelegate (FacebookQMLiOS)
@end

@implementation QIOSApplicationDelegate (FacebookQMLiOS)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

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

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    emit FacebookQMLiOSInstance::instance()->onShareSuccess();
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSString *message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?:
    @"There was a problem sharing, please try again later.";

    emit FacebookQMLiOSInstance::instance()->onShareError(QString::fromNSString(message));
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    emit FacebookQMLiOSInstance::instance()->onShareCancel();
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

FacebookQMLiOS::FacebookQMLiOS(QObject *parent)
{
    FacebookQMLiOSInstance::setInstance(this);
}

FacebookQMLiOS::~FacebookQMLiOS()
{
}

void FacebookQMLiOS::login()
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];

    [login logInWithPublishPermissions:@[toNSArray(m_publishPermissions)]
        handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            emit onLoginError(QString::fromNSString(error.localizedDescription));
        } else if (result.isCancelled) {
            emit onLoginCancel();
        }

        [login logInWithReadPermissions:@[toNSArray(m_readPermissions)]
            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                emit onLoginError(QString::fromNSString(error.localizedDescription));
            } else if (result.isCancelled) {
                emit onLoginCancel();
            }

            emit onLoginSuccess();
        }];

        }
    ];
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
    [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
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
            imageURLForPictureMode:size:CGMake(width, height)].absoluteString);
}

FacebookQMLiOS *FacebookQMLiOSInstance::instance()
{
    return m_instance;
}

void FacebookQMLiOSInstance::setInstance(FacebookQMLiOS *instance)
{
    m_instance = instance;
}
