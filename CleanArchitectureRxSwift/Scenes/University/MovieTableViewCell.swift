//
//  MovieTableViewCell.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import UIKit
import Domain
class MovieTableViewCell: UITableViewCell {

    static let nib = UINib(nibName: "MovieTableViewCell", bundle: .main)
    static let identifier = "MovieTableViewCell"
    
    @IBOutlet weak var ivMovie: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var vMain: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ivMovie.contentMode = .scaleToFill
        self.ivMovie.layer.cornerRadius = 10
        self.vMain.layer.shadowRadius = 8.0
        self.vMain.layer.shadowOpacity = 0.3
        self.vMain.layer.cornerRadius = 8
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
 
    func binding(data: UniversityModel) {
        self.lblTitle.text = data.name 
        self.lblSubTitle.text = data.country
    }
}

extension UIImageView {
    public func k_setImageWithUrl(url: URL, placeHolder: UIImage? = nil, showLoading: Bool = false, resize:CGSize? = nil) {
//        let indicator = UIActivityIndicatorView(style: .large)
//        indicator.tintColor = .blue
//        indicator.color = .gray
//        self.addSubview(indicator)
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        self.contentMode = .center
//        if showLoading {
//            indicator.startAnimating()
//        }
//        self.image = placeHolder
//        ImageDownloadManager.shared.dowLoadImage(url: url) { image, url, indexPath, error in
//            DispatchQueue.main.async {
//                indicator.stopAnimating()
//                self.image = image
//            }
//            if error != nil {
//                DispatchQueue.main.async {
//                    self.image = placeHolder
//                    indicator.stopAnimating()
//                }
//            }
//        }
    }
}
