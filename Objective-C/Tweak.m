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
- (void)createUIViewWithView:(UIView *)view
	withBackgroundColor:(UIColor *)color
	unleashesConstraints:(BOOL)unleashes;
- (void)animateViewWithViews:(UIView *)fillBar
	linearBar:(UIView *)linearBar
	currentFillColor:(UIColor *)currentFillColor
	currentLinearColor:(UIColor *)currentLinearColor;
@end


@interface _UIStatusBarStringView : UILabel
@end


static float currentBattery;
static BOOL isCharging;
static UIColor *stockColor;

#define kClass(string) NSClassFromString(string)

static void new_setupViews(_UIBatteryView *self, SEL _cmd) {

	self.linearBattery = [UILabel new];
	self.linearBattery.font = [UIFont boldSystemFontOfSize:7];
	self.linearBattery.text = [NSString stringWithFormat:@"%0.f%%", currentBattery];
	self.linearBattery.textAlignment = NSTextAlignmentCenter;
	self.linearBattery.translatesAutoresizingMaskIntoConstraints = NO;
	if(![self.linearBattery isDescendantOfView: self]) [self addSubview: self.linearBattery];

	self.linearBar = [UIView new];
	[self createUIViewWithView:self.linearBar
		withBackgroundColor:UIColor.lightGrayColor
		unleashesConstraints:NO
	];
	if(![self.linearBar isDescendantOfView: self]) [self addSubview: self.linearBar];

	self.fillBar = [UIView new];
	[self createUIViewWithView:self.fillBar
		withBackgroundColor:UIColor.systemBackgroundColor
		unleashesConstraints:YES
	];
	if(![self.fillBar isDescendantOfView: self.linearBar]) [self.linearBar addSubview: self.fillBar];

	NSString *const kImagePath = @"/var/mobile/Documents/LinearRevamped/LRChargingBolt.png";
	UIImage *chargingBoltImage = [UIImage imageWithContentsOfFile: kImagePath];
	chargingBoltImage = [chargingBoltImage imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];

	self.chargingBoltImageView = [UIImageView new];
	self.chargingBoltImageView.alpha = 0;
	self.chargingBoltImageView.image = chargingBoltImage;
	self.chargingBoltImageView.tintColor = UIColor.labelColor;
	self.chargingBoltImageView.clipsToBounds = YES;
	self.chargingBoltImageView.translatesAutoresizingMaskIntoConstraints = NO;
	if(![self.chargingBoltImageView isDescendantOfView: self]) [self addSubview: self.chargingBoltImageView];

	// layout

	[self.linearBar.topAnchor constraintEqualToAnchor: self.linearBattery.bottomAnchor constant: 0.5].active = YES;
	[self.linearBar.widthAnchor constraintEqualToConstant: 26].active = YES;
	[self.linearBar.heightAnchor constraintEqualToConstant: 3.5].active = YES;

	[self.linearBattery.topAnchor constraintEqualToAnchor: self.topAnchor].active = YES;
	[self.linearBattery.centerXAnchor constraintEqualToAnchor: self.linearBar.centerXAnchor].active = YES;

	[self.chargingBoltImageView.centerYAnchor constraintEqualToAnchor: self.linearBattery.centerYAnchor].active = YES;
	[self.chargingBoltImageView.leadingAnchor constraintEqualToAnchor: self.linearBattery.trailingAnchor constant: -0.8].active = YES;
	[self.chargingBoltImageView.widthAnchor constraintEqualToConstant: 7.5].active = YES;
	[self.chargingBoltImageView.heightAnchor constraintEqualToConstant: 7.5].active = YES;

}

static void new_updateViews(_UIBatteryView *self, SEL _cmd) {

	currentBattery = [UIDevice currentDevice].batteryLevel * 100;

	self.linearBattery.text = @"";

	CATransition *transition = [CATransition animation];
	transition.type = kCATransitionFade;
	transition.duration = 0.8;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[self.linearBattery.layer addAnimation:transition forKey:nil];

	self.linearBattery.text = [NSString stringWithFormat:@"%0.f%%", currentBattery];
	self.fillBar.frame = CGRectMake(0,0, floor((currentBattery / 100) * 26), 3.5);

}

static void new_updateColors(_UIBatteryView *self, SEL _cmd) {

	[self animateViewWithViews:self.fillBar
		linearBar:self.linearBar
		currentFillColor:stockColor
		currentLinearColor:[stockColor colorWithAlphaComponent: 0.5]
	];

}

static void new_createUIViewWithView(
	_UIBatteryView *self,
	SEL _cmd,
	UIView *view,
	UIColor *backgroundColor,
	BOOL unleashesConstraints) {

	view.backgroundColor = backgroundColor;
	view.layer.cornerCurve = kCACornerCurveContinuous;
	view.layer.cornerRadius = 2;
	if(unleashesConstraints) view.translatesAutoresizingMaskIntoConstraints = NO;

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
		self.chargingBoltImageView.alpha = isCharging ? 1 : 0;

	} completion:nil];

}

static void (*origSetChargingState)(_UIBatteryView *self, SEL _cmd, NSInteger);

static void overrideSetChargingState(_UIBatteryView *self, SEL _cmd, NSInteger state) {

	origSetChargingState(self, _cmd, state);
	isCharging = state == 1;

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

	if([text containsString: @"%"]) return origSetText(self, _cmd, @"");
	origSetText(self, _cmd, text);

}

// - (BOOL)shouldShowBolt;

static BOOL overrideSSB(_UIBatteryView *self, SEL _cmd) { return NO; }

// - (UIColor *)_batteryFillColor;

static UIColor *(*origBFC)(_UIBatteryView *self, SEL _cmd);

static UIColor *overrideBFC(_UIBatteryView *self, SEL _cmd) {

	stockColor = [origBFC(self, _cmd) colorWithAlphaComponent: 1];
	[self updateColors];

    return UIColor.clearColor; 

}

// - (UIColor *)bodyColor;

static UIColor *overrideBC(_UIBatteryView *self, SEL _cmd) { return UIColor.clearColor; }

// - (UIColor *)pinColor;

static UIColor *overridePC(_UIBatteryView *self, SEL _cmd) { return UIColor.clearColor; }

// getters and setters

/*--- sadly we can't use class_addProperty here since 
we need a backing ivar, and we can't add ivars to an
existing class at runtime ---*/

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
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(setChargingState:), (IMP) &overrideSetChargingState, (IMP *) &origSetChargingState);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_shouldShowBolt), (IMP) &overrideSSB, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_batteryFillColor), (IMP) &overrideBFC, (IMP *) &origBFC);
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
	class_addMethod(kClass(@"_UIBatteryView"), @selector(createUIViewWithView:withBackgroundColor:unleashesConstraints:), (IMP) &new_createUIViewWithView, "v@:@@@");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(animateViewWithViews:linearBar:currentFillColor:currentLinearColor:), (IMP) &new_animateViewWithViews, "v@:@@@@");

}
