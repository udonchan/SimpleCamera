//
//  AppDelegate.m
//  SimpleCameraServer
//
#import "AppDelegate.h"

@implementation AppDelegate
@synthesize window;

-(NSData*)NSImage2Jpeg:(NSImage*)i withCompressionFactor:(float)f {
    return [[NSBitmapImageRep imageRepWithData:[i TIFFRepresentation]] 
            representationUsingType:NSJPEGFileType
            properties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:f], NSImageCompressionFactor, nil]];
}

-(IBAction)ignight_capture:(id)sender{
    CVImageBufferRef imageBuffer;
    @synchronized (self) {
        imageBuffer = CVBufferRetain(mCurrentImageBuffer);
    }
    if (!imageBuffer)
        return;
    NSCIImageRep*imageRep = [NSCIImageRep imageRepWithCIImage:[CIImage imageWithCVImageBuffer:imageBuffer]];
    NSImage*image = [[NSImage alloc] initWithSize:[imageRep size]];
    [image addRepresentation:imageRep];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyyMMddHHmmss";
    [[self NSImage2Jpeg:image withCompressionFactor:1.0] writeToFile:[NSString stringWithFormat:@"%@%@%@", 
                                                                      SAVE_PATH, 
                                                                      [df stringFromDate:[NSDate date]],
                                                                      @".jpg"] atomically:YES];
    CVBufferRelease(imageBuffer);
}

-(void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame
     withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
       fromConnection:(QTCaptureConnection *)connection {
    CVImageBufferRef imageBufferToRelease;
    CVBufferRetain(videoFrame);
    @synchronized (self) {
        imageBufferToRelease = mCurrentImageBuffer;
        mCurrentImageBuffer = videoFrame;
    }
    CVBufferRelease(imageBufferToRelease);
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    mCaptureSession = [[QTCaptureSession alloc] init];
    NSError *error;

    // find a video device
    QTCaptureDevice *d = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    if (d && ![d open:&error]) {
        [[NSAlert alertWithError:error] runModal];
        return;
    }
    // add the video device to the session as device input
    mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:d];
    if (![mCaptureSession addInput:mCaptureDeviceInput error:&error]) {
        [[NSAlert alertWithError:error] runModal];
        return;
    }
    // set the decompressed video to the session output
    mCaptureDecompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
    [mCaptureDecompressedVideoOutput setDelegate:self];
    if (![mCaptureSession addOutput:mCaptureDecompressedVideoOutput error:&error]) {
        [[NSAlert alertWithError:error] runModal];
        return;
    }    
    [mCaptureView setCaptureSession:mCaptureSession];
    [mCaptureSession startRunning];
}

-(void)windowWillClose:(NSNotification *)notification {
    [mCaptureSession stopRunning];
    [[mCaptureDeviceInput device] close];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

@end
