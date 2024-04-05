//
//  ViewController.swift
//  TaskApp
//
//  Created by gokul on 30/03/24.
//

import UIKit
import CoreData
class FoldersVC: UIViewController {
    
    @IBOutlet weak var foldersCollectionView: UICollectionView!
    var folderArr = [DataModel]()
    var filteredFolderArr = [DataModel]()
    var coreDataManager = CoreDataManager.shared
    var helperClass = HelperClass.shared
    var imagesDocumentsArr = [DataModel]()
    lazy var foldersTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FOLDER_CELL)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter the folder name..."
        searchBar.delegate = self
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        barButtonSetup()
        searchBarConfig()
        uiTableSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataConfig()
        loadImgDocData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.text = ""
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    //MARK: - GET FOLDER LIST
    func dataConfig(){
        coreDataManager.getFolders { data in
            self.folderArr = data
            
            self.helperClass.updatePlaceholder(arrCount: self.folderArr.count, collectionView: self.foldersCollectionView, message: NO_FOLDERS_AVAILABLE_MESSAGE)
            self.foldersCollectionView.reloadData()
        }
    }
    func loadImgDocData(){
        self.coreDataManager.fetchImages(folderID: 0, getAllData: true) { arr in
            self.imagesDocumentsArr = arr
        }
    }
    func uiSetup(){
        foldersCollectionView.register(UINib(nibName: FOLDERS_COLLECTIONVIEW_CELL, bundle: Bundle.main), forCellWithReuseIdentifier: FOLDERS_COLLECTIONVIEW_CELL)
        foldersCollectionView.delegate = self
        foldersCollectionView.dataSource = self
        foldersCollectionView.keyboardDismissMode = .onDrag
    }
    
    func barButtonSetup(){
        let barBtn = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addFolderAction))
        let sortBarBtn = UIBarButtonItem(image: UIImage(systemName: "square.grid.3x1.below.line.grid.1x2"), style: .plain, target: self, action: #selector(sortAction))
        self.navigationItem.rightBarButtonItems = [barBtn,sortBarBtn]
    }
    
    func uiTableSetup() {
        view.addSubview(foldersTableView)
        NSLayoutConstraint.activate([
            foldersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            foldersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            foldersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            foldersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    //MARK: - SORTING FODER BASED FOLDER NAME AND FOLDER
    @objc func sortAction() {
        let alert = UIAlertController(title: "Alert!", message: SORTING_MESSAGE, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Name", style: .default, handler: { _ in
            self.sortByFolderName()
        }))

        alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { _ in
            self.sortByCreationDate()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        self.present(alert, animated: true)
    }

    func sortByFolderName() {
        folderArr.sort { (firstFolder, secondFolder) -> Bool in
            return firstFolder.folderName?.lowercased() ?? "" < secondFolder.folderName?.lowercased() ?? ""
        }
        self.foldersCollectionView.reloadData()
    }

    func sortByCreationDate() {
        folderArr.sort { (firstFolder, secondFolder) -> Bool in
            return firstFolder.createdDate ?? Date() < secondFolder.createdDate ?? Date()
        }
        self.foldersCollectionView.reloadData()
    }

    
    @objc func addFolderAction(){

        let vc = self.storyboard?.instantiateViewController(withIdentifier: ADD_FOLDER_CONTROLLER) as! AddFolderVC
        let rootVC = UINavigationController(rootViewController: vc)
        rootVC.modalPresentationStyle = .fullScreen
        self.present(rootVC, animated: true)
    }
    func searchBarConfig(){
        navigationItem.titleView = searchBar
    }
    
}

extension FoldersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UISearchBarDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folderArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FOLDERS_COLLECTIONVIEW_CELL, for: indexPath) as! FoldersCollectionViewCell
        var dict = folderArr[indexPath.row]

        cell.configure(with: dict)

        updateFavouriteButton(for: cell, isFavourite: dict.isFavourite ?? 0)

        cell.favouriteTap = {
            dict.isFavourite = dict.isFavourite == 1 ? 0 : 1
            self.folderArr[indexPath.row] = dict
            self.coreDataManager.addFavourite(folderId: dict.folderId ?? 0, isFavourite: dict.isFavourite ?? 0) {
                
                self.updateFavouriteButton(for: cell, isFavourite: dict.isFavourite ?? 0)
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: 55)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = folderArr[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(identifier: FILES_CONTROLLER) as! FilesVC
        vc.folderDict = dict
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UPDATE FAVOURITE BUTTON
    func updateFavouriteButton(for cell: FoldersCollectionViewCell, isFavourite: Int) {
        cell.favouriteBtn.isSelected = isFavourite == 1
        cell.favouriteBtn.tintColor = isFavourite == 1 ? .systemYellow : .systemGray
        let starImageName = isFavourite == 1 ? "star.fill" : "star"
        cell.favouriteBtn.setImage(UIImage(systemName: starImageName)?.withTintColor(cell.favouriteBtn.tintColor ?? .systemGray, renderingMode: .alwaysOriginal), for: .normal)
    }
}
//MARK: - FILTER FOLDER LIST
extension FoldersVC: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFolderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FOLDER_CELL, for: indexPath)
        let folder = filteredFolderArr[indexPath.row]
        cell.textLabel?.text = folder.folderName != nil ? folder.folderName : folder.fileName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFolder = filteredFolderArr[indexPath.row]
        self.foldersTableView.isHidden = true
        self.foldersCollectionView.isHidden = false
        let folder = filteredFolderArr[indexPath.row]
        if folder.folderName != nil{
            let filteredData = folderArr.filter { $0.folderId == selectedFolder.folderId }
            if let selectedFolderData = filteredData.first {
                // Show related records in collection view
                folderArr = [selectedFolderData]
                self.foldersCollectionView.reloadData()
            }
        }else{
            let filteredData = filteredFolderArr.filter { $0.fileName == selectedFolder.fileName }
            if let selectedFolderData = filteredData.first {
                // Show related records in collection view
                let vc = self.storyboard?.instantiateViewController(identifier: FILES_CONTROLLER) as! FilesVC
                vc.selectedImgArr = [selectedFolderData]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true) // Dismiss the keyboard
    }
}

// MARK: - SEARCH FOLDERS
extension FoldersVC {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.lowercased()
        if searchText.isEmpty {
            self.foldersTableView.isHidden = true
            // If the search text is empty, reload the original data
            dataConfig()
        } else {
            // Filter the array based on the search text
            filteredFolderArr = folderArr.filter { $0.folderName?.lowercased().contains(searchText) ?? false } + imagesDocumentsArr.filter { $0.fileName?.lowercased().contains(searchText) ?? false }
            print("totCountsss",filteredFolderArr.count)
            self.foldersTableView.isHidden = filteredFolderArr.isEmpty
        }
        self.foldersTableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

