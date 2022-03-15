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

	private let chargingBoltImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.alpha = 0
		imageView.tintColor = .label
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private var currentBattery = 0.0
	private let kImagePath = "/Library/Application Support/LinearRevamped/LRChargingBolt.png"

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

		translatesAutoresizingMaskIntoConstraints = false

		linearBattery.text = String(format: "%.0f%%", currentBattery)

		guard let boltImage = UIImage(contentsOfFile: kImagePath) else { return }
		chargingBoltImageView.image = boltImage.withRenderingMode(.alwaysTemplate)

		guard !linearBattery.isDescendant(of: self),
			!linearBar.isDescendant(of: self),
			!chargingBoltImageView.isDescendant(of: self),
			!fillBar.isDescendant(of: linearBar) else { return }

		addSubview(linearBattery)
		addSubview(linearBar)
		addSubview(chargingBoltImageView)
		linearBar.addSubview(fillBar)

		linearBattery.topAnchor.constraint(equalTo: topAnchor).isActive = true
		linearBattery.centerXAnchor.constraint(equalTo: linearBar.centerXAnchor).isActive = true

		linearBar.topAnchor.constraint(equalTo: linearBattery.bottomAnchor, constant: 0.5).isActive = true
		linearBar.widthAnchor.constraint(equalToConstant: 26).isActive = true
		linearBar.heightAnchor.constraint(equalToConstant: 3.5).isActive = true

		chargingBoltImageView.centerYAnchor.constraint(equalTo: linearBattery.centerYAnchor).isActive = true
		chargingBoltImageView.leadingAnchor.constraint(equalTo: linearBattery.trailingAnchor).isActive = true
		chargingBoltImageView.widthAnchor.constraint(equalToConstant: 7.5).isActive = true
		chargingBoltImageView.heightAnchor.constraint(equalToConstant: 7.5).isActive = true

		fillBar.frame = CGRect(x: 0, y: 0, width: floor((currentBattery / 100) * 26), height: 3.5)

	}

	@objc private func updateViews() {

		currentBattery = Double(UIDevice.current.batteryLevel * 100)

		linearBattery.text = ""
		linearBattery.text = String(format: "%.0f%%", currentBattery)

		fillBar.frame = CGRect(x: 0, y: 0, width: floor((currentBattery / 100) * 26), height: 3.5)

	}

	@objc private func updateColors() {

		animateViewWithViews(
			self.fillBar,
			self.linearBar,
			BatteryState.stockColor,
			BatteryState.stockColor.withAlphaComponent(0.5)
		)

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

}


enum BatteryState {

	static var isLPM = false
	static var isCharging = false
	static var stockColor = UIColor.white

}
