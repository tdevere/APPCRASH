# Mobile-ReactNative

    React : "16.13.1",
    React-native : "0.63.4",
    

    ## First time run the App need to run the shell file

    Project path => ./RunFirstTime.sh 
    
    
    ## In Android real device getting error in first time - Need to port reverse

    adb reverse tcp:8081 tcp:8081
    
    
** Package.json --> File adjustment

    "rn-fetch-blob": "0.10.13", 
    Android support version: 0.10.13 
    iOS support version: 0.12.0",

    In the scripts -->  "postinstall": "cd ios && pod install" --> Need to remove for Android.

            "build:ios": "react-native bundle --entry-file='index.js' --bundle-output='./ios/main.jsbundle' --dev=false --platform='ios' --assets-dest='./ios'",
        "postinstall": "cd ios && pod install"


    ios - > need to add these 2 package 
    "scandit-react-native-datacapture-barcode": "6.13.1",
    "scandit-react-native-datacapture-core": "6.13.1",

    Android :
      "scandit-react-native": "5.18.3",


