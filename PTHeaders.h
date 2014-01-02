/* Make sure tweak understand inter-app communications classes */
@interface NSDistributedNotificationCenter : NSNotificationCenter
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

-(void)setLayerContentsImage:(id)arg1;
-(id)imageFromImageContextClippedToWidth:(float)arg1;
-(id)imageWithShadowNamed:(id)arg1;

// %new
-(int)getAndSetPebbletoothOverride;
@end

/* Image call from statusbar class */
@interface UIStatusBarBluetoothItemView : UIStatusBarItemView
-(id)contentsImage;
@end

/* Class method to create image-set */
@interface _UILegibilityImageSet : NSObject
+(id)imageFromImage:(UIImage *)arg1 withShadowImage:(UIImage *)arg2;
@end