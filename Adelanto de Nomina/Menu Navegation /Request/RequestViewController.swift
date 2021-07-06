//
//  RequestViewController.swift
//  Adelanto de Nomina
//
//  Created by Miguel Eduardo  Valdez Tellez  on 22/06/21.
//

import UIKit
import Alamofire
import IQKeyboardManagerSwift

class RequestViewController: UIViewController {

    #if LOCAL
    let token = "pruebas"
    #elseif PRO
    let token = "07bd8da6-9e95-4bb1-b460-3ff48cf64d83"
    #endif

    var estados: [String] = []
    var municipios: [String] = []
    var colonias: [String] = []
    let allowedCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvxyz.-_@").inverted
    let url = "https://api.copomex.com/query"
    let tokenString = "?token="
    let urlEstados = "/get_estados"
    let urlMunicipio = "/get_municipio_por_estado/"
    let urlColonia = "/get_colonia_por_cp/"
    var activeTextField = UITextField()

    @IBOutlet weak var swithRequerid: UILabel!
    @IBOutlet weak var suburdRequed: UILabel!
    @IBOutlet weak var delegationRequed: UILabel!
    @IBOutlet weak var stateRequed: UILabel!
    @IBOutlet weak var dateRequed: UILabel!
    @IBOutlet weak var streetRequired: UILabel!
    @IBOutlet weak var switgRequest: UISwitch!
    @IBOutlet weak var pointFameOutlet: UIImageView!
    @IBOutlet weak var malePointOutlet: UIImageView!
    @IBOutlet weak var femeButtonOutlet: UIButton!
    @IBOutlet weak var maleButtonOutlet: UIButton!
    @IBOutlet weak var streetRequed: UITextField!
    @IBOutlet weak var postalCodeRequed: UILabel!
    @IBOutlet weak var phoneRequed: UILabel!
    @IBOutlet weak var emailRequed: UILabel!
    @IBOutlet weak var lastNameRequed: UILabel!
    @IBOutlet weak var nameRequed: UILabel!
    @IBOutlet weak var datePicker: DatePickerTextField!
    @IBOutlet weak var suburbPicker: PickerViewTextField!
    @IBOutlet weak var statePicker: PickerViewTextField!
    @IBOutlet weak var privaLabel: UILabel!
    @IBOutlet weak var delegationPicker: PickerViewTextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var codePostalTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        loader()
        initView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func codePostalTextField(_ sender: Any) {
        if codePostalTextField.text?.count == 5 {
            if let codigo = codePostalTextField.text {
                loader()
                getColonia(colonia: codigo)
            }
        }
    }
    @IBAction func fameAcction(_ sender: Any) {
        malePointOutlet.isHidden = true
        pointFameOutlet.isHidden = false
    }

    @IBAction func maleAction(_ sender: Any) {
        malePointOutlet.isHidden = false
        pointFameOutlet.isHidden = true
    }

