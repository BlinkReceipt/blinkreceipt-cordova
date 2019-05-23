function BlinkReceipt() {
}

exports.scanReceipt = function (successCallback, errorCallback, options) {

	var argsToPass = [];

	var allArgs = ['licenseKey','licensee','edgeDetection','storeUserFrames','dontSaveData','scanStatic','invoiceMode'];

	allArgs.forEach(function(curArg) {
		if (curArg in options) {
			argsToPass.push(options[curArg]);
		} else {
			argsToPass.push(null);
		}
	});

    cordova.exec(successCallback, errorCallback, "BlinkReceiptPlugin", "scanReceipt", argsToPass);
};