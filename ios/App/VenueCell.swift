//
//  VenueCell.swift
//  Benji
//
//  Created by Ajay Chainani on 8/30/18.
//  Copyright © 2018 Lenfest. All rights reserved.
//

import UIKit
import AlamofireImage

class VenueCell: UICollectionViewCell {
  
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var articleButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    containerView.layer.cornerRadius = 5.0
    containerView.clipsToBounds = true
    containerView.layer.borderColor = UIColor.lightGray.cgColor
    containerView.layer.borderWidth = 1

    articleButton.layer.cornerRadius = 5.0
    articleButton.clipsToBounds = true
    
  }
  
  func attributedText(text: String, font: UIFont) -> NSMutableAttributedString {
    let attributedString = NSMutableAttributedString(string: text)
    let paragraphStyle = NSMutableParagraphStyle()
    
    // *** set LineSpacing property in points ***
    paragraphStyle.lineSpacing = 5 // Whatever line spacing you want in points
    
    // *** Apply attribute to string ***
    attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
    attributedString.addAttribute(NSAttributedStringKey.font, value:font, range:NSMakeRange(0, attributedString.length))
    
    return attributedString
  }
  
  func setVenue(venue: Venue) {
    let text = NSMutableAttributedString(string: "")
    let title = self.attributedText(text: String(format: "%@\n", venue.title!), font: UIFont.boldSystemFont(ofSize: 16))
    let blurb = self.attributedText(text: venue.blurb!, font: UIFont.systemFont(ofSize: 14))
    text.append(title)
    text.append(blurb)
    self.textLabel.attributedText = text
    
    if venue.images?.count ?? 0 > 0 {
      let url = venue.images![0]
      self.imageView.af_setImage(withURL: url)
    }
    
  }
  
}
