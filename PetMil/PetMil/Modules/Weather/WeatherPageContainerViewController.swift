//
//  WeatherPageContainerViewController.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import UIKit

final class WeatherPageContainerViewController: UIViewController {

    private let cityListStorage: CityListStorageProtocol
    private let imageLoaderService: ImageLoaderServiceProtocol = ImageLoaderService()

    private var backgroundPhotoTask: Task<Void, Never>?
    private var currentLoadedBackgroundURL: URL?

    private lazy var backgroundPhotoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var backgroundDimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.25)
        view.isHidden = true
        return view
    }()

    private lazy var backgroundFallbackView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        return view
    }()

    private lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [UIPageViewController.OptionsKey.interPageSpacing: 0]
        )
        controller.dataSource = self
        controller.delegate = self
        return controller
    }()

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.hidesForSinglePage = true
        control.pageIndicatorTintColor = UIColor.label.withAlphaComponent(0.25)
        control.currentPageIndicatorTintColor = .label
        control.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        return control
    }()

    private lazy var settingsButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "gearshape.fill")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        configuration.baseForegroundColor = .label
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(handleSettingsTapped), for: .touchUpInside)
        return button
    }()

    private var pageControllers: [WeatherViewController] = []
    private var isPageBoundToList = false

    init(cityListStorage: CityListStorageProtocol) {
        self.cityListStorage = cityListStorage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBackground()
        setupChildren()
        setupLayout()
        rebuildPages()
        observeStorageChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        syncWithStorageIfNeeded()
    }
}

private extension WeatherPageContainerViewController {
    func setupBackground() {
        view.addToView(backgroundFallbackView)
        view.addToView(backgroundPhotoView)
        view.addToView(backgroundDimView)

        NSLayoutConstraint.activate([
            backgroundFallbackView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundFallbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundFallbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundFallbackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backgroundPhotoView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundPhotoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundPhotoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundPhotoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backgroundDimView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundDimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundDimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundDimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupChildren() {
        addChild(pageViewController)
        view.addToView(pageViewController.view)
        pageViewController.view.backgroundColor = .clear
        if let pageScrollView = pageViewController.view.subviews.first(where: { $0 is UIScrollView }) {
            pageScrollView.backgroundColor = .clear
        }
        pageViewController.didMove(toParent: self)

        view.addToView(pageControl)
        view.addToView(settingsButton)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -2),
            pageControl.heightAnchor.constraint(equalToConstant: 20),

            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            settingsButton.widthAnchor.constraint(equalToConstant: 40),
            settingsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func observeStorageChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cityListChanged),
            name: .cityListDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(unitPreferencesChanged),
            name: .unitPreferencesDidChange,
            object: nil
        )
    }

    func rebuildPages() {
        let cities = cityListStorage.cities

        if cities.isEmpty {
            let emptyVC = WeatherAssembly.build(for: nil)
            pageControllers = [emptyVC]
        } else {
            pageControllers = cities.map { WeatherAssembly.build(for: $0) }
        }

        let multiPage = cities.count > 1
        pageControllers.forEach { vc in
            vc.additionalSafeAreaInsets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: multiPage ? 22 : 0,
                right: 0
            )
        }

        wireBackgroundCallbacks()

        pageControl.numberOfPages = cities.isEmpty ? 0 : cities.count
        let activeIdx = clampedActiveIndex()
        pageControl.currentPage = activeIdx

        guard pageControllers.indices.contains(activeIdx) else { return }
        pageViewController.setViewControllers(
            [pageControllers[activeIdx]],
            direction: .forward,
            animated: false
        )
        isPageBoundToList = true
    }

    func wireBackgroundCallbacks() {
        for vc in pageControllers {
            vc.onContentLoaded = { [weak self, weak vc] url in
                guard let self, let vc else { return }
                let activeIdx = self.clampedActiveIndex()
                guard self.pageControllers.indices.contains(activeIdx),
                      self.pageControllers[activeIdx] === vc else { return }
                self.loadBackground(url: url)
            }
        }
    }

    func loadBackground(url: URL?) {
        if currentLoadedBackgroundURL == url, url != nil { return }
        currentLoadedBackgroundURL = url

        backgroundPhotoTask?.cancel()

        guard let url else {
            UIView.transition(
                with: backgroundPhotoView,
                duration: 0.3,
                options: .transitionCrossDissolve
            ) {
                self.backgroundPhotoView.image = nil
                self.backgroundDimView.isHidden = true
            }
            return
        }

        backgroundPhotoTask = Task { [weak self] in
            guard let self else { return }
            let image = await imageLoaderService.loadImage(from: url)
            await MainActor.run {
                guard self.currentLoadedBackgroundURL == url else { return }
                UIView.transition(
                    with: self.backgroundPhotoView,
                    duration: 0.4,
                    options: .transitionCrossDissolve
                ) {
                    self.backgroundPhotoView.image = image
                    self.backgroundDimView.isHidden = image == nil
                }
            }
        }
    }

    func syncWithStorageIfNeeded() {
        guard isPageBoundToList else {
            rebuildPages()
            return
        }

        let cities = cityListStorage.cities
        let pagesMatch = pageControllers.count == max(cities.count, 1)

        if !pagesMatch {
            rebuildPages()
            return
        }

        let activeIdx = clampedActiveIndex()
        guard pageControllers.indices.contains(activeIdx) else { return }
        let currentlyShown = pageViewController.viewControllers?.first as? WeatherViewController
        if currentlyShown !== pageControllers[activeIdx] {
            pageViewController.setViewControllers(
                [pageControllers[activeIdx]],
                direction: .forward,
                animated: false
            )
            pageControl.currentPage = activeIdx
        }
    }

    func clampedActiveIndex() -> Int {
        let count = max(cityListStorage.cities.count, 1)
        return max(0, min(cityListStorage.activeIndex, count - 1))
    }

    @objc
    func cityListChanged() {
        let currentCount = pageControllers.count
        let storedCount = max(cityListStorage.cities.count, 1)
        if currentCount != storedCount {
            rebuildPages()
        }
    }

    @objc
    func unitPreferencesChanged() {
        rebuildPages()
    }

    @objc
    func handleSettingsTapped() {
        let settingsVC = SettingsAssembly.build()
        present(settingsVC, animated: true)
    }

    @objc
    func pageControlChanged() {
        let target = pageControl.currentPage
        guard pageControllers.indices.contains(target) else { return }
        let current = clampedActiveIndex()
        let direction: UIPageViewController.NavigationDirection = target > current ? .forward : .reverse
        let targetVC = pageControllers[target]
        pageViewController.setViewControllers(
            [targetVC],
            direction: direction,
            animated: true
        )
        cityListStorage.activeIndex = target
        loadBackground(url: targetVC.currentBackgroundPhotoURL)
    }
}

extension WeatherPageContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let weatherVC = viewController as? WeatherViewController,
              let index = pageControllers.firstIndex(of: weatherVC),
              index > 0 else {
            return nil
        }
        return pageControllers[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let weatherVC = viewController as? WeatherViewController,
              let index = pageControllers.firstIndex(of: weatherVC),
              index < pageControllers.count - 1 else {
            return nil
        }
        return pageControllers[index + 1]
    }
}

extension WeatherPageContainerViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let visible = pageViewController.viewControllers?.first as? WeatherViewController,
              let index = pageControllers.firstIndex(of: visible) else {
            return
        }
        pageControl.currentPage = index
        cityListStorage.activeIndex = index
        loadBackground(url: visible.currentBackgroundPhotoURL)
    }
}
