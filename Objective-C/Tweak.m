@import UIKit;
#import <substrate.h>


@interface _UIBatteryView : UIView
@property (nonatomic, strong) UIView *fillBar;
@property (nonatomic, strong) UIView *linearBar;
@property (nonatomic, strong) UILabel *linearBattery;
- (void)setupViews;
- (void)updateViews;
- (void)updateColors;
@end


@interface _UIStatusBarStringView : UILabel
@end


static BOOL isLPM;
static BOOL isCharging;
static float currentBattery;

#define kClass(string) NSClassFromString(string)
#define kFillBarLPMTintColor UIColor.systemYellowColor
#define kLinearBarLPMTintColor [UIColor.systemYellowColor colorWithAlphaComponent: 0.5]
#define kFillBarChargingTintColor UIColor.systemGreenColor
#define kLinearBarChargingTintColor [UIColor.systemGreenColor colorWithAlphaComponent: 0.5]
#define kFillBarLowBatteryTintColor UIColor.systemRedColor
#define kLinearBarLowBatteryTintColor [UIColor.systemRedColor colorWithAlphaComponent: 0.5]

static void new_setupViews(_UIBatteryView *self, SEL _cmd) {

	self.linearBattery = [UILabel new];
	self.linearBattery.font = [UIFont boldSystemFontOfSize:8];
	self.linearBattery.text = [NSString stringWithFormat:@"%0.f%%", currentBattery];
	self.linearBattery.textAlignment = NSTextAlignmentCenter;
	self.linearBattery.translatesAutoresizingMaskIntoConstraints = NO;
	if(![self.linearBattery isDescendantOfView: self]) [self addSubview: self.linearBattery];

	[self.linearBattery.topAnchor constraintEqualToAnchor: self.topAnchor].active = YES;

	self.linearBar = [UIView new];
	self.linearBar.backgroundColor = UIColor.lightGrayColor;
	self.linearBar.layer.cornerRadius = 2;
	self.linearBar.translatesAutoresizingMaskIntoConstraints = NO;
	if(![self.linearBar isDescendantOfView: self]) [self addSubview: self.linearBar];

	[self.linearBar.topAnchor constraintEqualToAnchor: self.linearBattery.bottomAnchor constant: 0.5].active = YES;
	[self.linearBar.widthAnchor constraintEqualToConstant: 26].active = YES;
	[self.linearBar.heightAnchor constraintEqualToConstant: 3.5].active = YES;

	[self.linearBattery.centerXAnchor constraintEqualToAnchor: self.linearBar.centerXAnchor].active = YES;

	self.fillBar = [UIView new];
	self.fillBar.backgroundColor = UIColor.whiteColor;
	self.fillBar.layer.cornerRadius = 2;
	if(![self.fillBar isDescendantOfView: self.linearBar]) [self.linearBar addSubview: self.fillBar];

}

static void new_updateViews(_UIBatteryView *self, SEL _cmd) {

	currentBattery = [UIDevice currentDevice].batteryLevel * 100;

	self.linearBattery.text = @"";
	self.linearBattery.text = [NSString stringWithFormat:@"%0.f%%", currentBattery];

	/*--- ugh I love constraints but tbh they wouldn't update the bar
	here despite I was doing it correctly (pretty sure) and testing this
	obviously it's time consuming, so I took the ez way out :frCoal: ---*/

	self.fillBar.frame = CGRectMake(0,0, floor((currentBattery / 100) * 26), 3.5);

}

static void new_updateColors(_UIBatteryView *self, SEL _cmd) {

	if(currentBattery <=20 && !isCharging) {

		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{

			self.fillBar.backgroundColor = kFillBarLowBatteryTintColor;
			self.linearBar.backgroundColor = kLinearBarLowBatteryTintColor;

		} completion:nil];

	}

	if(isCharging) {

		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{

			self.fillBar.backgroundColor = kFillBarChargingTintColor;
			self.linearBar.backgroundColor = kLinearBarChargingTintColor;

		} completion:nil];

	}

	if(isLPM) {

		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{

			self.fillBar.backgroundColor = kFillBarLPMTintColor;
			self.linearBar.backgroundColor = kLinearBarLPMTintColor;

		} completion:nil];

	}

	else if(!isCharging && !isLPM && currentBattery > 20) {

		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{

			self.fillBar.backgroundColor = UIColor.whiteColor;
			self.linearBar.backgroundColor = UIColor.lightGrayColor;

		} completion:nil];

	}

}

