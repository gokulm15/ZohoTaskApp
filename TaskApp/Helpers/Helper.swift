//
//  Helper.swift
//  TaskApp
//
//  Created by gokul on 01/04/24.
//

import UIKit
class HelperClass {
    static let shared = HelperClass()
    private init() {}
    //MARK: - PLACEHOLDER WHEN THE LIST IS EMPTY
    func updatePlaceholder(arrCount: Int, collectionView: UICollectionView, message: String) {
        if arrCount == 0 {
            let placeholderView = PlaceholderView(frame: collectionView.bounds)
            placeholderView.updateMessage(message)
            collectionView.backgroundView = placeholderView
        } else {
            collectionView.backgroundView = nil
        }
    }
    //MARK: - GET UICOLOR TO COLOR CODE
    func colorCode(with color: UIColor) -> String{
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)
        
        let colorCodeLoc = String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
        print("selectedColorCode", colorCodeLoc, color)
        return colorCodeLoc
    }

}

// MARK: - CHANGE DATE FORMAT
struct DateUtils {
    static func changeDateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}
// MARK: - HEX COLOR
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexValue = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexValue.hasPrefix("#") {
            hexValue.remove(at: hexValue.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
//MARK: CARD STYLE
extension UIView {
    func addCardStyle() {
        layer.cornerRadius = 7
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        layer.masksToBounds = false
    }
}
