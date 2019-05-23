import UIKit
import AlamofireImage
import SnapKit

class RemoteImageView: UIImageView {

  lazy var spinner = { () -> UIActivityIndicatorView in
    let view = UIActivityIndicatorView(style: .whiteLarge)
    view.hidesWhenStopped = true
    addSubview(view)
    view.snp.remakeConstraints { make in
      make.center.equalTo(snp.center)
    }
    return view
  }()

  func set(_ url: URL? = nil, filter: ImageFilter? = nil) {
    guard let url = url else { return }
    spinner.startAnimating()
    let size = self.frame.size
    let filter = AspectScaledToFillSizeFilter(size: size)
    af_setImage(
      withURL: url,
      filter: filter,
      progress: { [weak self] latest in
        // ensure animation continues if scrolled off screen
        guard (self?.image == nil) else { return }
        self?.spinner.startAnimating()
      },
      imageTransition: .custom(
        duration: 0.2,
        animationOptions: [.transitionCrossDissolve, .allowUserInteraction],
        animations: { $0.image = $1 }, completion: nil),
      completion: { [weak self] _ in
        self?.spinner.stopAnimating()
    })
  }

}
