@import CydiaSubstrate;
@import libroot;
@import UIKit;


@interface _CDBatterySaver : NSObject
+ (id)batterySaver;
- (NSInteger)getPowerMode;
- (BOOL)setPowerMode:(NSInteger)powerMode error:(id)error;
@end


@interface _PMLowPowerMode : NSObject
+ (id)sharedInstance;
- (NSInteger)getPowerMode;
- (void)setPowerMode:(NSInteger)powerMode fromSource:(NSString *)source;
@end


@interface UIStatusBarWindow : UIWindow
@end


@interface _UIBatteryView : UIView
@property (nonatomic, strong) UIView *fillBar;
@property (nonatomic, strong) UIView *linearBar;
@property (nonatomic, strong) UILabel *linearBattery;
@property (nonatomic, strong) UIImageView *chargingBoltImageView;
@property (nonatomic, assign) CGFloat chargePercent;
@property (nonatomic, assign) NSInteger chargingState;
@property (nonatomic, assign) BOOL saverModeActive;
- (void)setupViews;
- (void)updateViews;
- (void)updateColors;
- (UIView *)setupUIView;
- (void)animateViewWithViews:(UIView *)fillBar
	linearBar:(UIView *)linearBar
	currentFillColor:(UIColor *)currentFillColor
	currentLinearColor:(UIColor *)currentLinearColor;
@end


@class _UIStatusBarBatteryItem;
@class _UIStatusBarStringView;

static float currentBattery;
static UIColor *stockColor;

#define kClass(string) NSClassFromString(string)
#define rootPathNS(path) JBROOT_PATH_NSSTRING(path)

static void new_setupViews(_UIBatteryView *self, SEL _cmd) {

	self.linearBattery = [UILabel new];
	self.linearBattery.font = [UIFont boldSystemFontOfSize: 7];
	self.linearBattery.text = [NSString stringWithFormat:@"%0.f%%", currentBattery];
	self.linearBattery.textColor = UIColor.labelColor;
	self.linearBattery.textAlignment = NSTextAlignmentCenter;
	self.linearBattery.translatesAutoresizingMaskIntoConstraints = NO;
	if(![self.linearBattery isDescendantOfView: self]) [self addSubview: self.linearBattery];

	self.linearBar = [self setupUIView];
	self.linearBar.translatesAutoresizingMaskIntoConstraints = NO;

	self.fillBar = [self setupUIView];

	if(![self.linearBar isDescendantOfView: self]) [self addSubview: self.linearBar];
	if(![self.fillBar isDescendantOfView: self.linearBar]) [self.linearBar addSubview: self.fillBar];

	NSString *const kImagePath = rootPathNS(@"/Library/Tweak Support/LinearRevamped/LRChargingBolt.png");
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
	transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	[self.linearBattery.layer addAnimation:transition forKey:nil];

	self.linearBattery.text = [NSString stringWithFormat:@"%0.f%%", currentBattery];

	self.fillBar.frame = CGRectMake(0, 0, floor((currentBattery / 100) * 26), 3.5);

}

static void new_updateColors(_UIBatteryView *self, SEL _cmd) {

	[self animateViewWithViews:self.fillBar
		linearBar:self.linearBar
		currentFillColor:stockColor
		currentLinearColor:[stockColor colorWithAlphaComponent: 0.5]
	];

}

static UIView *new_setupUIView(_UIBatteryView *self, SEL _cmd) {

	UIView *view = [UIView new];
	view.layer.cornerCurve = kCACornerCurveContinuous;
	view.layer.cornerRadius = 2;
	return view;

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
		self.chargingBoltImageView.alpha = self.chargingState == 1 ? 1 : 0;

	} completion:nil];

}

static id (*origIWF)(_UIBatteryView *, SEL, CGRect);
static id overrideIWF(_UIBatteryView *self, SEL _cmd, CGRect frame) {

	id orig = origIWF(self, _cmd, frame);

	[self setupViews];
	[self updateViews];

	[[UIDevice currentDevice] setBatteryMonitoringEnabled: YES];

	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateViews) name:UIDeviceBatteryLevelDidChangeNotification object:nil];

	return orig;

}

