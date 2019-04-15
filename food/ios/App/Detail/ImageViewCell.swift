import UIKit

class ImageViewCell: UICollectionViewCell {

  @IBOutlet weak var imageView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func prepareForReuse() {
    self.imageView.image = nil
  }

}
