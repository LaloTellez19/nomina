//
//  DetailsPaymentViewController.swift
//  Adelanto de Nomina
//
//  Created by Miguel Eduardo  Valdez Tellez  on 30/06/21.
//

import UIKit

class DetailsPaymentViewController: UIViewController {

    var conceptText = ""
    var balanceText = ""
    var dateText = ""
    var paymentText = ""
    var conceptImageText = ""

    @IBOutlet weak var conceptImage: UIImageView!
    @IBOutlet weak var conceptLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paymentImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
    }

    func initView() {
        conceptLabel.text = conceptText
        balanceLabel.text = balanceText
        dateLabel.text = dateText
        conceptImage.image = UIImage(named: conceptImageText)
        paymentImage.image = UIImage(named: paymentText)
    }
}