static void (*origSetChargingState)(_UIBatteryView *self, SEL _cmd, NSInteger);

static void overrideSetChargingState(_UIBatteryView *self, SEL _cmd, NSInteger state) {

	origSetChargingState(self, _cmd, state);
	isCharging = state == 1;

	[self updateColors];

}

static void (*origSetSaverModeActive)(_UIBatteryView *self, SEL _cmd, BOOL);

static void overrideSetSaverModeActive(_UIBatteryView *self, SEL _cmd, BOOL active) {

	origSetSaverModeActive(self, _cmd, active);
	isLPM = active;

	[self updateColors];

}

static void (*origCommonInit)(_UIBatteryView *self, SEL _cmd);

static void overrideCommonInit(_UIBatteryView *self, SEL _cmd) {

	origCommonInit(self, _cmd);

	[[UIDevice currentDevice] setBatteryMonitoringEnabled: YES];

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateViews) name:UIDeviceBatteryLevelDidChangeNotification object:nil];

	[self setupViews];
	[self updateViews];

}

static void (*origSetText)(_UIStatusBarStringView *self, SEL _cmd, NSString *);

static void overrideSetText(_UIStatusBarStringView *self, SEL _cmd, NSString *text) {

	if([text containsString: @"%"]) return;

	origSetText(self, _cmd, text);

}

// - (BOOL)shouldShowBolt;

static BOOL overrideSSB(_UIBatteryView *self, SEL _cmd) { return NO; }

// - (id)_batteryFillColor;

static id overrideBFC(_UIBatteryView *self, SEL _cmd) { return UIColor.clearColor; }

// - (id)bodyColor;

static id overrideBC(_UIBatteryView *self, SEL _cmd) { return UIColor.clearColor; }

// - (id)pinColor;

static id overridePC(_UIBatteryView *self, SEL _cmd) { return UIColor.clearColor; }

// getters and setters

/*--- sadly we can't use class_addProperty here since 
we need a backing ivar, and we can't add ivars to an
existing class at runtime :/ ---*/

static UIView *new_linearBar(_UIBatteryView *self, SEL _cmd) {

	return objc_getAssociatedObject(self, @selector(linearBar));

}

static void new_setLinearBar(_UIBatteryView *self, SEL _cmd, UIView *newLinearBar) {

	return objc_setAssociatedObject(self, @selector(linearBar), newLinearBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

static UIView *new_fillBar(_UIBatteryView *self, SEL _cmd) {

	return objc_getAssociatedObject(self, @selector(fillBar));

}

static void new_setFillBar(_UIBatteryView *self, SEL _cmd, UIView *newFillBar) {

	return objc_setAssociatedObject(self, @selector(fillBar), newFillBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

static UILabel *new_linearBattery(_UIBatteryView *self, SEL _cmd) {

	return objc_getAssociatedObject(self, @selector(linearBattery));

}

static void new_setLinearBattery(_UIBatteryView *self, SEL _cmd, UILabel *newLinearBattery) {

	objc_setAssociatedObject(self, @selector(linearBattery), newLinearBattery, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}


__attribute__((constructor)) static void init() {

	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_commonInit), (IMP) &overrideCommonInit, (IMP *) &origCommonInit);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(setChargingState:), (IMP) &overrideSetChargingState, (IMP *) &origSetChargingState);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(setSaverModeActive:), (IMP) &overrideSetSaverModeActive, (IMP *) &origSetSaverModeActive);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_shouldShowBolt), (IMP) &overrideSSB, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_batteryFillColor), (IMP) &overrideBFC, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(bodyColor), (IMP) &overrideBC, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(pinColor), (IMP) &overridePC, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIStatusBarStringView"), @selector(setText:), (IMP) &overrideSetText, (IMP *) &origSetText);

	class_addMethod(kClass(@"_UIBatteryView"), @selector(linearBar), (IMP) &new_linearBar, "@@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(setLinearBar:), (IMP) &new_setLinearBar, "v@:@");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(fillBar), (IMP) &new_fillBar, "@@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(setFillBar:), (IMP) &new_setFillBar, "v@:@");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(linearBattery), (IMP) &new_linearBattery, "@@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(setLinearBattery:), (IMP) &new_setLinearBattery, "v@:@");

	class_addMethod(kClass(@"_UIBatteryView"), @selector(setupViews), (IMP) &new_setupViews, "v@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(updateViews), (IMP) &new_updateViews, "v@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(updateColors), (IMP) &new_updateColors, "v@:");

}
