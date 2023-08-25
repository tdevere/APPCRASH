
package com.facebook.react;

import android.app.Application;
import android.content.Context;
import android.content.res.Resources;

import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainPackageConfig;
import com.facebook.react.shell.MainReactPackage;
import java.util.Arrays;
import java.util.ArrayList;

// @react-native-async-storage/async-storage
import com.reactnativecommunity.asyncstorage.AsyncStoragePackage;
// @react-native-community/slider
import com.reactnativecommunity.slider.ReactSliderPackage;
// @react-native-community/datetimepicker
import com.reactcommunity.rndatetimepicker.RNDateTimePickerPackage;
// @react-native-community/netinfo
import com.reactnativecommunity.netinfo.NetInfoPackage;
// @sentry/react-native
import io.sentry.react.RNSentryPackage;
// appcenter
import com.microsoft.appcenter.reactnative.appcenter.AppCenterReactNativePackage;
// appcenter-analytics
import com.microsoft.appcenter.reactnative.analytics.AppCenterReactNativeAnalyticsPackage;
// appcenter-crashes
import com.microsoft.appcenter.reactnative.crashes.AppCenterReactNativeCrashesPackage;
// cmbsdk-react-native
import com.cmb.RCTCmbSdkPackage;
// react-native-appstore-version-checker
import com.masteratul.RNAppstoreVersionCheckerPackage;
// react-native-camera
import org.reactnative.camera.RNCameraPackage;
// react-native-check-app-install
import com.rpt.reactnativecheckpackageinstallation.CheckPackageInstallationPackage;
// react-native-code-push
import com.microsoft.codepush.react.CodePush;
// react-native-cookies
import com.psykar.cookiemanager.CookieManagerPackage;
// react-native-device-info
import com.learnium.RNDeviceInfo.RNDeviceInfo;
// react-native-fs
import com.rnfs.RNFSPackage;
// react-native-image-crop-picker
import com.reactnative.ivpusic.imagepicker.PickerPackage;
// react-native-keep-awake
import com.corbt.keepawake.KCKeepAwakePackage;
// react-native-local-notifications
import com.github.wumke.RNLocalNotifications.RNLocalNotificationsPackage;
// react-native-pdf
import org.wonday.pdf.RCTPdfView;
// react-native-permissions
import com.reactnativecommunity.rnpermissions.RNPermissionsPackage;
// react-native-push-notification
import com.dieam.reactnativepushnotification.ReactNativePushNotificationPackage;
// react-native-sensitive-info
import br.com.classapp.RNSensitiveInfo.RNSensitiveInfoPackage;
// react-native-signature-capture
import com.rssignaturecapture.RSSignatureCapturePackage;
// react-native-sound-player
import com.johnsonsu.rnsoundplayer.RNSoundPlayerPackage;
// react-native-spinkit
import com.react.rnspinkit.RNSpinkitPackage;
// react-native-sqlite-storage
import org.pgsqlite.SQLitePluginPackage;
// react-native-uuid-generator
import io.github.traviskn.rnuuidgenerator.RNUUIDGeneratorPackage;
// react-native-video
import com.brentvatne.react.ReactVideoPackage;
// react-native-webview
import com.reactnativecommunity.webview.RNCWebViewPackage;
// react-native-torch
import com.cubicphuse.RCTTorch.RCTTorchPackage;
// react-native-zip-archive
import com.rnziparchive.RNZipArchivePackage;
// react-native-shared-group-preferences
import com.poppop.RNReactNativeSharedGroupPreferences.RNReactNativeSharedGroupPreferencesPackage;
// rn-fetch-blob
import com.RNFetchBlob.RNFetchBlobPackage;
// scandit-react-native
import com.scandit.reactnative.ScanditPackage;

public class PackageList {
  private Application application;
  private ReactNativeHost reactNativeHost;
  private MainPackageConfig mConfig;

  public PackageList(ReactNativeHost reactNativeHost) {
    this(reactNativeHost, null);
  }

  public PackageList(Application application) {
    this(application, null);
  }

  public PackageList(ReactNativeHost reactNativeHost, MainPackageConfig config) {
    this.reactNativeHost = reactNativeHost;
    mConfig = config;
  }

  public PackageList(Application application, MainPackageConfig config) {
    this.reactNativeHost = null;
    this.application = application;
    mConfig = config;
  }

  private ReactNativeHost getReactNativeHost() {
    return this.reactNativeHost;
  }

  private Resources getResources() {
    return this.getApplication().getResources();
  }

  private Application getApplication() {
    if (this.reactNativeHost == null) return this.application;
    return this.reactNativeHost.getApplication();
  }

  private Context getApplicationContext() {
    return this.getApplication().getApplicationContext();
  }

  public ArrayList<ReactPackage> getPackages() {
    return new ArrayList<>(Arrays.<ReactPackage>asList(
      new MainReactPackage(mConfig),
      new AsyncStoragePackage(),
      new ReactSliderPackage(),
      new RNDateTimePickerPackage(),
      new NetInfoPackage(),
      new RNSentryPackage(),
      new AppCenterReactNativePackage(getApplication()),
      new AppCenterReactNativeAnalyticsPackage(getApplication(), getResources().getString(com.InnovaZones.RNTreeIZHips.R.string.appCenterAnalytics_whenToEnableAnalytics)),
      new AppCenterReactNativeCrashesPackage(getApplication(), getResources().getString(com.InnovaZones.RNTreeIZHips.R.string.appCenterCrashes_whenToSendCrashes)),
      new RCTCmbSdkPackage(),
      new RNAppstoreVersionCheckerPackage(),
      new RNCameraPackage(),
      new CheckPackageInstallationPackage(),
      new CodePush(getResources().getString(com.InnovaZones.RNTreeIZHips.R.string.CodePushDeploymentKey), getApplicationContext(), com.InnovaZones.RNTreeIZHips.BuildConfig.DEBUG),
      new CookieManagerPackage(),
      new RNDeviceInfo(),
      new RNFSPackage(),
      new PickerPackage(),
      new KCKeepAwakePackage(),
      new RNLocalNotificationsPackage(),
      new RCTPdfView(),
      new RNPermissionsPackage(),
      new ReactNativePushNotificationPackage(),
      new RNSensitiveInfoPackage(),
      new RSSignatureCapturePackage(),
      new RNSoundPlayerPackage(),
      new RNSpinkitPackage(),
      new SQLitePluginPackage(),
      new RNUUIDGeneratorPackage(),
      new ReactVideoPackage(),
      new RNCWebViewPackage(),
      new RCTTorchPackage(),
      new RNZipArchivePackage(),
      new RNReactNativeSharedGroupPreferencesPackage(),
      new RNFetchBlobPackage(),
      new ScanditPackage()
    ));
  }
}
