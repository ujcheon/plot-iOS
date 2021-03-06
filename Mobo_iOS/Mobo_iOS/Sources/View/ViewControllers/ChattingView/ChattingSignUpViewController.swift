//
//  ChattingSignUpViewController.swift
//  Mobo_iOS
//
//  Created by 조경진 on 2019/12/24.
//  Copyright © 2019 조경진. All rights reserved.
//

import UIKit
import Firebase


class ChattingSignUpViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var color : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.right.top.left.equalTo(self.view)
            m.height.equalTo(20)
        }
        
        color = remoteconfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color!)
        signup.backgroundColor = UIColor(hex: color!)
        cancel.backgroundColor = UIColor(hex: color!)
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        
        signup.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancel.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           self.view.endEditing(true)
           //return 버튼 누르면 키보드 내려갈수있게 설정.
       }
    
    @objc func imagePicker(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        imageView.image = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func signupEvent(){
        
    Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, err) in
        let uid = user?.user.uid
        
        let image = self.imageView.image!.jpegData(compressionQuality: 0.1)
        
        Storage.storage().reference().child("userImages").child(uid!).putData(image!, metadata: nil, completion: { (data, error) in
                       
                      // let imageUrl = data?.downloadURL()?.absoluteString
                       let values = ["userName":self.name.text!,"profileImageUrl":"https://user-images.githubusercontent.com/46750574/67218949-32564e00-f462-11e9-9852-6c68178f9810.png","uid":Auth.auth().currentUser?.uid]
                       
                       Database.database().reference().child("users").child(uid!).setValue(values, withCompletionBlock: { (err, ref) in
                           
                           if(err==nil){
                               self.cancelEvent()
                           }
                           
                       })
                       
                   })
                   
                   
                   
               }
               
    }
//    @objc func signupEvent(){
//
//        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, err) in
//            let uid = user?.user.uid
//
//           let image = self.imageView.image!.jpegData(compressionQuality: 0.1)
//
//
//            Storage.storage().reference().child("userImages").child(uid!).putData(image!, metadata: nil, completion: { (data, error) in
//
//               // let imageUrl = data?.downloadURL()?.absoluteString
//
//                let values = ["userName":self.name.text!,"profileImageUrl":"","uid":Auth.auth().currentUser?.uid]
//
//                Database.database().reference().child("users").child(uid!).setValue(values, withCompletionBlock: { (err, ref) in
//
//                    if(err==nil){
//                        self.cancelEvent()
//                    }
//
//                })
//
//            })
//
//
//
//        }
        
        
//        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, err) in
//            let uid = user?.user.uid
//
//            let image = self.imageView.image!.jpegData(compressionQuality: 0.1)
//
//            Storage.storage().reference().child("userImages").child(uid!).putData(image!, metadata: nil, completion: { (data, error) in
//
//
//               // let imageUrl = (data?.downloadURL() as AnyObject).absoluteString
//
////                let image = self.imageView.image?.jpegData(compressionQuality: 0.1)
////
////                       let imageRef = Storage.storage().reference().child("userImages").child(uid!)
////
////                       imageRef.putData(image!, metadata: nil, completion: {(StorageMetadata, Error) in
////
////                           imageRef.downloadURL(completion: { (url, err) in
////
////                               Database.database().reference().child("user").child(uid!).setValue(["name":self.name.text,"profileImageUrl":url?.absoluteString])
////
////                           })
////                       })
//
//                       let values = ["userName":self.name.text!,"profileImageUrl":"","uid":Auth.auth().currentUser?.uid]
//
//                       Database.database().reference().child("users").child(uid!).setValue(values, withCompletionBlock: { (err, ref) in
//
//                           if(err==nil){
//                               self.cancelEvent()
//                           }
//
//                       })
//
//                   })
//
//
//
//               }
        
    //}
    
    
    //
    //    @objc func signupEvent(){
    //
    //        Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: {
    //
    //            (user, error) in
    //
    //        let image = self.imageView.image!.jpegData(compressionQuality: 0.1)
    //
    //            if error != nil{
    //
    //                if let ErrorCode = AuthErrorCode(rawValue: (error?._code)!) {
    //
    //                    switch ErrorCode {
    //
    //                    case AuthErrorCode.invalidEmail:
    //                        self.showAlert(message: "유효하지 않은 이메일 입니다")
    //
    //                    case AuthErrorCode.emailAlreadyInUse:
    //                        self.showAlert(message: "이미 가입한 회원 입니다")
    //
    //                    case AuthErrorCode.weakPassword:
    //                        self.showAlert(message: "비밀번호는 6자리 이상이여야해요")
    //
    //                    default:
    //                        print(ErrorCode)
    //                    }
    //                }
    //
    //            } else{
    //                print("회원가입 성공")
    //                dump(user)
    //            }
    //        })
    //
    //    }
    
    
    @objc func cancelEvent(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(message:String){
        let alert = UIAlertController(title: "회원가입 실패",message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
