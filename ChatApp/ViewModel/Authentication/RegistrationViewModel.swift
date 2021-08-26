//
//  RegistrationViewModel.swift
//  ChatApp
//
//  Created by Zach mills on 3/28/21.
//

import Foundation
import UIKit

struct RegistrationViewModel: AuthenticationProtocol {
    var email: String?
    var password: String?
    var username: String?
    var fullname: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
            && username?.isEmpty == false && fullname?.isEmpty == false
    }
}