static id (*origStatusBarWindowIWF)(UIStatusBarWindow *, SEL, CGRect);
static id overrideStatusBarWindowIWF(UIStatusBarWindow *self, SEL _cmd, CGRect frame) {

	id orig = origStatusBarWindowIWF(self, _cmd, frame);

	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(lr_didSwipeLeft)];
	swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[self addGestureRecognizer: swipeRecognizer];

	return orig;

}

// credits & slightly modified from ⇝ https://github.com/MTACS/Ampere/blob/059f2f6dcbf4c55b5fd343b96303603b5ee466ff/Ampere.xm#L253
static void lr_didSwipeLeft(UIStatusBarWindow *self, SEL _cmd) {

	if(kClass(@"_PMLowPowerMode")) {
		BOOL active = [[kClass(@"_PMLowPowerMode") sharedInstance] getPowerMode] == 1;
		[[kClass(@"_PMLowPowerMode") sharedInstance] setPowerMode:!active fromSource: @"SpringBoard"];
	}

	else {
		NSInteger state = [[kClass(@"_CDBatterySaver") batterySaver] getPowerMode];
		if(state == 0) [[kClass(@"_CDBatterySaver") batterySaver] setPowerMode:1 error: nil];
		else if(state == 1) [[kClass(@"_CDBatterySaver") batterySaver] setPowerMode:0 error: nil];
	}	

}

static UIImageView *overrideChargingView(_UIStatusBarBatteryItem *self, SEL _cmd) { return [UIImageView new]; }

static void (*origSetText)(_UIStatusBarStringView *, SEL, NSString *);
static void overrideSetText(_UIStatusBarStringView *self, SEL _cmd, NSString *text) {

	if([text containsString: @"%"]) return origSetText(self, _cmd, @"");
	origSetText(self, _cmd, text);

}

// - (UIColor *)_batteryFillColor;
// - (UIColor *)bodyColor;
// - (UIColor *)pinColor;
// - (BOOL)shouldShowBolt;

static UIColor *(*origBFC)(_UIBatteryView *, SEL);
static UIColor *overrideBFC(_UIBatteryView *self, SEL _cmd) {

	if(self.saverModeActive || self.chargingState == 1)
		stockColor = [origBFC(self, _cmd) colorWithAlphaComponent: 1];

	else stockColor = [UIColor colorWithHue:([UIDevice currentDevice].batteryLevel * .333) saturation:1 brightness:1 alpha: 1.0];

	[self updateColors];

	return UIColor.clearColor;

}

static UIColor *overrideBC(_UIBatteryView *self, SEL _cmd) { return UIColor.clearColor; }
static UIColor *overridePC(_UIBatteryView *self, SEL _cmd) { return UIColor.clearColor; }
static BOOL overrideSSB(_UIBatteryView *self, SEL _cmd) { return NO; }

// getters and setters

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

__attribute__((constructor)) static void init(void) {

	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(initWithFrame:), (IMP) &overrideIWF, (IMP *) &origIWF);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_shouldShowBolt), (IMP) &overrideSSB, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(_batteryFillColor), (IMP) &overrideBFC, (IMP *) &origBFC);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(bodyColor), (IMP) &overrideBC, (IMP *) NULL);
	MSHookMessageEx(kClass(@"_UIBatteryView"), @selector(pinColor), (IMP) &overridePC, (IMP *) NULL);
	MSHookMessageEx(kClass(@"UIStatusBarWindow"), @selector(initWithFrame:), (IMP) &overrideStatusBarWindowIWF, (IMP *) &origStatusBarWindowIWF);
	MSHookMessageEx(kClass(@"_UIStatusBarStringView"), @selector(setText:), (IMP) &overrideSetText, (IMP *) &origSetText);
	MSHookMessageEx(kClass(@"_UIStatusBarBatteryItem"), @selector(chargingView), (IMP) &overrideChargingView, (IMP *) NULL);

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
	class_addMethod(kClass(@"_UIBatteryView"), @selector(setupUIView), (IMP) &new_setupUIView, "@@:");
	class_addMethod(kClass(@"_UIBatteryView"), @selector(animateViewWithViews:linearBar:currentFillColor:currentLinearColor:), (IMP) &new_animateViewWithViews, "v@:@@@@");
	class_addMethod(kClass(@"UIStatusBarWindow"), @selector(lr_didSwipeLeft), (IMP) &lr_didSwipeLeft, "v@:");

}
