//
//  LoginController.swift
//  ChatApp
//
//  Created by Zach mills on 3/9/21.
//

import UIKit
import Firebase
import JGProgressHUD

protocol AuthenticationDelegate: class {
    func authenticationComplete()
}

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = LoginViewModel()
    
    weak var delegate: AuthenticationDelegate?
    
    
    
    // Configuring UI components
    
        // Image view setup, ADD to view later
    private let iconImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.right")
        iv.tintColor = .white
        return iv
    }()
    
    
    
    
        // Email box, instantiated in InputContainerView file function
    private lazy var emailContainerView: InputContainerView = {
            return InputContainerView(image: UIImage(systemName: "envelope"), textField: emailTextField)
    }()
    
    
    
    
        // Password box, instantiated in InputContainerView file function
    private lazy var passwordContainerView: InputContainerView = {
        return InputContainerView(image: UIImage(systemName: "lock"), textField: passwordTextField)
        
    }()
    
    
    
    
        // Log In Button
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.setHeight(height: 50)
        return button
    }()
    
    
    
    
    // Text field for email and password boxes, instantiated in CustomTextField file in View group
    private let emailTextField = CustomTextField(placeholder: "Email")
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    // Create dont have an account button, Sign Up button for addition to ConfigureUI() function
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ",
        attributes: [.font: UIFont.systemFont(ofSize: 16),  .foregroundColor: UIColor.white])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        // add target to navigate to when this button is pressed, which is handleShowSignUp
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return button
    }()
    
    
    // MARK: - Lifecycle

override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    
            
}
    
    // MARK: - Selectors
    
        // Logging in user
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
            // Progress indicator function in Extensions file
        showLoader(true, withText: "Logging In...")
        
                        // Reference AuthService for logUserIn function
        AuthService.shared.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showLoader(false)
                self.showError(error.localizedDescription)
                return
            }
                // Dismiss loader
            self.showLoader(false)
            self.delegate?.authenticationComplete()
        }

    }
    
    // Create navigation to the Reistration Controller
    @objc func handleShowSignUp () {
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // called when text changes in email or password text fields. Targets created below
    // updating viewModel based on sender triggering the action
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        checkFormStatus()
    }
    
    
    // MARK: - Helper Functions
   
    
        // Function containing UI elements
    func configureUI() {
       
        navigationController?.navigationBar.isHidden = true
                // Makes time and battery icons white
        navigationController?.navigationBar.barStyle = .black
        
        
        
        configureGradientLayer()
        
        
        
        
        // Configure autolayout for image using constraint functions created in Extensions file
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        iconImage.setDimensions(height: 120, width: 120)
        
            // Put UI components in a stack view
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   loginButton])
        
        stack.axis = .vertical
        stack.spacing = 16
        
        
            // Configure stack view layout
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 32,
                     paddingLeft: 32,
                     paddingRight: 32)
        
                // Adding the sign up button to the view and configuring layout
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left: view.leftAnchor,
                                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                        right: view.rightAnchor,
                                        paddingLeft: 32,
                                        paddingBottom: 6,
                                        paddingRight: 32)
        
        // called every time text changes
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    
}

extension LoginController: AuthenticationControllerProtocol {
    
    // Checking if formIsValid is true (formIsValid in LoginViewMdoel tells if there is text input). And either changes button color or stays the same
    func checkFormStatus() {
        if viewModel.formIsValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }
    }
}


