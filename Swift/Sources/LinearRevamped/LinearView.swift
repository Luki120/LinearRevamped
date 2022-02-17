import UIKit


final class LinearView: UIView {

	private let linearBattery: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 8)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let linearBar: UIView = {
		let view = UIView()
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 2
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let fillBar: UIView = {
		let view = UIView()
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 2
		return view
	}()

	private var currentBattery = 0.0

	private let kFillBarLPMTintColor = UIColor.systemYellow
	private let kLinearBarLPMTintColor = UIColor.systemYellow.withAlphaComponent(0.5)
	private let kFillBarChargingTintColor = UIColor.systemGreen
	private let kLinearBarChargingTintColor = UIColor.systemGreen.withAlphaComponent(0.5)
	private let kFillBarLowBatteryTintColor = UIColor.systemRed
	private let kLinearBarLowBatteryTintColor = UIColor.systemRed.withAlphaComponent(0.5)

	init() {

		super.init(frame: .zero)

		UIDevice.current.isBatteryMonitoringEnabled = true

		NotificationCenter.default.removeObserver(self)
		NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updateColors), name: Notification.Name("updateColors"), object: nil)

		setupViews()
		updateViews()

	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	private func setupViews() {

		linearBattery.text = String(format: "%.0f%%", currentBattery)

		guard !linearBattery.isDescendant(of: self),
			!linearBar.isDescendant(of: self),
			!fillBar.isDescendant(of: linearBar) else { return }

		addSubview(linearBattery)
		addSubview(linearBar)
		linearBar.addSubview(fillBar)

		linearBattery.topAnchor.constraint(equalTo: topAnchor).isActive = true
		linearBattery.centerXAnchor.constraint(equalTo: linearBar.centerXAnchor).isActive = true

		linearBar.topAnchor.constraint(equalTo: linearBattery.bottomAnchor, constant: 0.5).isActive = true
		linearBar.widthAnchor.constraint(equalToConstant: 26).isActive = true
		linearBar.heightAnchor.constraint(equalToConstant: 3.5).isActive = true

		fillBar.frame = CGRect(x: 0, y: 0, width: floor((currentBattery / 100) * 26), height: 3.5)

	}

	@objc private func updateViews() {

		currentBattery = Double(UIDevice.current.batteryLevel * 100)

		linearBattery.text = ""
		linearBattery.text = String(format: "%.0f%%", currentBattery)

		fillBar.frame = CGRect(x: 0, y: 0, width: floor((currentBattery / 100) * 26), height: 3.5)

	}

	@objc private func updateColors() {

		// not great but.. :bThisIsHowItIs:
		// edit: still not great, but much better, I can sleep a bit better now

		if currentBattery <= 20 && !BatteryState.isCharging && !BatteryState.isLPM {
			animateViewWithViews(self.fillBar, self.linearBar, self.kFillBarLowBatteryTintColor, self.kLinearBarLowBatteryTintColor)
		}

		if BatteryState.isCharging {
			animateViewWithViews(self.fillBar, self.linearBar, self.kFillBarChargingTintColor, self.kLinearBarChargingTintColor)
		}

		else if BatteryState.isLPM {
			animateViewWithViews(self.fillBar, self.linearBar, self.kFillBarLPMTintColor, self.kLinearBarLPMTintColor)
		}

		else if !BatteryState.isCharging && !BatteryState.isLPM && currentBattery > 20 {
			animateViewWithViews(self.fillBar, self.linearBar, .white, .lightGray)
		}

	}

	private func animateViewWithViews(_ fillBar: UIView, _ linearBar: UIView, _ currentFillColor: UIColor, _ currentLinearColor: UIColor) {

		UIView.animate(withDuration: 0.5, delay: 0, options: .overrideInheritedCurve, animations: {
			fillBar.backgroundColor = currentFillColor
			linearBar.backgroundColor = currentLinearColor
		}, completion: nil)		

	}

}


enum BatteryState {

	static var isLPM = false
	static var isCharging = false

}
