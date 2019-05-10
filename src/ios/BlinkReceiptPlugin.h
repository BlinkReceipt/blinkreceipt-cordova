#import <Cordova/CDVPlugin.h>
#import <BlinkReceiptStatic/BlinkReceiptStatic.h>

@interface BlinkReceiptPlugin : CDVPlugin

- (void) scanReceipt:(CDVInvokedUrlCommand*)command;

@end
