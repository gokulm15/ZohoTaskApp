//
//  FileUploadVC.swift
//  TaskApp
//
//  Created by gokul on 31/03/24.
//

import UIKit
import PhotosUI
import CoreData
import WebKit
class FilesVC: UIViewController {
    
    @IBOutlet weak var fileUploadCollectionView: UICollectionView!
    var folderDict: DataModel?
    var fetchedDatas = [DataModel]()
    var coreDataManager = CoreDataManager.shared
    var helperClass = HelperClass.shared
    var selectedImgArr = [DataModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        barButtonSetup()
        loadData()
    }
    func uiSetup(){
        self.navigationItem.title = "Images And Documents"
        fileUploadCollectionView.register(UINib(nibName: FOLDERS_COLLECTIONVIEW_CELL, bundle: Bundle.main), forCellWithReuseIdentifier: FOLDERS_COLLECTIONVIEW_CELL)
        fileUploadCollectionView.delegate = self
        fileUploadCollectionView.dataSource = self
    }
    func barButtonSetup(){
        let barBtn = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(fileUpload))
        self.navigationItem.rightBarButtonItem = barBtn
    }
    @objc func fileUpload(){
        let alert = UIAlertController(title: "Alert!", message: "Select Option", preferredStyle: .alert)
        
        let imageAction = UIAlertAction(title: "Select Image", style: .default) { _ in
            self.selectImage()
        }
        let cameraAction = UIAlertAction(title: "Capture Image", style: .default) { _ in
            self.captureImage()
        }
        let documentAction = UIAlertAction(title: "Select Document", style: .default) { _ in
            self.selectFile()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(imageAction)
        alert.addAction(cameraAction)
        alert.addAction(documentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker
    func selectImage() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0 // Allow unlimited selection
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func captureImage() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera is not available")
        }
    }
    func loadData() {
        if let id = folderDict?.folderId{
            ActivityIndicatorManager.shared.showLoader(on: self.view)
            coreDataManager.fetchImages(folderID: id) { fileArr in
                ActivityIndicatorManager.shared.hideLoader(from: self.view)
                self.fetchedDatas = fileArr
                self.helperClass.updatePlaceholder(arrCount: self.fetchedDatas.count, collectionView: self.fileUploadCollectionView, message: LIST_PLACEHOLDER_MESSAGE)
                self.fileUploadCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - Document Picker
    func selectFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
}
extension FilesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UINavigationControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImgArr.count == 0 ? fetchedDatas.count : selectedImgArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FOLDERS_COLLECTIONVIEW_CELL, for: indexPath) as! FoldersCollectionViewCell
        let dict = selectedImgArr.count == 0 ? fetchedDatas[indexPath.row] : selectedImgArr[indexPath.row]
        cell.configureImgAndFiles(with: dict)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: 55)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = selectedImgArr.count == 0 ? fetchedDatas[indexPath.row] : selectedImgArr[indexPath.row]
        showPreview(data: dict.imgDocuments ?? Data())
    }
    //MARK: - PREVIEW IMAGE AND DOCUMENTS
    func showPreview(data: Data) {
        let previewViewController = UIViewController()
        previewViewController.view.backgroundColor = .systemBackground
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.label, for: .normal)
        closeButton.addTarget(self, action: #selector(closePreview), for: .touchUpInside)
        closeButton.frame = CGRect(x: 20, y: 40, width: 60, height: 30)
        previewViewController.view.addSubview(closeButton)

        if let image = UIImage(data: data) {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: previewViewController.view.frame.width, height: previewViewController.view.frame.height)
            previewViewController.view.addSubview(imageView)
        } else {
            
            let webView = WKWebView()
            previewViewController.view.addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                webView.leadingAnchor.constraint(equalTo: previewViewController.view.leadingAnchor, constant: 30),
                webView.topAnchor.constraint(equalTo: previewViewController.view.topAnchor, constant: 100),
                webView.trailingAnchor.constraint(equalTo: previewViewController.view.trailingAnchor, constant: -30),
                webView.bottomAnchor.constraint(equalTo: previewViewController.view.bottomAnchor, constant: -75)
            ])
            
            previewViewController.view.addSubview(webView)
            webView.load(data, mimeType: "application/pdf", characterEncodingName: "", baseURL: NSURL() as URL)
        }
        
        present(previewViewController, animated: true, completion: nil)
    }
    
    @objc func closePreview() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension FilesVC: UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, UIDocumentPickerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)

        let dispatchGroup = DispatchGroup()

        var imageDataArray: [(name: String, data: Data)] = []
        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
                if let url = url {
                    if let imageData = try? Data(contentsOf: url) {
                        let imageName = url.lastPathComponent
                        imageDataArray.append((name: imageName, data: imageData))
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.coreDataManager.saveImages(folderId: self.folderDict?.folderId ?? 0, imagesData: imageDataArray) {
                self.loadData()
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage {
            let timestamp = Date().timeIntervalSince1970
            let imageName = "image_\(timestamp).png"

            if let imageData = image.pngData() {
                self.coreDataManager.saveImages(folderId: self.folderDict?.folderId ?? 0, imagesData: [(name: imageName, data: imageData)]) {
                    self.loadData()
                }
            }
        }
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        dismiss(animated: true, completion: nil)
        let dispatchGroup = DispatchGroup()

        var fileDataArray: [(name: String, data: Data)] = []
        for fileURL in urls {
            dispatchGroup.enter()
            do {
                let fileData = try Data(contentsOf: fileURL)
                let fileName = fileURL.lastPathComponent
                fileDataArray.append((name: fileName, data: fileData))
                dispatchGroup.leave()
            } catch {
                print("Failed to load file data:", error.localizedDescription)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.coreDataManager.saveImages(folderId: self.folderDict?.folderId ?? 0, imagesData: fileDataArray) {
                self.loadData()
            }
        }
    }
    
}
