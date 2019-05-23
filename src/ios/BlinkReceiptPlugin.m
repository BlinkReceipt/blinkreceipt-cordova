#import "BlinkReceiptPlugin.h"

@interface BRScanManager ()

- (void)directScanReceiptImages:(NSArray<UIImage*>*)images
                    scanOptions:(BRScanOptions*)scanOptions
                   withDelegate:(NSObject<BRScanResultsDelegate>*)delegate;

- (void)setBlinkLicensee:(NSString*)licensee;

@end

@interface BRScanOptions ()

@property (nonatomic) BOOL dontSaveData;
@property (nonatomic) BOOL resizeDown;
@property (nonatomic) NSInteger invoiceMode;

@end

@interface BlinkReceiptPlugin () <BRScanResultsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) BOOL edgeDetection, storeUserFrames, dontSaveData, invoiceMode;
@property (strong, nonatomic) CDVInvokedUrlCommand* commandHelper;

@end

@implementation BlinkReceiptPlugin

- (void) scanReceipt:(CDVInvokedUrlCommand*)command {
    self.commandHelper = command;
    CDVPluginResult* pluginResult;
    
    NSString* licenseKey = [command argumentAtIndex:0 withDefault:nil andClass:[NSString class]];
    NSString* licensee = [command argumentAtIndex:1 withDefault:nil andClass:[NSString class]];
    self.edgeDetection = [[command argumentAtIndex:2 withDefault:@(NO) andClass:[NSNumber class]] boolValue];
    self.storeUserFrames = [[command argumentAtIndex:3 withDefault:@(NO) andClass:[NSNumber class]] boolValue];
    self.dontSaveData = [[command argumentAtIndex:4 withDefault:@(NO) andClass:[NSNumber class]] boolValue];
    BOOL scanStaticImage = [[command argumentAtIndex:5 withDefault:@(NO) andClass:[NSNumber class]] boolValue];
    self.invoiceMode = [[command argumentAtIndex:6 withDefault:@(NO) andClass:[NSNumber class]] boolValue];
    
    if (!licenseKey) {
        NSDictionary *errorDict = @{@"error": @"No license key"};
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [BRScanManager sharedManager].licenseKey = licenseKey;
    
    if (licensee) {
        [[BRScanManager sharedManager] setBlinkLicensee:licensee];
    }
    
#if TARGET_IPHONE_SIMULATOR
    //simulator can only scan static images
    scanStaticImage = YES;
#endif
    
    if (scanStaticImage) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [[self currentApplicationViewController] presentViewController:imagePicker animated:YES completion:nil];
    } else {
        BRScanOptions *scanOptions = [BRScanOptions new];
        
        scanOptions.detectDistanceWithEdges = self.edgeDetection;
        if (self.edgeDetection) {
            scanOptions.numGoodFramesToStopEdges = 0;
        }
        scanOptions.storeUserFrames = self.storeUserFrames;
        scanOptions.dontSaveData = self.dontSaveData;
        scanOptions.invoiceMode = self.invoiceMode ? 2 : 0;
        
        [[BRScanManager sharedManager] startStaticCameraFromController:[self currentApplicationViewController]
                                                           scanOptions:scanOptions
                                                          withDelegate:self];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    BRScanOptions *scanOptions = [BRScanOptions new];
    
    scanOptions.resizeDown = YES;
    scanOptions.invoiceMode = self.invoiceMode ? 2 : 0;
    scanOptions.dontSaveData = self.dontSaveData;
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [[BRScanManager sharedManager] directScanReceiptImages:@[image]
                                               scanOptions:scanOptions
                                              withDelegate:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *errorDict = @{@"error": @"User cancelled scanning"};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHelper.callbackId];
}

- (void)didFinishScanning:(UIViewController*)cameraViewController withScanResults:(BRScanResults*)scanResults {
    [cameraViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *resultsDict = [scanResults dictionaryForSerializing];
    
    if (self.storeUserFrames && [BRScanManager sharedManager].userFramesFilepaths.count > 0) {
        NSMutableDictionary *mutResultDict = [NSMutableDictionary dictionaryWithDictionary:resultsDict];
        
        mutResultDict[@"userFramesFilepaths"] = [BRScanManager sharedManager].userFramesFilepaths;
        resultsDict = mutResultDict;
    }

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultsDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHelper.callbackId];
}

- (void)didCancelScanning:(UIViewController *)cameraViewController {
    [cameraViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *errorDict = @{@"error": @"User cancelled scanning"};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHelper.callbackId];
}

- (void)scanningErrorOccurred:(NSError*)error {
    NSDictionary *errorDict = @{@"error": [error localizedDescription]};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandHelper.callbackId];
}

- (UIViewController *) currentApplicationViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    
    if([rootViewController isKindOfClass:[UIViewController class]]){
        return [[UIApplication sharedApplication]delegate].window.rootViewController;
    } else {
        UINavigationController *navigationController = (UINavigationController *)[[UIApplication sharedApplication]delegate].window.rootViewController;
        return(UIViewController *)[navigationController topViewController];
    }
    return nil;
}
@end
