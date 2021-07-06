//
//  PickerViewTextField.swift
//  encuentro
//
//  Created by Edgar Hernandez Solis on 03/10/20.
//  Copyright © 2020 Linko. All rights reserved.
//

import Foundation
import UIKit

class PickerViewTextField: UITextField {
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    let pickerView = UIPickerView()
    var pickOptions: [String] = []
    var closure: ((_ index: Int) -> Void)? = { _ in }
    var didSelectRow: ((_ index: Int) -> Void)? = { _ in }
    var didBeginEditing: (() -> Void)? = {}
    var didEndEditing: (() -> Void)? = {}
    var closureOnChange = false
    func initialize() {
        self.tintColor = .clear
        self.delegate = self
        self.pickerView.delegate = self
        self.inputView = self.pickerView
    }
    func reloadComponents() {
        self.pickerView.reloadAllComponents()
    }
}

extension PickerViewTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing?()
        if !self.pickOptions.isEmpty {
            if self.text?.isEmpty ?? false {
                let index = (self.pickerView.selectedRow(inComponent: 0) + 1) >
                    self.pickOptions.count ? 0 : self.pickerView.selectedRow(inComponent: 0)
                self.text = self.pickOptions[index]
                closure?(index)
            } else {
                if let index = self.pickOptions.firstIndex(of: self.text ?? "") {
                    self.pickerView.selectRow(index, inComponent: 0, animated: true)
                    closure?(index)
                }
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        didEndEditing?()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return pickOptions.contains(string)
    }
}

extension PickerViewTextField: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if closureOnChange {
            closure?(row)
        }
        return self.pickOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = (self.text?.isEmpty ?? true) ? nil : self.pickOptions[row]
        // didSelectRow?(row)
        closure?(row)
    }
}
