import UIKit

final class WeatherLoadingView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "weather_loading_cover")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
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
    }
    
    func hideAnimated(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                self.isHidden = true
                completion?()
            }
        )
    }
}

private extension WeatherLoadingView {
    func setupLayout() {
        addToView(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
