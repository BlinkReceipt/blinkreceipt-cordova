# blinkreceipt-cordova

This is a Cordova plugin that wraps the BlinkReceipt iOS and (coming soon) Android SDKs

## Installation

1. Clone or download this repository
2. In your Cordova app's folder run `cordova plugin add /path/to/blinkreceipt-cordova`

- Note: This will automatically download the BlinkReceipt iOS static framework which is ~20mb so it may take a few minutes depending on your connection speed

## Usage

- To initiate a scan session, you call the `scanReceipt` function as follows:

```javascript
cordova.plugins.blinkReceipt.scanReceipt(successCallback, errorCallback, options);
```

- The `options` parameter you pass in is an object with the following properties:

Property | Required | Description
-------- | -------- | -------------
licenseKey | Yes | This is the iOS license key that you must generate at the [Microblink Dashboard](https://microblink.com/signup)
staticScan | No | By default the scanning session will use the live camera, but you can pass `true` for this parameter to instead scan from the camera roll. When running on the iOS simulator you will always scan from camera roll.
edgeDetection | No | Pass `true` in order to turn on edge detection which prompts the user with tips for adjusting their distance from the receipt
storeUserFrames | No | Pass `true` in order to store the frames the user snapped during the scan session. The file paths for these frames will be found in the `userFramesFilepaths` key of the scan results
dontSaveData | No | Pass `true` to prevent the SDK from saving any receipt data or images remotely
invoiceMode | No | Pass `true` to indicate that the document type for this scan session is a full size paper invoice (rather than a receipt)

- The `successCallback` is a function as follows:

```javascript
function successCallback(scanResults) {
  //access results
}
```

- `scanResults` is an object containing all the data from the scan session with property names matching those of the iOS results objects such as `BRScanResults`, `BRProduct` etc which are all documented at https://blinkreceipt.github.io/blinkreceipt-ios

- The `errorCallback` is a function as follows:

```javascript
function errorCallback(errorObject) {
  //errorObject.error contains a description of the error
}
```
- As with all Cordova plugins, you must wait for the `deviceready` event before interacting with this plugin.

## Example

- Here is a small demo showing how to initate a scan session and output the results to the console from within your own Cordova app (this assumes your page has a button with id `btnScan` on it):

```javascript
var app = {

    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        document.getElementById('btnScan').addEventListener('touchstart', this.btnScanTouch.bind(this));
    },

    btnScanTouch: function() {
        var options = {licenseKey: "your_license_key",
                        edgeDetection: true,
                        storeUserFrames: true
                        };

        cordova.plugins.blinkReceipt.scanReceipt(this.scanSuccess.bind(this), this.scanFailure.bind(this), options);
    },

    scanSuccess: function(scanResults) {
        window.alert("Scanning complete!");
        
        console.log("Scan results: " + JSON.stringify(scanResults));
    },

    scanFailure: function(error) {
        window.alert("Scanning error: " + error.error);
    },
};

app.initialize();
```
