@import UIKit;
#import <substrate.h>


@interface _UIBatteryView : UIView
@property (nonatomic, strong) UIView *fillBar;
@property (nonatomic, strong) UIView *linearBar;
@property (nonatomic, strong) UILabel *linearBattery;
@property (nonatomic, strong) UIImageView *chargingBoltImageView;
@property (assign, getter=isLowBattery, nonatomic, readonly) BOOL lowBattery;
- (void)setupViews;
- (void)updateViews;
- (void)updateColors;
- (void)shouldAnimateChargingBolt;
- (void)animateViewWithViews:(UIView *)fillBar
	linearBar:(UIView *)linearBar
	currentFillColor:(UIColor *)currentFillColor
	currentLinearColor:(UIColor *)currentLinearColor;
@end


@interface _UIStatusBarStringView : UILabel
@end


static float currentBattery;
static UIColor* stockColor;

#define kClass(string) NSClassFromString(string)

static void new_setupViews(_UIBatteryView *self, SEL _cmd) {

	/*--- TODO:
	• refactor to use 2 stack views, one horizontal inside a vertical one
	• not rn tho, I'm lazy ---*/

	self.linearBattery = [UILabel new];
	self.linearBattery.font = [UIFont boldSystemFontOfSize:8];
	self.linearBattery.text = [NSString stringWithFormat:@"%0.f%%", currentBattery];
	self.linearBattery.textAlignment = NSTextAlignmentCenter;
	self.linearBattery.translatesAutoresizingMaskIntoConstraints = NO;
	if(![self.linearBattery isDescendantOfView: self]) [self addSubview: self.linearBattery];

	[self.linearBattery.topAnchor constraintEqualToAnchor: self.topAnchor].active = YES;

	self.linearBar = [UIView new];
	self.linearBar.backgroundColor = UIColor.lightGrayColor;
	self.linearBar.layer.cornerCurve = kCACornerCurveContinuous;
	self.linearBar.layer.cornerRadius = 2;
	self.linearBar.translatesAutoresizingMaskIntoConstraints = NO;
	if(![self.linearBar isDescendantOfView: self]) [self addSubview: self.linearBar];

	[self.linearBar.topAnchor constraintEqualToAnchor: self.linearBattery.bottomAnchor constant: 0.5].active = YES;
	[self.linearBar.widthAnchor constraintEqualToConstant: 26].active = YES;
	[self.linearBar.heightAnchor constraintEqualToConstant: 3.5].active = YES;

	[self.linearBattery.centerXAnchor constraintEqualToAnchor: self.linearBar.centerXAnchor].active = YES;

	self.fillBar = [UIView new];
	self.fillBar.backgroundColor = UIColor.whiteColor;
	self.fillBar.layer.cornerCurve = kCACornerCurveContinuous;
	self.fillBar.layer.cornerRadius = 2;
	if(![self.fillBar isDescendantOfView: self.linearBar]) [self.linearBar addSubview: self.fillBar];

	UIImage *chargingBoltImage = [[UIImage imageWithContentsOfFile: @"/Library/Application Support/LinearRevamped/LRChargingBolt.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];

	self.chargingBoltImageView = [UIImageView new];
	self.chargingBoltImageView.alpha = 0;
	self.chargingBoltImageView.image = chargingBoltImage;
	self.chargingBoltImageView.tintColor = UIColor.labelColor;
	self.chargingBoltImageView.clipsToBounds = YES;
	self.chargingBoltImageView.translatesAutoresizingMaskIntoConstraints = NO;
	if(![self.chargingBoltImageView isDescendantOfView: self]) [self addSubview: self.chargingBoltImageView];

	[self.chargingBoltImageView.centerYAnchor constraintEqualToAnchor: self.linearBattery.centerYAnchor].active = YES;
	[self.chargingBoltImageView.leadingAnchor constraintEqualToAnchor: self.linearBattery.trailingAnchor].active = YES;
	[self.chargingBoltImageView.widthAnchor constraintEqualToConstant: 7.5].active = YES;
	[self.chargingBoltImageView.heightAnchor constraintEqualToConstant: 7.5].active = YES;

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
    [self animateViewWithViews:self.fillBar linearBar:self.linearBar currentFillColor:stockColor currentLinearColor:[stockColor colorWithAlphaComponent: 0.5]];
}

static void new_shouldAnimateChargingBolt(_UIBatteryView *self, SEL _cmd) {

	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{

		self.chargingBoltImageView.alpha = isCharging ? 1 : 0;

	} completion:nil];

}

static void new_animateViewWithViews(
	_UIBatteryView *self,
	SEL _cmd,
	UIView *fillBar,
	UIView *linearBar,
	UIColor *currentFillColor,
	UIColor *currentLinearColor) {

	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{

		fillBar.backgroundColor = currentFillColor;
		linearBar.backgroundColor = currentLinearColor;

	} completion:nil];

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

	if([text containsString: @"%"]) return origSetText(self, _cmd, @"");

	origSetText(self, _cmd, text);

}

