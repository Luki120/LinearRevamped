import Orion
import UIKit


class BatteryHook: ClassHook<UIView> {

	static let targetName = "_UIBatteryView"

	// orion:new
	func setupViews() {
		let linearView = LinearView()
		target.addSubview(linearView)

		linearView.topAnchor.constraint(equalTo: target.topAnchor).isActive = true
		linearView.bottomAnchor.constraint(equalTo: target.bottomAnchor).isActive = true
		linearView.leadingAnchor.constraint(equalTo: target.leadingAnchor).isActive = true
		linearView.trailingAnchor.constraint(equalTo: target.trailingAnchor).isActive = true
	}

	func setChargingState(_ state: Int) {
		orig.setChargingState(state)
		BatteryState.isCharging = state == 1
		NotificationCenter.default.post(name: Notification.Name("updateColors"), object: nil)
	}

	func _commonInit() {
		orig._commonInit()
		setupViews()
	}

	func _batteryFillColor() -> UIColor {
		BatteryState.stockColor = orig._batteryFillColor().withAlphaComponent(1)
		NotificationCenter.default.post(name: Notification.Name("updateColors"), object: nil)
		return .clear
	}

	func bodyColor() -> UIColor { return .clear }
	func pinColor() -> UIColor { return .clear }
	func _shouldShowBolt() -> Bool { return false }

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
