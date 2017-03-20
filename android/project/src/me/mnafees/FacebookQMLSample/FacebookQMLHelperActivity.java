package me.mnafees.FacebookQMLSample;

import java.util.Arrays;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import com.facebook.FacebookSdk;
import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.Profile;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;

import org.qtproject.qt5.android.bindings.QtActivity;

public class FacebookQMLHelperActivity extends QtActivity {

    private static String TAG = "FacebookQMLHelperActivity";
    private static FacebookQMLHelperActivity mInstance = null;

    private CallbackManager mCallbackManager;
    private ShareDialog mShareDialog;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(this);

        mInstance = this;
        mCallbackManager = CallbackManager.Factory.create();
        mShareDialog = new ShareDialog(this);
        mShareDialog.registerCallback(mCallbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result) {
                FacebookQMLCallbacks.onShareSuccess();
            }

            @Override
            public void onCancel() {
                FacebookQMLCallbacks.onShareCancel();
            }

            @Override
            public void onError(FacebookException error) {
                FacebookQMLCallbacks.onShareError(error.getMessage());
            }
        });
        LoginManager.getInstance().registerCallback(mCallbackManager, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(LoginResult loginResult) {
                AccessToken.setCurrentAccessToken(loginResult.getAccessToken());
                Profile.fetchProfileForCurrentAccessToken();
                FacebookQMLCallbacks.onLoginSuccess();
            }

            @Override
            public void onCancel() {
                FacebookQMLCallbacks.onLoginCancel();
            }

            @Override
            public void onError(FacebookException error) {
                FacebookQMLCallbacks.onLoginError(error.getMessage());
            }
        });

    }

    public static void login(String[] readPermissions, String[] publishPermissions) {
        LoginManager.getInstance().logInWithReadPermissions(mInstance, Arrays.asList(readPermissions));
        LoginManager.getInstance().logInWithPublishPermissions(mInstance, Arrays.asList(publishPermissions));
    }

    public static void logout() {
        LoginManager.getInstance().logOut();
    }

    public static boolean isLoggedIn() {
        return AccessToken.getCurrentAccessToken() != null;
    }

    public static String getProfileId() {
        return Profile.getCurrentProfile().getId();
    }

    public static String getProfileName() {
        return Profile.getCurrentProfile().getName();
    }

    public static String getProfileLinkUri() {
        return Profile.getCurrentProfile().getLinkUri().toString();
    }

    public static String getProfilePictureUri(int width, int height) {
        return Profile.getCurrentProfile().getProfilePictureUri(width, height).toString();
    }

    public static void share(String text, String imageUrl, String url, String title) {
        ShareLinkContent content = new ShareLinkContent.Builder()
                .setContentUrl(Uri.parse(url))
                .setContentTitle(title)
                .setContentDescription(text)
                .setImageUrl(Uri.parse(imageUrl))
                .build();
        mInstance.mShareDialog.show(content);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        mCallbackManager.onActivityResult(requestCode, resultCode, data);
    }

}

class FacebookQMLCallbacks {

    public static native void onLoginSuccess();

    public static native void onLoginCancel();

    public static native void onLoginError(String error);

    public static native void onShareSuccess();

    public static native void onShareCancel();

    public static native void onShareError(String error);

}
