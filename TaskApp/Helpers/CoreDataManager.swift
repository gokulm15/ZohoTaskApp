//
//  CoreDataManager.swift
//  TaskApp
//
//  Created by gokul on 01/04/24.
//

import Foundation
import UIKit
import CoreData
class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    //MARK: - SAVE IMAGES
    func saveImages(folderId: Int, imagesData: [(name: String, data: Data)], completion: @escaping() -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for imageData in imagesData {
            let imageName = imageData.name
            let imageData = imageData.data
            
            if let entity = NSEntityDescription.entity(forEntityName: IMAGES_ENTITY, in: managedContext) {
                let imageObject = NSManagedObject(entity: entity, insertInto: managedContext)
                imageObject.setValue(imageData, forKey: "imgDocuments")
                imageObject.setValue(folderId, forKey: "folderId")
                imageObject.setValue(imageName, forKey: "fileName")
                let uuidString = UUID().uuidString
                imageObject.setValue(1, forKey: "imgId")
                imageObject.setValue(Date(), forKey: "createdAt")
            }
        }
        
        do {
            try managedContext.save()
            completion()
        } catch let error as NSError {
            print("Could not save images. \(error), \(error.userInfo)")
        }
    }
    //MARK: - ADD FAVOURITE
    func addFavourite(folderId: Int, isFavourite: Int, completion: @escaping() -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FOLDERS_ENTITY)
        fetchRequest.predicate = NSPredicate(format: "folderId == %d", folderId)
        
        do {
            if let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject], let folder = results.first {
                folder.setValue(isFavourite, forKey: "isFavourite")
            } else {

                print("Folder with ID \(folderId) not found.")
                completion()
                return
            }
            
            try managedContext.save()
            completion()
        } catch let error as NSError {
            print("Could not update isFavourite attribute. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - FETCH IMAGES
    func fetchImages(folderID: Int, getAllData: Bool = false, completion: @escaping ([DataModel]) -> Void) {
        var imagesData = [DataModel]()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(imagesData)
            return
        }
        
        let managedContext = appDelegate.persistentContainer.newBackgroundContext()
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: IMAGES_ENTITY)
            if !getAllData{
                fetchRequest.predicate = NSPredicate(format: "folderId == %d", folderID)
            }
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                
                for data in result as! [NSManagedObject] {
                    if let imgId = data.value(forKey: "imgId") as? Int,
                       let folderId = data.value(forKey: "folderId") as? Int,
                       let createdAt = data.value(forKey: "createdAt") as? Date,
                       let fileName = data.value(forKey: "fileName") as? String {
                        
                        // Load image data asynchronously
                        let imgDocuments = data.value(forKey: "imgDocuments") as? Data ?? Data()
                        
                        let imageData = DataModel(folderId: folderId, imgId: imgId,
                                                    imgDocuments: imgDocuments,
                                                             createdAt: createdAt,
                                                             fileName: fileName)
                        
                        imagesData.append(imageData)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(imagesData)
                }
            } catch {
                print("Error fetching images: \(error)")
                DispatchQueue.main.async {
                    completion(imagesData)
                }
            }
        }
    }

//MARK: - GET FOLDERS
    func getFolders(completion: @escaping ([DataModel]) -> Void) {
        print("called")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion([])
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FOLDERS_ENTITY)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            var folderArr = [DataModel]()
            
            for data in result as! [NSManagedObject] {
                if let folderId = data.value(forKey: "folderId") as? Int,
                   let folderName = data.value(forKey: "folderName") as? String,
                   let folderColor = data.value(forKey: "folderColor") as? String,
                   let createdDate = data.value(forKey: "createdDate") as? Date,
                   let isFavourite = data.value(forKey: "isFavourite") as? Int{
                    let folder = DataModel(folderId: folderId, folderName: folderName, folderColor: folderColor, isFavourite: isFavourite, createdDate: createdDate)
                    folderArr.append(folder)
                }
            }
            completion(folderArr)
        } catch {
            print("Failed to fetch folders: \(error)")
            completion([])
        }
    }
    // MARK: - ADD FOLDER
    func addFolder(folderName: String, colorCode: String, completion: @escaping () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FOLDERS_ENTITY)
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["folderId"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "folderId", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            var maxFolderId = 0
            
            if let dictionary = result.first as? [String: Any], let maxId = dictionary["folderId"] as? Int {
                maxFolderId = maxId
            }

            let newFolderId = maxFolderId + 1
            let folderEntity = NSEntityDescription.entity(forEntityName: FOLDERS_ENTITY, in: managedContext)!

            let folder = NSManagedObject(entity: folderEntity, insertInto: managedContext)
            print("maxFolderID",maxFolderId,newFolderId)
            folder.setValue(newFolderId, forKey: "folderId")
            folder.setValue(folderName, forKey: "folderName")
            folder.setValue(colorCode, forKey: "folderColor")
            folder.setValue(Date(), forKey: "createdDate")

            try managedContext.save()
            completion()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}
