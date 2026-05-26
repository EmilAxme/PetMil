import UIKit

final class WeatherLoadingView: UIView {

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        isHidden = false
        alpha = 1
        activityIndicator.startAnimating()
    }

    func hideAnimated(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                self.isHidden = true
                self.activityIndicator.stopAnimating()
                completion?()
            }
        )
    }
}

private extension WeatherLoadingView {
    func setupLayout() {
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
