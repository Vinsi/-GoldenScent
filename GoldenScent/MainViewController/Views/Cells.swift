//
//  Cells.swift
//  GoldenScent
//
//  Created by Vinsi on 06/03/2021.
//

import UIKit
import Kingfisher

fileprivate extension String {
    
    var toTextAlignment: NSTextAlignment {
        switch self.lowercased() {
        case "left":
            return .left
        case "right":
            return .right
        case "center":
            return .center
        default:
            return.natural
        }
    }
}

final class ContentCell: UICollectionViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var bottomBarView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImageView.layer.cornerRadius = CGFloat(5.0)
        self.iconImageView.clipsToBounds = true
    }
  
    class ViewModel {
        private(set) var previousIndex: Int?
        var selectedIndex: Int = 0 {
            willSet {
                previousIndex = selectedIndex
            }
        }
        var count: Int {
            switch content {
            case .image(let columns): return columns.count
            case .slider(let data): return data.count
            }
        }
        var content: ContentType
        enum ContentType {
            case image(column: [LayoutDataModel.Row.Column])
            case slider(data:[LayoutDataModel.Row.Column.Slide])
        }
        init(content: ContentType) {
            self.content = content
        }
    }
    
    func configure(viewModel: ViewModel, index: Int) {
        if case .image(let column) = viewModel.content {
            let item = column[index]
            iconImageView.setImage(with: item.src)
            textLabel.text = item.content
            textLabel.textAlignment = item.textAlign?.toTextAlignment ?? .natural
            if let size = item.fontSize {
                textLabel.font = textLabel.font.withSize(CGFloat(size))
            }
            if let hexColor = item.fontColor {
                textLabel.textColor = hexColor.toColor()
            }
            bottomBarView.isHidden = true
            
            contentView.backgroundColor = item.background?.color?.toColor()
        }
        
        if case .slider(let data) = viewModel.content {
            let item = data[index]
            textLabel.isHidden = true
            iconImageView.setImage(with: item.src)
            bottomBarView.isHidden = !(index == viewModel.selectedIndex)
        }
    }
}
