//
//  ListTableViewCell.swift
//  CardList
//
//  Created by Venu on 21/02/22.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var budgetIdLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
