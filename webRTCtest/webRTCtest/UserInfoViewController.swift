//
//  UserInfoViewController.swift
//  webRTCtest
//
//  Created by 清浦駿 on 2020/04/23.
//  Copyright © 2020 com.example. All rights reserved.
//

import UIKit
import Firebase

class UserInfoViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var window: UIWindow?
    let db = Firestore.firestore()
    let userDefault = UserDefaults.standard
    let storage = Storage.storage()
    var image: UIImage? = nil
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func registoreButton(_ sender: Any) {
        let uid = UserDefaults.standard.object(forKey: "uid") as! String
        if userNameField.text == ""{
            print("空白")
        } else {
            db.collection("Users").document(uid).setData(["name": userNameField.text!])
            if image != nil {
                let uploadTask = storage.reference().child("UserImages/\(userDefault.string(forKey: "uid")!)/1.jpeg").putData((image?.jpegData(compressionQuality: 1.0))!, metadata: nil) {
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
                    }
                }
            }
            
            
            window = UIWindow(frame: UIScreen.main.bounds)
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
            
        }
        
    }
    
    @IBAction func addImageButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image =  info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
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
