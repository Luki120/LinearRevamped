import LinearRevampedC
import Orion


class BatteryHook: ClassHook<_UIBatteryView> {

	// orion:new
	func setupViews() {
		let linearView = LinearView()
		target.addSubview(linearView)

		linearView.topAnchor.constraint(equalTo: target.topAnchor).isActive = true
		linearView.bottomAnchor.constraint(equalTo: target.bottomAnchor).isActive = true
		linearView.leadingAnchor.constraint(equalTo: target.leadingAnchor).isActive = true
		linearView.trailingAnchor.constraint(equalTo: target.trailingAnchor).isActive = true
	}

	func initWithFrame(_ frame: CGRect) -> Target {
		let orig = orig.initWithFrame(frame)
		setupViews()
		return orig
	}

	func setChargingState(_ chargingState: Int) {
		orig.setChargingState(chargingState)
		BatteryState.isCharging = chargingState == 1
	}

	func _batteryFillColor() -> UIColor {
		if target.saverModeActive || target.chargingState == 1 {
			BatteryState.stockColor = orig._batteryFillColor().withAlphaComponent(1)
		}
		else {
			BatteryState.stockColor = .init(
				hue: CGFloat(UIDevice.current.batteryLevel * 0.333),
				saturation: 1,
				brightness: 1,
				alpha: 1
			)
		}

		NotificationCenter.default.post(name: .didUpdateColorsNotification, object: nil)
		return .clear
	}

	func bodyColor() -> UIColor { return .clear }
	func pinColor() -> UIColor { return .clear }
	func _shouldShowBolt() -> Bool { return false }

}

class UIStatusBarWindowHook: ClassHook<UIWindow> {

	static let targetName = "UIStatusBarWindow"

	func initWithFrame(_ frame: CGRect) -> Target {
		let orig = orig.initWithFrame(frame)

		let swipeRecognizer = UISwipeGestureRecognizer(target: target, action: #selector(lrDidSwipeLeft))
		swipeRecognizer.direction = .left
		target.addGestureRecognizer(swipeRecognizer)

		return orig
	}

	// orion:new
	@objc
	func lrDidSwipeLeft() {
		if let _PMLowPowerMode = NSClassFromString("_PMLowPowerMode") {
			let active = _PMLowPowerMode.sharedInstance().getPowerMode() == 1
			_PMLowPowerMode.sharedInstance().setPowerMode(!active ? 1 : 0, fromSource: "SpringBoard")
		}
		else {
			guard let _CDBatterySaver = NSClassFromString("_CDBatterySaver") else { return }
			let state = _CDBatterySaver.shared().getPowerMode()

			switch state {
				case 0: let _ = _CDBatterySaver.shared().setPowerMode(1, error: nil)
				case 1: let _ = _CDBatterySaver.shared().setPowerMode(0, error: nil)
				default: break
			}
		}
	}

}

class BatteryBoltHook: ClassHook<NSObject> {

	static let targetName = "_UIStatusBarBatteryItem"
	func chargingView() -> UIImageView { return UIImageView() }

}

class StringHook: ClassHook<UILabel> {

	static let targetName = "_UIStatusBarStringView"

	func setText(_ text: String) {
		guard !text.contains("%") else { return orig.setText("") }
		orig.setText(text)
	}

}
