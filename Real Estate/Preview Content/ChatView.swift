//
//  ChatView.swift
//  Real Estate
//
//  Created by Rion on 5.11.25.
//

import SwiftUI

import SwiftUI



struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    
    var body: some View {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(viewModel.messages) { message in
                                    ChatBubble(message: message, currentUserID: viewModel.currentUserID)
                                        .id(message.id)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            if let last = viewModel.messages.last {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    Divider().padding(.vertical, 6)
                    
                    // Message Input
                    HStack(spacing: 10) {
                        TextField("Type a message...", text: $viewModel.newMessageText)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(radius: 1)
                        
                        Button(action: viewModel.sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
                 .navigationTitle("Chat")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbar(.hidden, for: .tabBar)
            
        }
    }



struct ChatBubble: View {
    let message: Message
    let currentUserID: String
    
    var isCurrentUser: Bool {
        message.senderID == currentUserID
    }
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            Text(message.text)
                .padding(10)
                .background(isCurrentUser ? Color.blue.opacity(0.8) : Color.gray.opacity(0.25))
                .foregroundColor(isCurrentUser ? .white : .black)
                .cornerRadius(15)
                .frame(maxWidth: 260, alignment: isCurrentUser ? .trailing : .leading)
            
            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

struct ChatListView: View {
    @ObservedObject private var viewModel: ChatListViewModel
    @State private var path = NavigationPath()

    init(currentUserID: String) {
        viewModel = ChatListViewModel(currentUserID: currentUserID)
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(viewModel.chats) { chat in
                    NavigationLink(value: chat.userID) {
                        ChatRowView(chat: chat)
                    }
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        path.append("NewChat")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "NewChat" {
                    NewChatView { userID in
                        path.removeLast()
                        path.append(userID)
                    }
                } else {
                    ChatView(
                        viewModel: ChatViewModel(
                            receiverID: value,
                            currentUserID: viewModel.currentUserID
                        )
                    )
                }
            }
        }
    }
}


struct NewChatView: View {
    @State private var userID: String = ""
    @Environment(\.dismiss) var dismiss
    
    var onCreate: (String) -> Void

    var body: some View {
            VStack(spacing: 20) {
                TextField("Enter user ID", text: $userID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Start Chat") {
                    guard !userID.isEmpty else { return }
                    onCreate(userID)   // <-- triggers newChatUserID in ChatListView
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .navigationTitle("New Chat")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
        }
    }
}

struct ChatRowView: View {
    let chat: ChatSummary

    var body: some View {
        HStack(spacing: 12) {
            // Circle avatar (just first letter of user ID for now)
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(chat.userID.prefix(1)))
                        .foregroundColor(.white)
                        .font(.headline)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.userID) // Replace with actual username if available
                    .font(.headline)
                
                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(chat.lastTimestamp, style: .time)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 6)
        .navigationBarBackButtonHidden(true)
    }
}

