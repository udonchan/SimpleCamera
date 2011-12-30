//
//  AppDelegate.h
//  SimpleCameraServer
//

#define SAVE_PATH @"/Users/Shared/"

#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>
#import <QTKit/QTKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet QTCaptureView*mCaptureView;
    IBOutlet NSButton*captureButton;

    QTCaptureSession*mCaptureSession;
    QTCaptureDeviceInput*mCaptureDeviceInput;
    QTCaptureDecompressedVideoOutput*mCaptureDecompressedVideoOutput;

@private
    CVImageBufferRef mCurrentImageBuffer;
}
- (IBAction)ignight_capture:(id)sender;
@property(assign)IBOutlet NSWindow*window;
@end
