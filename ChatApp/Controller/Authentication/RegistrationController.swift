//
//  RegistrationController.swift
//  ChatApp
//
//  Created by Zach mills on 3/9/21.
//

import UIKit
import Firebase
import JGProgressHUD

protocol AuthenticationControllerProtocol {
    func checkFormStatus()
}

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = RegistrationViewModel()
    // Create instance of profile image
    private var profileImage: UIImage?
    
    weak var delegate: AuthenticationDelegate?
    
    
    // Create the add photo button with image
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        // Image picker config
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    
    // Email box, instantiated in InputContainerView file function
private lazy var emailContainerView: InputContainerView = {
        return InputContainerView(image: UIImage(systemName: "envelope"), textField: emailTextField)
}()

    private lazy var fullnameContainerView: InputContainerView = {
            return InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullnameTextField)
    }()

    private lazy var usernameContainerView: InputContainerView = {
            return InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: usernameTextField)
    }()


    // Password box, instantiated in InputContainerView file function
private lazy var passwordContainerView: InputContainerView = {
    return InputContainerView(image: UIImage(systemName: "lock"), textField: passwordTextField)
    
}()

    
    private let emailTextField = CustomTextField(placeholder: "Email")
    private let fullnameTextField = CustomTextField(placeholder: "Full Name")
    private let usernameTextField = CustomTextField(placeholder: "Username")
    
    
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    
    // create Sign Up button
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        // Add target to button to handle registration
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        button.setHeight(height: 50)
        return button
    }()
    
    
    // Create already have an account button, Log In button for addition to ConfigureUI() function
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ",
        attributes: [.font: UIFont.systemFont(ofSize: 16),  .foregroundColor: UIColor.white])
        
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        // add target to navigate to when this button is pressed, which is handleShowLogin
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        return button
    }()
    
    
    // MARK: - Lifecycle

override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureNotificationObservers()
            
}
    
    // MARK: - Selectors
    
    // Grabbing registration info to send to database for authentication. Executed by target added in signUpButton.
    @objc func handleRegistration() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let profileImage = profileImage else { return }
        
            // AuthService file createUser function
        let credentials = RegistrationCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        showLoader(true, withText: "Creating Profile...")
        
        
        AuthService.shared.createUser(credentials: credentials) { error in
            if let error = error {
                self.showLoader(false)
                self.showError(error.localizedDescription)
                return
            }
            self.showLoader(false)
            self.delegate?.authenticationComplete()
        }
    }
    
   
    // called when text changes in email or password text fields. Targets created below
    // updating viewModel based on sender triggering the action
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        } else if sender == fullnameTextField {
            viewModel.fullname = sender.text
        } else if sender == usernameTextField {
            viewModel.username = sender.text
        }
        
        checkFormStatus()
    }
    
    // Handle the pressing of the plusPhotoButton
        // shows image picker controller
    
    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    // Create navigation to the Login Controller
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
        // functions for fields adjusting to keyboard display
    @objc func keyboardWillShow() {
        if view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 88
        }
    }
    
    @objc func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    
    // MARK: - Helper Functions
 
    
    func configureUI() {
        configureGradientLayer()
        
        // add plusPhotoButton to the subview
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        plusPhotoButton.setDimensions(height: 200, width: 200)
        
        
        // Put UI components in a stack view
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   fullnameContainerView,
                                                   usernameContainerView,
                                                   signUpButton])
        
        stack.axis = .vertical
        stack.spacing = 16
        
        
        // Configure stack view layout
    view.addSubview(stack)
    stack.anchor(top: plusPhotoButton.bottomAnchor,
                 left: view.leftAnchor,
                 right: view.rightAnchor,
                 paddingTop: 32,
                 paddingLeft: 32,
                 paddingRight: 32)
        
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor,
                                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                        right: view.rightAnchor,
                                        paddingLeft: 32,
                                        paddingBottom: 6,
                                        paddingRight: 32)
    }
    
    func configureNotificationObservers() {
        // called every time text changes
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        
            // fields adjusting to keyboard display. keyboardWillShow(), keyboardWillHide()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}

extension RegistrationController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            // Tells the delegate that user picked an image/video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Grabbed image
        let image = info[.originalImage] as? UIImage
            // Replace plus photo button with selected image
        plusPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        profileImage = image
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 3.0
        plusPhotoButton.layer.cornerRadius = 200 / 2
       
        // button.clipstobounds = true in the top level makes image fit
        
        dismiss(animated: true, completion: nil)
    }
}

extension RegistrationController: AuthenticationControllerProtocol {

    
    // Checking if formIsValid is true (formIsValid in LoginViewMdoel tells if there is text input). And either changes button color or stays the same
    func checkFormStatus() {
        if viewModel.formIsValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }
    }
}
