import Combine
import PrismAgent
import SwiftUI
import UIKit

protocol DashboardViewModel: ObservableObject {
    var toasty: FancyToast? { get set }
    var selectedIndex: Int { get set }
    var proofOfRequest: RequestPresentation? { get set }

    func middleButtonPressed()
    func start()
}

final class DashboardTabViewController<ViewModel: DashboardViewModel>: UITabBarController, UITabBarControllerDelegate {
    private var presentQRCodeScanner: Binding<Bool>
    private let viewModel: ViewModel
    private let middleIndex = 2
    private lazy var middleButton = makeScanButton()
    private var cancellables = Set<AnyCancellable>()

    override var selectedIndex: Int {
        didSet {
            setupButton(selectedIndex: selectedIndex)
        }
    }

    init(viewModel: ViewModel, presentQRCodeScanner: Binding<Bool>) {
        self.viewModel = viewModel
        self.presentQRCodeScanner = presentQRCodeScanner
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(middleButton)
        tabBar.barTintColor = UIColor.white
        tabBar.tintColor = UIColor.cyan
        tabBar.unselectedItemTintColor = UIColor.gray
        tabBar.backgroundColor = UIColor.white
        tabBar.addDropShadow(radius: 20, opacity: 0.14, offset: CGSize(width: 0, height: 4), color: UIColor.darkGray)

        UITabBarItem
            .appearance()
            .setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)],
                for: .normal
            )
        UITabBarItem
            .appearance()
            .setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)],
                for: .normal
            )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndex = middleIndex
        _ = middleButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupButton(selectedIndex: Int) {
        middleButton
            .setImage(
                getButtonImage(isTabSelected: selectedIndex == middleIndex),
                for: .normal
            )
    }

    private func makeScanButton() -> UIButton {
        let button = UIButton()
        button.setImage(getButtonImage(isTabSelected: selectedIndex == middleIndex), for: .normal)
        let margin = UIApplication.shared.windows[0].safeAreaInsets.bottom
        button.frame = CGRect(
            origin: CGPoint(
                x: (view.frame.width / 2) - 24,
                y: view.frame.height - margin - tabBar.height - 15
            ),
            size: .init(width: 48, height: 48)
        )
        button.addTarget(self, action: #selector(selectMiddleViewController(sender:)), for: .touchUpInside)
        return button
    }

    private func getButtonImage(isTabSelected: Bool) -> UIImage {
        let name = isTabSelected ? "tab_central_on" : "tab_central_off"
        guard let image = UIImage(named: name) else {
            fatalError("Image missing")
        }
        return image
    }

    @objc private func selectMiddleViewController(
        sender: UIButton
    ) {
        viewModel.middleButtonPressed()
        presentQRCodeScanner.wrappedValue = true
    }

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        viewControllers?
            .firstIndex(of: viewController)
            .map { setupButton(selectedIndex: $0) }
        if viewModel.selectedIndex != selectedIndex {
            viewModel.selectedIndex = selectedIndex
        }
    }
}

extension UIView {
    func addDropShadow(
        radius: CGFloat = 4.0,
        opacity: Float = 0.4,
        offset: CGSize = CGSize(width: 0.0, height: 1.0),
        color: UIColor = UIColor.darkGray
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}

extension UIView {
    /// Size of view.
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }

    /// Width of view.
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }

    /// Height of view.
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
}
