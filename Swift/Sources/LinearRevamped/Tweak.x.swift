import Orion
import UIKit


class BatteryHook: ClassHook<UIView> {

	static let targetName = "_UIBatteryView"

	// orion:new

	func setupViews() {

		let linearView = LinearView()
		linearView.translatesAutoresizingMaskIntoConstraints = false
		target.addSubview(linearView)

		linearView.topAnchor.constraint(equalTo: target.topAnchor).isActive = true
		linearView.bottomAnchor.constraint(equalTo: target.bottomAnchor).isActive = true
		linearView.leadingAnchor.constraint(equalTo: target.leadingAnchor).isActive = true
		linearView.trailingAnchor.constraint(equalTo: target.trailingAnchor).isActive = true

	}

	/*--- in the objc version a simple call of updateColors() works,
	here? Oh no, it won't work reliably for some fucking reason,
	so I had to move all the color logic to the LinearView class
	and use notifications :deadaf: I prefer this approach anyways,
	there's more encapsulation. I would refactor the objc version to
	keep consistency between both but there I'm using associated objects
	to add properties at runtime, and those are cool, so I'll just let it be ---*/

	func setChargingState(_ state: Int) {
		orig.setChargingState(state)
		BatteryState.isCharging = state == 1
		NotificationCenter.default.post(name: Notification.Name("updateColors"), object: nil)
	}

	func setSaverModeActive(_ active: Bool) {
		orig.setSaverModeActive(active)
		BatteryState.isLPM = active
		NotificationCenter.default.post(name: Notification.Name("updateColors"), object: nil)
	}

	func _commonInit() {
		orig._commonInit()
		setupViews()
	}

	func _shouldShowBolt() -> Bool {
		return false
	}

	func _batteryFillColor() -> UIColor {
		return .clear
	}

	func bodyColor() -> UIColor {
		return .clear
	}

	func pinColor() -> UIColor {
		return .clear
	}

}


class StringHook: ClassHook<UILabel> {

	static let targetName = "_UIStatusBarStringView"

	func setText(_ text: String) {
		guard !text.contains("%") else { return }
		orig.setText(text)
	}
}
