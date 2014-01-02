/* Make sure tweak understands inter-app communications classes */
@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

/* Class method to create image-set */
@interface _UILegibilityImageSet : NSObject
+(id)imageFromImage:(UIImage *)arg1 withShadowImage:(UIImage *)arg2;
@end

/* For image usage in the UIKit framework (private API?) */
@interface UIImage (Private)
+(UIImage *)kitImageNamed:(NSString *)name;
+(UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

/* Detect Pebble connection from BluetoothManager */
@interface BluetoothManager
+(id)sharedInstance;
-(void)_connectedStatusChanged;
-(NSArray *)connectedDevices;
@end

@interface UIStatusBarItem : NSObject
-(int)type;
@end

/* Superclass for Bluetooth statusbar item, used for notifications */
@interface UIStatusBarItemView : UIView{
	struct CGContext { } *_imageContext;
}

-(id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4;
-(void)dealloc;
-(id)contentsImage;
-(id)imageWithShadowNamed:(id)arg1;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;

-(void)endImageContext;
-(id)imageFromImageContextClippedToWidth:(float)arg1;
-(void)beginImageContextWithMinimumWidth:(float)arg1;
@end

/* Image call from statusbar class */
@interface UIStatusBarBluetoothItemView : UIStatusBarItemView
-(int)getAndSetPebbletoothOverride; // %new
@end