    @IBAction func AcceptButtonAction(_ sender: Any) {
        if let name = nameTextField.text, !name.isEmpty,
           let lastName = lastNameTextField.text, !lastName.isEmpty,
           let email = emailTextField.text, !email.isEmpty,
           let phone = phoneTextField.text, !phone.isEmpty,
           let date = datePicker.text, !date.isEmpty,
           let code = codePostalTextField.text, !code.isEmpty,
           let state = statePicker.text, !state.isEmpty,
           let delagation = delegationPicker.text, !delagation.isEmpty,
           let suburd = suburbPicker.text, !suburd.isEmpty,
           let street = streetTextField.text, !street.isEmpty {
            if switgRequest.isOn {
                let controller = UIAlertController(title: NSLocalizedString("REQUEST_OK", comment: ""),
                                           message: NSLocalizedString("REQUEST_MESS", comment: ""), preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: someHandler))
                self.present(controller, animated: true)
            } else {
                swithRequerid.isHidden = false
            }
        } else {
            if let name = nameTextField.text, name.isEmpty {
                nameRequed.isHidden = false
            }
            if let lastName = lastNameTextField.text, lastName.isEmpty {
                lastNameRequed.isHidden = false
            }
            if let code = codePostalTextField.text, code.isEmpty {
                postalCodeRequed.isHidden = false
            }
            if let state = statePicker.text, state.isEmpty {
                stateRequed.isHidden = false
            }
            if let suburd = suburbPicker.text, suburd.isEmpty {
                suburdRequed.isHidden = false
            }
            if let delegation = delegationPicker.text, delegation.isEmpty {
                delegationRequed.isHidden = false
            }
            if let email = emailTextField.text, email.isEmpty {
                emailRequed.isHidden = false
            }
            if let phone = phoneTextField.text, phone.isEmpty {
                phoneRequed.isHidden = false
            }
            if let date = datePicker.text, date.isEmpty {
                dateRequed.isHidden = false
            }
            if let street = streetTextField.text, street.isEmpty {
                streetRequired.isHidden = false
            }
        }
    }

    func initView() {
        self.hideKeyboardWhenTappedAround()
        getState()
        statePicker.initialize()
        delegationPicker.initialize()
        suburbPicker.initialize()
        datePicker.initialize()
        codePostalTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        nameTextField.delegate = self
        lastNameTextField.delegate = self
        nameTextField.placeholder = NSLocalizedString("NAMES", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("LAST_NAME", comment: "")
        emailTextField.placeholder = NSLocalizedString("EMAIL", comment: "")
        phoneTextField.placeholder = NSLocalizedString("PHONE", comment: "")
        streetTextField.placeholder = NSLocalizedString("STREET", comment: "")
        privaLabel.text = NSLocalizedString("ACEPT_PRY", comment: "")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func someHandler(alert: UIAlertAction!) {
        tabBarController?.selectedIndex = 1
    }

    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -200
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }

    func anotherMethod() {

         // self.activeTextField.text is an optional, we safely unwrap it here
         if let activeTextFieldText = self.activeTextField.text {
               print("Active text field's text: \(activeTextFieldText)")
               return
         }

         print("Active text field is empty")
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

    func getState() {
        AF.request("\(url)\(urlEstados)\(tokenString)\(token)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let jsonData = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let state = try jsonDecoder.decode(Estados.self, from: jsonData)
                        self.estados = state.response.estado
                        self.statePicker.pickOptions = self.estados.map({$0})
                        self.statePicker.closure = { _ in }
                        self.statePicker.addRightLeftOnKeyboardWithTarget(self, leftButtonTitle: "Cerrar",
                                                                          rightButtonTitle: "Agregar",
                                                                          leftButtonAction: #selector(self.closePicker),
                                                                          rightButtonAction: #selector(self.addState))
                        self.statePicker.initialize()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc func addState() {
        guard let muni = statePicker.text else { return }
        getMunicipio(municipio: muni)
        statePicker.resignFirstResponder()
    }

    @objc func closePicker() {
        statePicker.resignFirstResponder()
        delegationPicker.resignFirstResponder()
        suburbPicker.resignFirstResponder()
    }

    @objc func addDelegation() {
        delegationPicker.resignFirstResponder()
    }

    @objc func addSubur() {
        delegationPicker.resignFirstResponder()
    }

    func nextTextField(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            phoneTextField.becomeFirstResponder()
        default:
            lastNameTextField.resignFirstResponder()
        }
    }

    func alertCustom(keyTitle: String, keyMessage: String, keyButton: String) {
        let controller = UIAlertController(title: NSLocalizedString(keyTitle, comment: ""),
                                   message: NSLocalizedString(keyMessage, comment: ""), preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: NSLocalizedString(keyButton, comment: ""), style: .default))
        self.present(controller, animated: true)
    }

    func getMunicipio(municipio: String) {
        AF.request("\(url)\(urlMunicipio)\(municipio)\(tokenString)\(token)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let jsonData = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let municipios = try jsonDecoder.decode(Municipios.self, from: jsonData)
                        self.municipios = municipios.response.municipios
                        self.delegationPicker.pickOptions = self.municipios.map({$0})
                        self.delegationPicker.closure = { _ in }
                        self.delegationPicker.addRightLeftOnKeyboardWithTarget(self, leftButtonTitle: "Cerrar",
                                                                               rightButtonTitle: "Agregar",
                                                                               leftButtonAction: #selector(self.closePicker),
                                                                               rightButtonAction: #selector(self.addDelegation))
                        self.delegationPicker.initialize()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func getColonia(colonia: String) {
        AF.request("\(url)\(urlColonia)\(colonia)\(tokenString)\(token)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let jsonData = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let colonias = try jsonDecoder.decode(Colonias.self, from: jsonData)
                        self.colonias = colonias.response.colonia
                        self.suburbPicker.pickOptions = self.colonias.map({$0})
                        self.suburbPicker.closure = { _ in }
                        self.suburbPicker.addRightLeftOnKeyboardWithTarget(self, leftButtonTitle: "Cerrar",
                                                                           rightButtonTitle: "",
                                                                           leftButtonAction: #selector(self.closePicker),
                                                                           rightButtonAction: #selector(self.addSubur))
                        self.suburbPicker.initialize()
                        self.dismiss(animated: false, completion: nil)
                    } catch _ {
                        self.dismiss(animated: false, completion: nil)
                    }
                }
            case .failure(_):
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}

extension RequestViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {return true}
        let components = string.components(separatedBy: allowedCharacters)
        let filtered = components.joined(separator: "")
        if string == filtered {
            return true
        } else {
            return false
        }
        let newLengt = text.count + string.count - range.length
        switch textField {
        case codePostalTextField:
            return newLengt <= 5
        default:
            return newLengt <= 100
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nextTextField(textField)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
}
