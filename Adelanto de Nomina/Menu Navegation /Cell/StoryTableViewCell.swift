//
//  StoryTableViewCell.swift
//  Adelanto de Nomina
//
//  Created by Miguel Eduardo  Valdez Tellez  on 22/06/21.
//

import UIKit

class StoryTableViewCell: UITableViewCell {

    static let reuseIdentifier = "Payment"
    static let nib = UINib(nibName: StoryTableViewCell.reuseIdentifier, bundle: nil)

    @IBOutlet weak var medioPagoImage: UIImageView!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var conceptoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
