//
//  CreateAccountViewController.swift
//  Adelanto de Nomina
//
//  Created by Miguel Eduardo  Valdez Tellez  on 21/06/21.
//

import UIKit
import CoreData
import FirebaseAuth

class CreateAccountViewController: UIViewController {

    let allowedCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvxyz.-_@ ").inverted
    let storeCheck = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$")
    var account: [NSManagedObject] = []
    @IBOutlet weak var requeridStore: UILabel!
    @IBOutlet weak var requeridEmailConfirm: UILabel!
    @IBOutlet weak var requeridEmail: UILabel!
    @IBOutlet weak var requeridName: UILabel!
    @IBOutlet weak var storeTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var emailTextFieldText: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        fullNameTextField.delegate = self
        emailTextFieldText.delegate = self
        confirmEmailTextField.delegate = self
        storeTextField.delegate = self
        fullNameTextField.placeholder = NSLocalizedString("NAME", comment: "")
        emailTextFieldText.placeholder = NSLocalizedString("EMAIL", comment: "")
        confirmEmailTextField.placeholder = NSLocalizedString("CONFIRM_EMAIL", comment: "")
        // Listen events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func storageValide(_ sender: Any) {
        if storeCheck.evaluate(with: storeTextField.text) == true {
            requeridStore.isHidden = false
            requeridStore.text = NSLocalizedString("VALID", comment: "")
            requeridStore.textColor = .green
        } else {
            requeridStore.isHidden = false
            requeridStore.text = NSLocalizedString("INVALID", comment: "")
        }
    }
    @IBAction func createAccountButton(_ sender: Any) {
        if let name = fullNameTextField.text, !name.isEmpty,
           let email = emailTextFieldText.text, !email.isEmpty,
           let confirmEmail = confirmEmailTextField.text, !confirmEmail.isEmpty,
           let storage = storeTextField.text, !storage.isEmpty {
            if  email.isValidEmail() {
                Auth.auth().createUser(withEmail: email, password: storage) { result, error in
                    if let result = result, error == nil {
                        let controller = UIAlertController(title: NSLocalizedString("CREATE_ACCOUNT", comment: ""),
                                                           message: NSLocalizedString("LOGIN", comment: ""), preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                                           style: .default, handler: self.someHandler))
                        print(result)
                        self.present(controller, animated: true)
                    } else {
                        self.alertCustom(keyTitle: "NO_REGISTER", keyMessage: "AGAIN", keyButton: "OK")
                    }
                }
            } else {
                requeridEmail.isHidden = false
                requeridEmail.text = NSLocalizedString("inValid", comment: "")
            }
        } else {
            if let name = fullNameTextField.text, name.isEmpty {
                requeridName.isHidden = false
            }
            if let email = emailTextFieldText.text, email.isEmpty {
                requeridEmail.isHidden = false
            }
            if let confirmEmail = confirmEmailTextField.text, confirmEmail.isEmpty {
                requeridEmailConfirm.isHidden = false
            }
            if let pass = storeTextField.text, pass.isEmpty {
                requeridStore.isHidden = false
            }
        }
    }
    @IBAction func loginButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -100
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0
    }

    func someHandler(alert: UIAlertAction!) {
        dismiss(animated: true, completion: nil)
    }

    func alertCustom(keyTitle: String, keyMessage: String, keyButton: String) {
        let controller = UIAlertController(title: NSLocalizedString(keyTitle, comment: ""),
                                   message: NSLocalizedString(keyMessage, comment: ""), preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: NSLocalizedString(keyButton, comment: ""), style: .default))
        self.present(controller, animated: true)
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

    func nextTextField(_ textField: UITextField) {
        switch textField {
        case fullNameTextField:
            emailTextFieldText.becomeFirstResponder()
        case emailTextFieldText:
            confirmEmailTextField.becomeFirstResponder()
        case confirmEmailTextField:
            storeTextField.becomeFirstResponder()
        default:
            storeTextField.resignFirstResponder()
        }
    }

    func save(user: String, storage: String) {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Accounts",
                                       in: managedContext)!
        let person = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        person.setValue(user, forKeyPath: "user")
        person.setValue(storage, forKey: "storage")
        do {
            try managedContext.save()
            account.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension CreateAccountViewController: UITextFieldDelegate {
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
