//
//  NotesCollectionViewCell.swift
//  TaskApp
//
//  Created by gokul on 30/03/24.
//

import UIKit

class FoldersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var folderImg: UIImageView!
    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var folderDate: UILabel!
    var favouriteTap: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configure(with dict: DataModel) {
            favouriteBtn.isHidden = false
           folderName.text = dict.folderName
        let formattedDate = DateUtils.changeDateFormat(date: dict.createdDate ?? Date())
           folderDate.text = "\(formattedDate)"
        folderImg.tintColor = UIColor(hex: dict.folderColor ?? "#FFFFFF")
           favouriteBtn.tintColor = dict.isFavourite == 1 ? .systemYellow : .systemGray
           let starImageName = dict.isFavourite == 1 ? "star.fill" : "star"
           favouriteBtn.setImage(UIImage(systemName: starImageName)?.withTintColor(favouriteBtn.tintColor, renderingMode: .alwaysOriginal), for: .normal)
       }
    func configureImgAndFiles(with dict: DataModel) {
        folderName.text = dict.fileName
        let formattedDate = DateUtils.changeDateFormat(date: dict.createdAt ?? Date())
        folderDate.text = formattedDate
        if let img = UIImage(data: dict.imgDocuments ?? Data()){
            folderImg.image = img
        }else{
            folderImg.image = UIImage(systemName: "doc.text")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        }
        
        favouriteBtn.isHidden = true
    }
    
    @IBAction func favouriteBtnAction(_ sender: Any) {
        favouriteTap?()
    }
}
