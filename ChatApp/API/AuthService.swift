//
//  AuthService.swift
//  ChatApp
//
//  Created by Zach mills on 3/30/21.
//

import UIKit
import Firebase

// Database communication work for user authentication

struct RegistrationCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)

            
        }
    
    
func createUser(credentials: RegistrationCredentials, completion: ((Error?) -> Void)?) {
        
            // compresses image for faster loading
    guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
            // Creates file in Firebase to store images with unique identifiers
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
            // Uploading image to database
        ref.putData(imageData, metadata: nil) { (meta, error) in
            if let error = error {
                completion!(error)
                return
            }
                // Fetching imageURL
            ref.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                
                    // Creating user to upload info into databse
                Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                    if let error = error {
                        completion!(error)
                        return
                    }
                    
                    
                        // getting unique identifier based on result of user creation
                    guard let uid = result?.user.uid else { return }
                    
                    // Info being uploaded to database
                    let data = ["email": credentials.email,
                                "fullname": credentials.fullname,
                                "profileImageUrl": profileImageUrl,
                                "uid": uid,
                                "username": credentials.username] as [String: Any]
                    
                    
                    // Accesses database and creates "users" collection
                    Firestore.firestore().collection("users").document(uid).setData(data, completion: completion)
                    
                       
                   
                }
            }
        }
        
    }

}

