//
//  WeatherPageContainerViewController.swift
//  PetMil
//
//  Created by Emil on 29.05.2026.
//

import UIKit

final class WeatherPageContainerViewController: UIViewController {

    private let cityListStorage: CityListStorageProtocol

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
    func setupChildren() {
        addChild(pageViewController)
        view.addToView(pageViewController.view)
        pageViewController.didMove(toParent: self)

        view.addToView(pageControl)
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
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func observeStorageChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cityListChanged),
            name: .cityListDidChange,
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
    func pageControlChanged() {
        let target = pageControl.currentPage
        guard pageControllers.indices.contains(target) else { return }
        let current = clampedActiveIndex()
        let direction: UIPageViewController.NavigationDirection = target > current ? .forward : .reverse
        pageViewController.setViewControllers(
            [pageControllers[target]],
            direction: direction,
            animated: true
        )
        cityListStorage.activeIndex = target
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
    }
}
