//
//  UserViewController.swift
//  webRTCtest
//
//  Created by 清浦駿 on 2020/04/16.
//  Copyright © 2020 com.example. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let userDefault = UserDefaults.standard
    let storage = Storage.storage()
    let db = Firestore.firestore()
    let uid = UserDefaults.standard.object(forKey: "uid")

    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func deleteUidButton(_ sender: Any) {
        userDefault.removeObject(forKey: "uid")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        uidLabel.text = uid as? String
        
        reroad()
        
        
        /*httpsReference.getData(maxSize: 1 * 1024 * 1024){
            data, error in
            if let error = error {
              // Uh-oh, an error occurred!
            } else {
              // Data for "images/island.jpg" is returned
                self.imageView.image = UIImage(data: data!)
            }
        }*/
        
        // Do any additional setup after loading the view.
    }
    
    func reroad() {
        var url = ""
        
        
        db.collection("Users").document("\(userDefault.object(forKey: "uid")!)").getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.nameLabel.text =  (dataDescription?["name"])! as! String
                url = dataDescription?["imgURL"]! as! String
                
                /*
                httpsReference.getData(maxSize: 1 * 1024 * 1024){
                    data, error in
                    if let error = error {
                      // Uh-oh, an error occurred!
                    } else {
                      // Data for "images/island.jpg" is returned
                        self.imageView.image = UIImage(data: data!)
                    }
                }*/
                print(url)
                self.imageView.sd_setImage(with: URL(string: url))
            } else {
                print("Document does not exist")
            }
        }
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