// - (BOOL)shouldShowBolt;

static BOOL overrideSSB(_UIBatteryView *self, SEL _cmd) { return NO; }

// - (id)_batteryFillColor;
static UIColor* (*origBatteryFillColor)(_UIBatteryView *self, SEL _cmd);

static id overrideBFC(_UIBatteryView *self, SEL _cmd) {
    // The alpha value is set here because iOS sometimes makes it semi-transparent
    // Without this it would look funny in wireless carplay.
	stockColor = [origBatteryFillColor(self, _cmd) colorWithAlphaComponent: 1];

	[self updateColors];

    return UIColor.clearColor; 
}

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

static UIImageView *new_chargingBoltImageView(_UIBatteryView *self, SEL _cmd) {

	return objc_getAssociatedObject(self, @selector(chargingBoltImageView));

}

static void new_setChargingBoltImageView(_UIBatteryView *self, SEL _cmd, UIImageView *newChargingBoltImageView) {

	objc_setAssociatedObject(self, @selector(chargingBoltImageView), newChargingBoltImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}


__attribute__((constructor)) static void init() {

	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_commonInit), (IMP) &overrideCommonInit, (IMP *) &origCommonInit);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_shouldShowBolt), (IMP) &overrideSSB, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_batteryFillColor), (IMP) &overrideBFC, (IMP *) &origBatteryFillColor);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(bodyColor), (IMP) &overrideBC, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(pinColor), (IMP) &overridePC, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIStatusBarStringView"), @selector(setText:), (IMP) &overrideSetText, (IMP *) &origSetText);

	class_addMethod(kClass(@"_UIBatteryView"), @selector(linearBar), (IMP) &new_linearBar, "@@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(setLinearBar:), (IMP) &new_setLinearBar, "v@:@");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(fillBar), (IMP) &new_fillBar, "@@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(setFillBar:), (IMP) &new_setFillBar, "v@:@");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(linearBattery), (IMP) &new_linearBattery, "@@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(setLinearBattery:), (IMP) &new_setLinearBattery, "v@:@");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(chargingBoltImageView), (IMP) &new_chargingBoltImageView, "@@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(setChargingBoltImageView:), (IMP) &new_setChargingBoltImageView, "v@:@");

	class_addMethod(kClass(@"_UIBatteryView"), @selector(setupViews), (IMP) &new_setupViews, "v@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(updateViews), (IMP) &new_updateViews, "v@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(updateColors), (IMP) &new_updateColors, "v@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(shouldAnimateChargingBolt), (IMP) &new_shouldAnimateChargingBolt, "v@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(animateViewWithViews:linearBar:currentFillColor:currentLinearColor:), (IMP) &new_animateViewWithViews, "v@:@@@@");

}
