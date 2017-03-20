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
        id: button
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        style: ButtonStyle {
            background: Rectangle {
                color: "#3b5998"
            }
            label: Text {
                color: "white"
                text: qsTr("Login with Facebook")
            }
            padding.bottom: 30
            padding.top: 30
            padding.left: 30
            padding.right: 30
        }

        onClicked: {
            if (facebook.isLoggedIn()) {
                facebook.logout()
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
            showUserInfo()
        }
    }
}
