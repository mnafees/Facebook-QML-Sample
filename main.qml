import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

import me.mnafees 1.0

Window {
    visible: true
    width: 300
    height: 300

    Facebook {
        id: facebook
        readPermissions: ["public_profile", "email", "user_friends"]
        publishPermissions: ["publish_actions"]

        // Callbacks
        onLoginSuccess: {
            showUserInfo()
            shareButton.visible = true
            loginButton.text = "Logout"
            console.log("Login successful")
        }
        onLoginError: {
            console.log("Login error")
        }
        onLoginCancel: {
            console.log("Login canceled")
        }
        onShareSuccess: {
            console.log("Share successful")
        }
        onShareError: {
            console.log("Share error")
        }
        onShareCancel: {
            console.log("Share canceled")
        }
    }

    Button {
        id: shareButton
        anchors.bottom: loginButton.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Share on Facebook"
        visible: false

        onClicked: {
            if (facebook.isLoggedIn()) {
                facebook.share("Test", "Test", "https://github.com/mnafees", facebook.getProfilePictureUri(200, 200))
            }
        }
    }

    Button {
        id: loginButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: "Login with Facebook"

        onClicked: {
            if (facebook.isLoggedIn()) {
                facebook.logout()
                shareButton.visible = false
                loginButton.text = "Login with Facebook"
            } else {
                facebook.login()
            }
            /**
              * Other valid method calls
              *
              * facebook.share("title", "text", "url", "imageUrl")
              * facebook.getProfileId()
              * facebook.getProfileLinkUri()
              * facebook.getProfileName()
              * facebook.getProfilePictureUri(200, 200) */
        }
    }

    function showUserInfo() {
        console.log(facebook.getProfileId())
        console.log(facebook.getProfileLinkUri())
        console.log(facebook.getProfileName())
        console.log(facebook.getProfilePictureUri(200, 200))
    }

    Component.onCompleted: {
        if (facebook.isLoggedIn()) {
            shareButton.visible = true
            loginButton.text = "Logout"
            showUserInfo()
        }
    }
}
