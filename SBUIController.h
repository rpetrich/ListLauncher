/**
 * This header is generated by class-dump-z 0.2-1.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: (null)
 */

#import <Foundation/NSObject.h>
#import <SBApplication.h>


@class UIView, SBZoomView, UIWindow, SBWallpaperView;

@interface SBUIController : NSObject 

{

}
+(int)displayedLevelForLockScreenBatteryLevel:(int)lockScreenBatteryLevel;
+(SBUIController *)sharedInstance;
-(void)_indicateConnectedToPower;

-(void)animateAppleDown:(BOOL)animated;	// Zoom out the Apple logo.
-(BOOL)launchedAfterLanguageRestart;
-(void)clearLaunchedAfterLanguageRestart;
-(void)localeChanged;
-(void)languageChanged;
-(void)finishLaunching;
-(void)systemControllerRouteChanged:(id)changed;
-(void)lock:(BOOL)lock;
-(void)lock;	// Simulate pressing the "lock" button.
-(void)clearZoomLayer;
-(UIView *)contentView;
-(UIWindow *)window;

-(void)activateApplicationAnimated:(SBApplication*)application;
-(void)showZoomLayerWithDefaultImageOfApp:(SBApplication *)app;
-(void)showZoomLayerWithIOSurfaceSnapshotOfApp:(SBApplication *)app includeStatusWindow:(id)window;
-(void)scatterIconListAndBar:(BOOL)animated;
-(void)insertAndOrderIconListsForReordering:(BOOL)reordering;
-(void)animateApplicationActivation:(id)activation animateDefaultImage:(BOOL)image scatterIcons:(BOOL)icons;
-(void)animateApplicationActivationDidStop:(id)animateApplicationActivation finished:(id)finished context:(void*)context;
-(void)tearDownIconListAndBar;
-(void)animateApplicationSuspend:(SBApplication*)suspend;	// Zoom out and suspend the app
-(void)applicationSuspendAnimationDidStop:(SBApplication *)applicationSuspendAnimation finished:(id)finished context:(void*)context;
-(void)animateApplicationSuspendFlip:(id)flip;
-(void)applicationSuspendFlipDidStop:(SBApplication *)applicationSuspendFlip;
-(void)stopRestoringIconList;
-(void)finishedFadingInButtonBar;
-(BOOL)clickedMenuButton;
-(void)wakeUp:(id)up;

-(void)updateBatteryState:(id)state;
-(CGFloat)batteryCapacity;
-(NSInteger)batteryCapacityAsPercentage;
-(CGFloat)curvedBatteryCapacity;
-(NSInteger)curvedBatteryCapacityAsPercentage;
-(BOOL)isBatteryCharging;
-(BOOL)isOnAC;
-(void)ACPowerChanged;
-(void)setIsConnectedToUnusableFirewireCharger:(BOOL)unusableFirewireCharger;
-(BOOL)isConnectedToUnusableFirewireCharger;
-(void)noteStatusBarHeightChanged:(CGFloat)changed duration:(NSTimeInterval)duration;
-(BOOL)isHeadsetDocked;
-(BOOL)isHeadsetBatteryCharging;
-(unsigned char)headsetBatteryCapacity;



-(void)lock:(BOOL)lock disableLockSound:(BOOL)sound;
-(void)setShouldRasterizeAndFreezeContentView:(BOOL)rasterizeAndFreezeContentView;
-(void)_updateWallpaperImage;
-(SBWallpaperView *)wallpaperView;
-(BOOL)isDisplayingWallpaper;
-(void)setWallpaperAlpha:(CGFloat)alpha;
-(void)_setRoundedCornersOnZoomLayerIfNecessaryForApp:(SBApplication *)app withCornersFrame:(CGRect)cornersFrame;
-(void)fadeIconsForScatter:(BOOL)scatter duration:(NSTimeInterval)duration startTime:(double)time;
-(void)restoreIconListAnimated:(BOOL)animated;
-(void)restoreIconListAnimated:(BOOL)animated animateWallpaper:(BOOL)wallpaper;
-(void)showButtonBar:(BOOL)bar animate:(BOOL)animate animateWallpaper:(BOOL)wallpaper action:(SEL)action delegate:(id)delegate startTime:(double)time duration:(NSTimeInterval)duration;
-(BOOL)_handleButtonEventToSuspendDisplays:(BOOL)suspendDisplays displayWasSuspendedOut:(BOOL*)anOut;
-(int)displayBatteryCapacityAsPercentage;
// in a protocol: -(BOOL)shouldWindowUseOnePartInterfaceRotationAnimation:(id)animation;
// in a protocol: -(BOOL)window:(id)window shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation;
// in a protocol: -(id)rotatingContentViewForWindow:(id)window;
// in a protocol: -(id)rotatingFooterViewForWindow:(id)window;
-(CGFloat)_buttonBarContainerViewHeightForOrientation:(int)orientation;
-(void)_resetSubviewGeometryIfNecessary;
// in a protocol: -(void)getRotationContentSettings:(XXStruct_t5OlHA*)settings forWindow:(id)window;
// in a protocol: -(void)window:(id)window willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(NSTimeInterval)duration;
// in a protocol: -(void)window:(id)window willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(NSTimeInterval)duration;
// in a protocol: -(void)window:(id)window didRotateFromInterfaceOrientation:(int)interfaceOrientation;

-(void)restoreIconList:(BOOL)animated;
-(void)showButtonBar:(BOOL)bar animate:(BOOL)animate action:(SEL)action delegate:(id)delegate;

@end
