#import <objc/runtime.h>
#include <stdlib.h>

/* Make sure tweak understand inter-app communications class */
@interface NSDistributedNotificationCenter : NSNotificationCenter
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

/* Process request for Bluetooth symbol */
@interface UIStatusBarBluetoothItemView
-(id)init;
-(id)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
@end

@interface UIStatusBarBluetoothItemView (Pebbletooth)
@property (nonatomic, readwrite) BOOL overrideUpdate;
-(void)setShouldUpdate:(NSDictionary *)userInfo;
@end

@implementation UIStatusBarBluetoothItemView (Pebbletooth)
-(void)setShouldUpdate:(NSDictionary *)userInfo{
	[self setOverrideUpdate:[userInfo[@"overrideUpdate"] boolValue]];
}

-(BOOL)overrideUpdate{
	return self.overrideUpdate;
}

-(void)setOverrideUpdate:(BOOL)arg1{
	self.overrideUpdate = arg1;
}
@end

%hook UIStatusBarBluetoothItemView
-(id)init{
	NSLog(@"******* initnintin*");
	self = %orig;
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setShouldUpdate:) name:@"PTUpdate" object:nil];
	return self;
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}
%end

/* Return accurate image for Bluetooth icon request */
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


%hook UIStatusBarBluetoothItemView
-(id)contentsImage{
	if(self.overrideUpdate)
		return [_UILegibilityImageSet imageFromImage:[UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"] withShadowImage:[UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"]];
	return %orig;
}

-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	NSLog(@"********* update: %@, %i, %@", arg1, arg2, %orig?@"YES":@"NO");
	return self.overrideUpdate?YES:%orig;
}
%end