import UIKit
import SnapKit

class ImageViewCell: UICollectionViewCell {

  @IBOutlet weak var imageView: RemoteImageView!

  override func prepareForReuse() {
    self.imageView.image = nil
  }

}
