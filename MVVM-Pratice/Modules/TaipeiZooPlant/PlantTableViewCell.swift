//
//  PlantTableViewCell.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import UIKit
import SDWebImage

class PlantTableViewCell: UITableViewCell {
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var featureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(plant: Plant) {
        nameLabel.text = plant.F_Name_Ch
        locationLabel.text = plant.F_Location
        featureLabel.text = plant.F_Location
        plantImageView.sd_setImage(with: URL(string: plant.F_Pic01_URL), placeholderImage: UIImage(named: "cathaybk"))
    }
    
}
