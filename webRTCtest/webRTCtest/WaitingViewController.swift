//
//  WaitingViewController.swift
//  webRTCtest
//
//  Created by 清浦駿 on 2020/04/18.
//  Copyright © 2020 com.example. All rights reserved.
//

import UIKit
import Firebase

class WaitingViewController: UIViewController {
    
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    
    let userDefaults = UserDefaults.standard
    
    @IBAction func makeTalkroom(_ sender: Any) {
        ref = db.collection("TalkRooms").document(userDefaults.object(forKey: "uid") as! String)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
