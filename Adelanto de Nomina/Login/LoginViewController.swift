//
//  LoginViewController.swift
//  Adelanto de Nomina
//
//  Created by Miguel Eduardo  Valdez Tellez  on 18/06/21.
//

import UIKit
import LocalAuthentication
import CoreData
import Alamofire
import FirebaseAuth

class LoginViewController: UIViewController {

    let allowedCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvxyz.-_@").inverted
    let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: UIColor(red: 104/255, green: 172/255, blue: 174/255, alpha: 1),
        .underlineStyle: NSUnderlineStyle.single.rawValue]

    @IBOutlet weak var politicasOultlet: UIButton!
    @IBOutlet weak var requeridStorage: UILabel!
    @IBOutlet weak var requeridEmail: UILabel!
    @IBOutlet weak var StorageTextField: UITextField!
    @IBOutlet var correoTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func loginButton(_ sender: Any) {
        if let correo = correoTextField.text, !correo.isEmpty,
           let storage = StorageTextField.text, !storage.isEmpty {
            // Campos llenados
            if correo.isValidEmail() {
                Auth.auth().signIn(withEmail: correo, password: storage) { result, error in
                    if let result = result, error == nil {
                        let context = LAContext()
                        var error: NSError?
                        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                            let reason = "Identify yourself!"
                            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                   localizedReason: reason) { [weak self] success, _ in DispatchQueue.main.async {
                                if success {
                                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                                    guard let controller = storyboard.instantiateViewController(withIdentifier:
                                                                                                    "Home") as? HomeTabViewController else {
                                        fatalError()
                                    }
                                    controller.modalPresentationStyle = .fullScreen
                                    self?.present(controller, animated: true, completion: nil)
                                } else {
                                    // error
                                    self?.alertCustom(keyTitle: "AUTHE_FAILED", keyMessage: "NO_AUTH", keyButton: "OK")
                                }
                            }
                            }
                        } else {
                            // no biometry
                            let storyboard = UIStoryboard(name: "Home", bundle: nil)
                            guard let controller = storyboard.instantiateViewController(withIdentifier:
                                                                                            "Home") as? HomeTabViewController else {
                                fatalError()
                            }
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: true, completion: nil)
                        }
                    } else {
                        self.alertCustom(keyTitle: "LOGIN_INCORRECT", keyMessage: "VERIFED", keyButton: "ACEPT")
                    }
                }
            } else {
                requeridEmail.isHidden = false
                requeridEmail.text = NSLocalizedString("inValid", comment: "")
            }
        } else {
            if let correo = correoTextField.text, correo.isEmpty {
                requeridEmail.isHidden = false
            }
            if let pass = StorageTextField.text, pass.isEmpty {
                requeridStorage.isHidden = false
            }
        }
    }

    @IBAction func politicasAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    @IBAction func createButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CreateAccount", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "Create") as? CreateAccountViewController else {
            fatalError()
        }
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }

    func initView() {
        self.hideKeyboardWhenTappedAround()
        let attributeString = NSMutableAttributedString(string: NSLocalizedString("CHANGE", comment: ""),
                                                        attributes: attributes)
        correoTextField.delegate = self
        StorageTextField.delegate = self
        politicasOultlet.setAttributedTitle(attributeString, for: .normal)
        correoTextField.placeholder = NSLocalizedString("EMAIL", comment: "")
    }

    func loader() {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("WAIT", comment: ""), preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -50
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }

    func alertCustom(keyTitle: String, keyMessage: String, keyButton: String) {
        let controller = UIAlertController(title: NSLocalizedString(keyTitle, comment: ""),
                                           message: NSLocalizedString(keyMessage, comment: ""), preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: NSLocalizedString(keyButton, comment: ""), style: .default))
        self.present(controller, animated: true)
    }

    func nextTextField(_ textField: UITextField) {
        switch textField {
        case correoTextField:
            StorageTextField.becomeFirstResponder()
        case StorageTextField:
            StorageTextField.resignFirstResponder()
        default:
            correoTextField.resignFirstResponder()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        correoTextField.text = ""
        StorageTextField.text = ""
        requeridEmail.isHidden = true
        requeridStorage.isHidden = true
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let components = string.components(separatedBy: allowedCharacters)
        let filtered = components.joined(separator: "")
        if string == filtered {
            return true
        } else {
            return false
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nextTextField(textField)
        return true
    }
}
