//
//  CardTableViewCell.swift
//  CardList
//
//  Created by Venu on 21/02/22.
//

import UIKit
import LocalAuthentication

protocol CardCellDelegate {
    func updateCVV(isSuccess:Bool)
}

class CardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverView: UIView! {
        
        didSet {
            coverView.layer.cornerRadius = 10
            coverView.layer.borderColor = UIColor.lightGray.cgColor
            coverView.layer.borderWidth = 2.0
//            coverView.dropShadow()
        }
    }
    
    @IBOutlet weak var cvvLbl: UILabel!
    @IBOutlet weak var switchAccess: UISwitch!
    @IBOutlet weak var bankImageView: UIImageView! {
        
        didSet {
            
            bankImageView.layer.cornerRadius = 10
        }
    }
    var delegate: CardCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        
        self.delegate?.updateCVV(isSuccess: false)
        
    }
    
}

