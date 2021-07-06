import UIKit

// MARK: Localizable
public protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: XIBLocalizable
public protocol XIBLocalizable {
    var localeKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable public var localeKey: String? {
        get { return nil }
        set(key) {
            text = key?.localized
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable public var localeKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}

// MARK: Special protocol to localizaze UI's placeholder
public protocol UIPlaceholderXIBLocalizable {
    var localePlaceholderKey: String? { get set }
}

extension UITextField: UIPlaceholderXIBLocalizable {

    @IBInspectable public var localePlaceholderKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized
        }
    }

}

extension UISearchBar: UIPlaceholderXIBLocalizable {

    @IBInspectable public var localePlaceholderKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized
        }
    }
}

extension String {
    func isValidEmail() -> Bool {
        let expres = NSLocalizedString(["^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:",
                                        "[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9]",
                                        "(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"].joined(), comment: "")
        guard let regex = try? NSRegularExpression(pattern: expres, options: .caseInsensitive) else {
            fatalError()
        }
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
