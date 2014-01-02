#import <objc/runtime.h>
#include <stdlib.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

/* Detect Pebble connection from BluetoothManager */
@interface BluetoothManager
-(void)_connectedStatusChanged;
- (id)connectedDevices;
@end

%hook BluetoothManager
-(void)_connectedStatusChanged{
	BOOL pebble = NO;
	for(id device in [self connectedDevices])
		if ([[device name] rangeOfString:@"Pebble"].location != NSNotFound)
			pebble = YES;

	NSLog(@"Pebbletooth: detected connection of Bluetooth device that %@ to be a Pebble (currently connected to: %@).", pebble?@"appears":@"does not appear", [[self connectedDevices] description]);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"PTUpdate" object:nil];
	%orig;
}//end statuschanged
%end

/* Catch notification from BluetoothManager and process the UIStatusBarItem */
@interface SBStatusBarStateAggregator
-(void)_updateBluetoothItem;
@end

%hook SBStatusBarStateAggregator
-(id)init{
	self = %orig;
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateBluetoothItem) name:@"PTUpdate" object:nil];
	return self;
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}
%end

/* Return accurate icon for Bluetooth symbol request */
@interface UIStatusBarBluetoothItemView
-(id)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
@end

%hook UIStatusBarBluetoothItemView
-(id)contentsImage{
	NSLog(@"********* contents: %@", %orig);

	//@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png" 
	return %orig;
}

-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	NSLog(@"********* update: %@, %i, %@", arg1, arg2, %orig?@"YES":@"NO");
	return %orig;
}
%end