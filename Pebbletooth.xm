#import <objc/runtime.h>
#include <stdlib.h>

/* Make sure tweak understand inter-app communications and image-set classes */
@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface _UILegibilityImageSet : NSObject {
    UIImage *_image;
    UIImage *_shadowImage;
}

@property(retain) UIImage *image;
@property(retain) UIImage *shadowImage;

+(id)imageFromImage:(UIImage *)arg1 withShadowImage:(UIImage *)arg2;
-(id)initWithImage:(UIImage *)arg1 shadowImage:(UIImage *)arg2;
-(void)setImage:(UIImage *)arg1;
-(void)setShadowImage:(UIImage *)arg1;
-(UIImage *)image;
-(UIImage *)shadowImage;
@end

/* Detect Pebble connection from BluetoothManager */
@interface BluetoothManager
-(void)_connectedStatusChanged;
-(id)connectedDevices;
@end

%hook BluetoothManager
-(void)_connectedStatusChanged{
	BOOL pebble = NO;
	for(id device in [self connectedDevices])
		if ([[device name] rangeOfString:@"Pebble"].location != NSNotFound)
			pebble = YES;

	NSLog(@"Pebbletooth: detected connection of Bluetooth device that %@ to be a Pebble (currently connected to: %@).", pebble?@"appears":@"does not appear", [[self connectedDevices] description]);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"PTUpdate" object:nil userInfo:@{@"overrideUpdate" : @(pebble)}];
	%orig;
}
%end

/* Return accurate image for Bluetooth icon request */
@interface UIStatusBarBluetoothItemView
-(id)init;
-(void)dealloc;
-(id)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
@end

%hook UIStatusBarBluetoothItemView
%new -(void)setShouldUpdate:(NSDictionary *)userInfo{
	NSLog(@"------ setshould %@", userInfo);
	objc_setAssociatedObject(self, @"shouldOverride", userInfo[@"shouldOverride"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)init{
	NSLog(@"----- init");
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setShouldUpdate:) name:@"PTUpdate" object:nil];
	return %orig;
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}

-(id)contentsImage{
	NSLog(@"---- contents: %@", objc_getAssociatedObject(self, @"shouldOverride"));
	if([objc_getAssociatedObject(self, @"shouldOverride") boolValue])
		return [_UILegibilityImageSet imageFromImage:[UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"] withShadowImage:[UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"]];
	return %orig;
}

-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	NSLog(@"********* update: %@, %i, %@", arg1, arg2, %orig?@"YES":@"NO");
	return [objc_getAssociatedObject(self, @"shouldOverride") boolValue]?YES:%orig;
}
%end