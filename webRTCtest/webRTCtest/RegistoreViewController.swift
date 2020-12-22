//
//  LoginViewController.swift
//  webRTCtest
//
//  Created by 清浦駿 on 2020/04/15.
//  Copyright © 2020 com.example. All rights reserved.
//

import UIKit
import Firebase

class RegistoreViewController: UIViewController,UITextFieldDelegate {
    
    let userDefault = UserDefaults.standard

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBAction func registoreButton(_ sender: Any) {
        let email: String = emailField.text!
        let password: String = passwordField.text!
        if (email != "") && (password != ""){
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    if let errCode = AuthErrorCode(rawValue: error._code){
                        switch errCode {
                        case .weakPassword:
                            print("うぃーくぱすわーど")
                        default:
                            return
                        }
                    }
                } else {
                    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                      // ...
                        self?.userDefault.set(Auth.auth().currentUser?.uid, forKey: "uid")
                        self?.userDefault.synchronize()
                        
                        self?.userIdLabel.text = Auth.auth().currentUser?.uid
                    }
                    self.performSegue(withIdentifier: "moveToInfoView", sender: nil)
                }
                
            }
        } else{
            print("empty")
        }
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
