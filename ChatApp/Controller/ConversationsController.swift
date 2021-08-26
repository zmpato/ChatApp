//
//  Conversations.swift
//  ChatApp
//
//  Created by Zach mills on 2/26/21.
//

import UIKit
import Firebase

private let reuseIdentifier = "ConversationCell"

class ConversationsController: UIViewController {
    
    
    // MARK: - Properties
    
        // storing UITV in variable to create and configure later
    private let tableView = UITableView()
    private var conversations = [Conversation]()
    private var conversationDictionary = [String: Conversation]()
    
        // Instantiate a button for new message
    private let newMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .chatNeonBlue
        button.tintColor = .white
        button.imageView?.setDimensions(height: 24, width: 24)
        button.addTarget(self, action: #selector(showNewMessage), for: .touchUpInside)
            // ^accesses showNewMessage() function which activates NewMessageController file contents
        return button
    }()
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        authenticateUser()
        fetchConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(withTitle: "Messages", prefersLargeTitles: true)
    }
    
    
    // MARK: - Selectors
    
        // Presenting ProfileController
    @objc func showProfile() {
        let controller = ProfileController(style: .insetGrouped) // Separated cells appearance from background
        let nav = UINavigationController(rootViewController: controller)
        controller.delegate = self
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
        // Called in button press, activates NewMessageController file contents
    @objc func showNewMessage() {
        let controller = NewMessageController()
        let nav = UINavigationController(rootViewController: controller)
        controller.delegate = self
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    
    // MARK: - API
    
    func fetchConversations() {
        showLoader(true)
        
        Service.fetchConversations { conversations in
            
            conversations.forEach { conversation in
                let message = conversation.message
                self.conversationDictionary[message.chatPartnerId] = conversation
            }
            
            self.showLoader(false)
            
            self.conversations = Array(self.conversationDictionary.values)
            
            self.tableView.reloadData()
        }
    }
    
        // Indicating if user is logged in or not in order to load correct screen
    func authenticateUser() {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginScreen()
        }
    }
   
        // log user out
    func logout() {
        do {
            try Auth.auth().signOut()
            presentLoginScreen()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    // MARK: - Helper Functions

        // Present login screen if user is logged out
    func presentLoginScreen() {
        DispatchQueue.main.async {
            let controller = LoginController()
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    
        // Function containing UI elements
    func configureUI() {
        view.backgroundColor = .white
        
            // Calling other functions containing UI elements
        
        configureTableView()

            // NavBar image icon
        let image = UIImage(systemName: "person.circle.fill")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showProfile))
        
            // add newMessageButton to view
        view.addSubview(newMessageButton)
        newMessageButton.setDimensions(height: 56, width: 56)
        newMessageButton.layer.cornerRadius = 56 / 2
        newMessageButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                    right: view.rightAnchor,
                                    paddingBottom: 16,
                                    paddingRight: 24)
        
    }
    
    // Configuring Table View
    func configureTableView() {
            // Register and configure tableview cell
        tableView.backgroundColor = .white
        tableView.rowHeight = 90
        tableView.register(ConversationCell.self, forCellReuseIdentifier: reuseIdentifier)
            // Only showing row separators for amount of occupied cells
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
    
    func showChatController(forUser user: User) {
        let controller = ChatController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
}

// MARK: UITableViewDataSource


// Create data source to allow tableview to manage and update data contents

extension ConversationsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
        // providing the cell object to be reused and configured
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ConversationCell
        cell.conversation = conversations[indexPath.row]
        return cell
    }
    
    
}

// MARK: UITableViewDelegate

// Delegate allows tableview to perform actions

extension ConversationsController: UITableViewDelegate {
        // what happens when row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = conversations[indexPath.row].user
        showChatController(forUser: user)
    }
}

// MARK: - New Message Controller Delegate
extension ConversationsController: NewMessageControllerDelegate {
    func controller(_ controller: NewMessageController, wantsToStartChatWith user: User) {
        dismiss(animated: true, completion: nil)
        showChatController(forUser: user)
    }
    
    
}

// MARK: - ProfileControllerDelegate

extension ConversationsController: ProfileControllerDelegate {
    func handleLogout() {
        logout()
    }
}

// MARK: - AuthenticationDelegate

extension ConversationsController: AuthenticationDelegate {
    func authenticationComplete() {
        dismiss(animated: true, completion: nil)
        configureUI()
        fetchConversations()
    }
}
