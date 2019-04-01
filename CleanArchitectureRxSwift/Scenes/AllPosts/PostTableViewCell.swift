import UIKit

final class PostTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!

    func bind(_ viewModel: PostItemViewModel) {
        titleLabel.text = viewModel.title
        detailsLabel.text = viewModel.subtitle
    }
}
