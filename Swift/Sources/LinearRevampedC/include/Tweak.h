@import UIKit;


@interface _CDBatterySaver : NSObject
+ (instancetype)batterySaver NS_SWIFT_NAME(shared());
- (NSInteger)getPowerMode;
- (BOOL)setPowerMode:(NSInteger)powerMode error:(id)error;
@end


@interface _PMLowPowerMode : NSObject
+ (instancetype)sharedInstance;
- (NSInteger)getPowerMode;
- (void)setPowerMode:(NSInteger)powerMode fromSource:(NSString *)source;
@end


@interface _UIBatteryView : UIView
@property (nonatomic, assign) BOOL saverModeActive;
@property (nonatomic, assign) NSInteger chargingState;
@end
