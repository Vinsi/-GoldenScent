//
//  Utility.swift
//  GoldenScent
//
//  Created by Vinsi on 05/03/2021.
//

import Foundation
import UIKit
import Kingfisher

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    func toColor( alpha: CGFloat = 1.0) -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
       return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
extension UIImageView {
    
    func setImage(with urlString: String?, placeholderImage: UIImage? = nil, shouldEncodeUrl: Bool = true) {
        let encodedUrlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: shouldEncodeUrl ? encodedUrlString : (urlString ?? ""))
        kf.setImage(with: url,
                    placeholder: placeholderImage,
                    options: [.transition(ImageTransition.fade(0.2))])
    }
}

class JSONUtility {
    
    func dataFromFile(named fileName: String) throws ->  Data? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            return nil
        }
        return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    }
    
    func decodeFromJson<T:Codable>(named fileName: String, type: T.Type) throws -> T? {
        guard let data = try dataFromFile(named: fileName) else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

protocol SegueIdentifiable {
    
    var identifier: String { get }
}

extension SegueIdentifiable where Self: RawRepresentable, Self.RawValue == String {
    var identifier: String {
        return rawValue
    }
}

extension UIViewController {
    func performSegue(segue: SegueIdentifiable, sender: Any?) {
        performSegue(withIdentifier: segue.identifier, sender: sender)
    }
}

extension UIStoryboard {
    
    /// The uniform place where we state all the storyboard we have in our application
    
    enum Storyboard: String {
        case main = "Main"
        
        var filename: String {
            return rawValue
        }
    }
    
    // MARK: - Convenience Initializers
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }
    
    // MARK: - View Controller Instantiation from Generics
    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        return viewController
    }
}



