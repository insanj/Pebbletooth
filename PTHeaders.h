/* Make sure tweak understands inter-app communications classes */
@interface NSDistributedNotificationCenter : NSNotificationCenter
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
-(id)connectedDevices;
@end

/* Superclass for Bluetooth statusbar item, used for notifications */
@interface UIStatusBarItemView : UIView
-(id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4;
-(void)dealloc;
@end

/* Image call from statusbar class */
@interface UIStatusBarBluetoothItemView : UIStatusBarItemView
-(id)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;

// %new
-(int)getAndSetPebbletoothOverride;
@end

/* Class method to create image-set */
@interface _UILegibilityImageSet : NSObject
+(id)imageFromImage:(UIImage *)arg1 withShadowImage:(UIImage *)arg2;
@end