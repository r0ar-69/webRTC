//
//  EditViewController.swift
//  webRTCtest
//
//  Created by 清浦駿 on 2020/05/01.
//  Copyright © 2020 com.example. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class EditViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    let db = Firestore.firestore()
    let userDefault = UserDefaults.standard
    let storage = Storage.storage()
    var image: UIImage? = nil
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBAction func registoreButton(_ sender: Any) {
        
        let uid = UserDefaults.standard.object(forKey: "uid") as! String
        if nameField.text == ""{
            print("空白")
        } else {
            db.collection("Users").document(uid).updateData(["name": nameField.text!])
            if image != nil {
                let meta = StorageMetadata()
                meta.contentType = "image/jpeg"
                let uploadTask = storage.reference().child("UserImages/\(userDefault.string(forKey: "uid")!)/1.jpeg").putData((image?.jpegData(compressionQuality: 1.0))!, metadata: meta) {
                    metadata, error in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        print("Uh-oh, an error occurred!")
                        return
                    }
                    
                    self.storage.reference().child("UserImages/\(uid)/1.jpeg").downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            print(error)
                            return
                        }
                        self.db.collection("Users").document(self.userDefault.string(forKey: "uid")!).updateData(["imgURL": "\(downloadURL)"])
                        print(downloadURL)
                        self.dismiss(animated: true, completion: nil)
                        UserViewController().loadView()
                        UserViewController().viewDidLoad()
                    }
                }
            }
        }
    }
    
    @IBAction func button(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db.collection("Users").document("\(userDefault.object(forKey: "uid")!)").getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let url = dataDescription?["imgURL"]! as! String
                print(url)
                let httpsReference = self.storage.reference(forURL: url)/*
                 httpsReference.getData(maxSize: 1 * 1024 * 1024){
                 data, error in
                 if let error = error {
                 // Uh-oh, an error occurred!
                 } else {
                 // Data for "images/island.jpg" is returned
                 self.imageView.image = UIImage(data: data!)
                 }
                 }*/
                let placeholderImage = UIImage(named: "placeholder.jpg")
                self.imgView.sd_setImage(with: httpsReference, placeholderImage: placeholderImage)
            } else {
                print("Document does not exist")
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image =  info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imgView.image = image
        picker.dismiss(animated: true, completion: nil)
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
