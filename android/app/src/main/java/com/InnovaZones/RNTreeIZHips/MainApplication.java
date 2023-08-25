package com.InnovaZones.RNTreeIZHips;

import android.app.Application;
import android.content.Context;
import com.facebook.react.PackageList;
// import androidx.multidex.MultiDex;

import com.facebook.react.ReactApplication;
import org.reactnative.camera.RNCameraPackage;
import com.microsoft.codepush.react.CodePush;
import com.facebook.react.ReactInstanceManager;
import com.masteratul.RNAppstoreVersionCheckerPackage;
import com.dieam.reactnativepushnotification.ReactNativePushNotificationPackage;
import org.wonday.pdf.RCTPdfView;
import com.rpt.reactnativecheckpackageinstallation.CheckPackageInstallationPackage;
import com.github.wumke.RNLocalNotifications.RNLocalNotificationsPackage;
import com.johnsonsu.rnsoundplayer.RNSoundPlayerPackage;
import com.microsoft.appcenter.reactnative.analytics.AppCenterReactNativeAnalyticsPackage;
import com.microsoft.appcenter.reactnative.appcenter.AppCenterReactNativePackage;
import com.microsoft.appcenter.reactnative.crashes.AppCenterReactNativeCrashesPackage;
import com.microsoft.codepush.react.CodePush;
import br.com.classapp.RNSensitiveInfo.RNSensitiveInfoPackage;

import com.psykar.cookiemanager.CookieManagerPackage;
import com.react.rnspinkit.RNSpinkitPackage;
import com.reactnative.ivpusic.imagepicker.PickerPackage;
import com.RNFetchBlob.RNFetchBlobPackage;
import com.learnium.RNDeviceInfo.RNDeviceInfo;
import com.corbt.keepawake.KCKeepAwakePackage;
import com.brentvatne.react.ReactVideoPackage;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;
import java.lang.reflect.InvocationTargetException;
import com.microsoft.codepush.react.ReactInstanceHolder;
import com.reactnativecommunity.asyncstorage.AsyncStoragePackage;
import com.rnfs.RNFSPackage;
import com.rnziparchive.RNZipArchivePackage;
import com.rssignaturecapture.RSSignatureCapturePackage;
import com.scandit.reactnative.ScanditPackage;
import com.uk.tsl.rfid.asciiprotocol.AsciiCommander;
import com.uk.tsl.rfid.asciiprotocol.device.ReaderManager;

import org.pgsqlite.SQLitePluginPackage;
import java.util.Arrays;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {

  private final MyReactNativeHost mReactNativeHost = new MyReactNativeHost(this);


  @Override
  public void onCreate() {
    CodePush.setReactInstanceHolder(mReactNativeHost);
    super.onCreate();
    // MultiDex.install(getBaseContext());
    SoLoader.init(this, /* native exopackage */ false);
    initializeFlipper(this, getReactNativeHost().getReactInstanceManager());
  }

  /**
   * Loads Flipper in React Native templates. Call this in the onCreate method with something like
   * initializeFlipper(this, getReactNativeHost().getReactInstanceManager());
   *
   * @param context
   * @param reactInstanceManager
   */
  private static void initializeFlipper(
          Context context, ReactInstanceManager reactInstanceManager) {
    if (BuildConfig.DEBUG) {
      try {
        /*
         We use reflection here to pick up the class that initializes Flipper,
        since Flipper library is not available in release mode
        */
        Class<?> aClass = Class.forName("com.rndiffapp.ReactNativeFlipper");
        aClass
                .getMethod("initializeFlipper", Context.class, ReactInstanceManager.class)
                .invoke(null, context, reactInstanceManager);
      } catch (ClassNotFoundException e) {
        e.printStackTrace();
      } catch (NoSuchMethodException e) {
        e.printStackTrace();
      } catch (IllegalAccessException e) {
        e.printStackTrace();
      } catch (InvocationTargetException e) {
        e.printStackTrace();
      }
    }
  }

  public class MyReactNativeHost extends ReactNativeHost implements ReactInstanceHolder {

    Application mApplication;

    public MyReactNativeHost(Application application) {
      super(application);
      mApplication = application;
    }

    @Override
    protected String getJSMainModuleName() {
      return "index";
    }

    @Override
    protected String getJSBundleFile() {
      return CodePush.getJSBundleFile();
    }

    @Override
    public boolean getUseDeveloperSupport() {
      return BuildConfig.DEBUG;
    }

    @Override

    protected List<ReactPackage> getPackages() {
//      return Arrays.<ReactPackage>asList(

      @SuppressWarnings("UnnecessaryLocalVariable")
      List<ReactPackage> packages = new PackageList(this).getPackages();
      packages.add(new CustomReactPackage());
      // Packages that cannot be autolinked yet can be added manually here, for example:
      return packages;
//      );
    }
  }

  @Override
  public ReactNativeHost getReactNativeHost() {
    return mReactNativeHost;
  }
}