//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by Zach mills on 3/26/21.
//

import Foundation
import UIKit

// Conforming to this protocol will make the formIsValid property a requirement
protocol AuthenticationProtocol {
    var formIsValid: Bool { get }
}

struct LoginViewModel: AuthenticationProtocol {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
            && password?.isEmpty == false
    }
}
