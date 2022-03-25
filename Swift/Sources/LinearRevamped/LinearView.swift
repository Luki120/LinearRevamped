import UIKit


final class LinearView: UIView {

	private let linearBattery: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 7)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let chargingBoltImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.alpha = 0
		imageView.tintColor = .label
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private var linearBar: UIView!
	private var fillBar: UIView!
	private var currentBattery = 0.0
	private var widthAnchorConstraint: NSLayoutConstraint?

	// MARK: Lifecyle

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

		let kImagePath = "/var/mobile/Documents/LinearRevamped/LRChargingBolt.png"
		guard let boltImage = UIImage(contentsOfFile: kImagePath) else { return }
		chargingBoltImageView.image = boltImage.withRenderingMode(.alwaysTemplate)

		linearBar = setupUIView()
		fillBar = setupUIView()

		addSubview(linearBattery)
		addSubview(linearBar)
		addSubview(chargingBoltImageView)
		linearBar.addSubview(fillBar)

		setupLayout()

	}

	private func setupLayout() {

		translatesAutoresizingMaskIntoConstraints = false

		linearBattery.topAnchor.constraint(equalTo: topAnchor).isActive = true
		linearBattery.centerXAnchor.constraint(equalTo: linearBar.centerXAnchor).isActive = true

		linearBar.topAnchor.constraint(equalTo: linearBattery.bottomAnchor, constant: 0.5).isActive = true
		linearBar.widthAnchor.constraint(equalToConstant: 26).isActive = true
		linearBar.heightAnchor.constraint(equalToConstant: 3.5).isActive = true

		fillBar.heightAnchor.constraint(equalToConstant: 3.5).isActive = true

		chargingBoltImageView.centerYAnchor.constraint(equalTo: linearBattery.centerYAnchor).isActive = true
		chargingBoltImageView.leadingAnchor.constraint(equalTo: linearBattery.trailingAnchor, constant: -0.5).isActive = true
		chargingBoltImageView.widthAnchor.constraint(equalToConstant: 7.5).isActive = true
		chargingBoltImageView.heightAnchor.constraint(equalToConstant: 7.5).isActive = true

	}

	// MARK: Reusable funcs

	private func setupUIView() -> UIView {

		let view = UIView()
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 2
		view.translatesAutoresizingMaskIntoConstraints = false
		return view

	}

	private func animateViewWithViews(
		_ fillBar: UIView,
		_ linearBar: UIView,
		_ currentFillColor: UIColor,
		_ currentLinearColor: UIColor
	) {

		UIView.animate(withDuration: 0.5, delay: 0, options: .overrideInheritedCurve, animations: {
			fillBar.backgroundColor = currentFillColor
			linearBar.backgroundColor = currentLinearColor
			self.chargingBoltImageView.alpha = BatteryState.isCharging ? 1 : 0
		}, completion: nil)

	}

	// MARK: Selectors

	@objc private func updateViews() {

		currentBattery = Double(UIDevice.current.batteryLevel * 100)

		linearBattery.text = ""

		let transition = CATransition()
		transition.duration = 0.8
		transition.type = CATransitionType.fade
		transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		linearBattery.layer.add(transition, forKey: nil)

		linearBattery.text = String(format: "%.0f%%", currentBattery)

		widthAnchorConstraint?.isActive = false
		widthAnchorConstraint = fillBar.widthAnchor.constraint(equalToConstant: CGFloat(floor((currentBattery / 100) * 26)))
		widthAnchorConstraint?.isActive = true

	}

	@objc private func updateColors() {

		animateViewWithViews(
			self.fillBar,
			self.linearBar,
			BatteryState.stockColor,
			BatteryState.stockColor.withAlphaComponent(0.5)
		)

	}

}


enum BatteryState {

	static var isCharging = false
	static var stockColor = UIColor.white

}
