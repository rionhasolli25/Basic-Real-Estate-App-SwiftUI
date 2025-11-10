//
//  ChatViewModel.swift
//  Real Estate
//
//  Created by Rion on 5.11.25.
//

import Foundation
import RealmSwift

class ChatViewModel : ObservableObject{
    
    @Published var messages : [Message] = []
    @Published var newMessageText: String = ""
    private var notificationToken: NotificationToken?
    private var realm: Realm
    let currentUserID: String
    let receiverID: String
    
    init(receiverID: String,currentUserID:String){
        self.receiverID = receiverID
        self.currentUserID = currentUserID
        
        realm = try! Realm()
        
        loadMessages()
        
    }
    func loadMessages() {
        let results = realm.objects(Message.self)
            .filter("(senderID == %@ AND receiverID == %@) OR (senderID == %@ AND receiverID == %@)",
                    currentUserID, receiverID, receiverID, currentUserID)
            .sorted(byKeyPath: "timestamp", ascending: true)
        
        messages = Array(results)
        
        // 🟢 Live updates
        notificationToken = results.observe { [weak self] changes in
            switch changes {
            case .initial(let collection):
                self?.messages = Array(collection)
            case .update(let collection, _, _, _):
                self?.messages = Array(collection)
            case .error(let error):
                print("Realm error: \(error)")
            }
        }
    }
    func sendMessage() {
            guard !newMessageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            let message = Message()
            message.senderID = currentUserID
            message.receiverID = receiverID
            message.text = newMessageText
            message.timestamp = Date()
            
            do {
                try realm.write {
                    realm.add(message)
                }
                
                // Clear text field instantly
                newMessageText = ""
            } catch {
                print("❌ Failed to send message: \(error.localizedDescription)")
            }
        }

        
        deinit {
            notificationToken?.invalidate()
        }
        
    }




struct ChatSummary: Identifiable {
    let id = UUID()
    let userID: String
    let lastMessage: String
    let lastTimestamp: Date
}

class ChatListViewModel: ObservableObject {
    @Published var chats: [ChatSummary] = []
    
    private var realm: Realm
    let currentUserID: String
    
    init(currentUserID: String) {
        self.currentUserID = currentUserID
        self.realm = try! Realm()
        
        loadChats()
        observeChats()
    }
    
    func loadChats() {
        let messages = realm.objects(Message.self)
            .filter("senderID == %@ OR receiverID == %@", currentUserID, currentUserID)
            .sorted(byKeyPath: "timestamp", ascending: false)
        
        var dict: [String: Message] = [:]
        
        for msg in messages {
            let otherID = msg.senderID == currentUserID ? msg.receiverID : msg.senderID
            if dict[otherID] == nil {
                dict[otherID] = msg
            }
        }
        
        chats = dict.map { key, value in
            ChatSummary(userID: key, lastMessage: value.text, lastTimestamp: value.timestamp)
        }.sorted { $0.lastTimestamp > $1.lastTimestamp }
    }
    
    func observeChats() {
        let results = realm.objects(Message.self)
            .filter("senderID == %@ OR receiverID == %@", currentUserID, currentUserID)
            .sorted(byKeyPath: "timestamp", ascending: false)
        
        _ = results.observe { [weak self] _ in
            self?.loadChats()
        }
    }
}
