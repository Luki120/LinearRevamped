import UIKit


final class LinearView: UIView {

	private lazy var linearBattery: UILabel = {
		let label = UILabel()
		label.font = .boldSystemFont(ofSize: 7)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		addSubview(label)
		return label
	}()

	private lazy var chargingBoltImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.alpha = 0
		imageView.tintColor = .label
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)
		return imageView
	}()

	private var currentBattery = 0.0
	private var fillBar: UIView!
	private var linearBar: UIView!
	private var widthAnchorConstraint: NSLayoutConstraint?

	// ! Lifecyle

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	init() {
		super.init(frame: .zero)

		UIDevice.current.isBatteryMonitoringEnabled = true

		NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updateColors), name: Notification.Name("updateColors"), object: nil)

		setupViews()
		updateViews()
	}

	deinit { NotificationCenter.default.removeObserver(self) }

	private func setupViews() {
		linearBattery.text = String(format: "%.0f%%", currentBattery)

		let kImagePath = "/var/mobile/Documents/LinearRevamped/LRChargingBolt.png"
		guard let boltImage = UIImage(contentsOfFile: kImagePath) else { return }
		chargingBoltImageView.image = boltImage.withRenderingMode(.alwaysTemplate)

		linearBar = setupUIView()
		fillBar = setupUIView()

		addSubview(linearBar)
		linearBar.addSubview(fillBar)

		layoutViews()
	}

	private func layoutViews() {
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

	// ! Reusable

	private func setupUIView() -> UIView {
		let view = UIView()
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 2
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}

	private func animate(withViews views: [UIView], fillColor: UIColor, linearColor: UIColor) {
		UIView.animate(withDuration: 0.5, delay: 0, options: .overrideInheritedCurve) {
			views.first?.backgroundColor = fillColor
			views[1].backgroundColor = linearColor
			self.chargingBoltImageView.alpha = BatteryState.isCharging ? 1 : 0
		}

	}

	// ! Selectors

	@objc private func updateColors() {
		animate(
			withViews: [fillBar, linearBar],
			fillColor: BatteryState.stockColor,
			linearColor: BatteryState.stockColor.withAlphaComponent(0.5)
		)
	}

	@objc private func updateViews() {
		currentBattery = Double(UIDevice.current.batteryLevel * 100)

		linearBattery.text = ""

		let transition = CATransition()
		transition.duration = 0.8
		transition.type = .fade
		transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		linearBattery.layer.add(transition, forKey: nil)

		linearBattery.text = String(format: "%.0f%%", currentBattery)

		let kWidthConstant = CGFloat(floor((currentBattery / 100) * 26))

		widthAnchorConstraint?.isActive = false
		widthAnchorConstraint = fillBar.widthAnchor.constraint(equalToConstant: kWidthConstant)
		widthAnchorConstraint?.isActive = true

	}

}

enum BatteryState {
	static var isCharging = false
	static var stockColor = UIColor.white
}
