//
//  ChatView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-28.
//

import SwiftUI
import CoreData
import FirebaseFirestore


struct ChatListView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var chats: [Chat] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let chatService = ChatService()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                if isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading ..."); Spacer() }
                    Spacer()

                } else if let err = errorMessage {
                    Spacer()
                    Text(err).foregroundColor(.red).padding()
                    Spacer()

                } else if chats.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No chats yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("A group chat is created once your move request is accepted and a mover is assigned.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()

                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(chats) { chat in
                                NavigationLink(destination: ChatRoomView(chat: chat)) {
                                    ChatRow(chat: chat)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadChats() }
        .refreshable { await loadChats() }
    }

    private func loadChats() async {
        guard let uid = authManager.user?.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            chats = try await chatService.fetchChats(for: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}


private struct ChatRow: View {
    let chat: Chat

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Color("goodPurple"))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text("Move Chat")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text(chat.lastMessage ?? "Chat started")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            if let date = chat.lastMessageAt {
                Text(date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.06))
        .cornerRadius(14)
    }
}


struct ChatRoomView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var context

    let chat: Chat

    @State private var messages: [Message] = []
    @State private var listener: AnyObject? = nil
    @State private var draftText = ""

    private let chatService = ChatService()
    private var draftService: ChatDraftService { ChatDraftService(context: context) }

    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            MessageBubble(
                                message: message,
                                isMe: message.senderId == authManager.user?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                .onChange(of: messages.count) {
                    if let lastId = messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastId = messages.last?.id {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 10) {
                TextField("Message", text: $draftText, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                    .onChange(of: draftText) {
                        draftService.saveDraft(draftText, chatId: chat.id ?? "")
                    }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            draftText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.gray : Color("goodPurple")
                        )
                        .cornerRadius(20)
                }
                .disabled(draftText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
        }
        .navigationTitle("Move Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            draftText = draftService.loadDraft(chatId: chat.id ?? "")
            startListening()
        }
        .onDisappear {
            stopListening()
        }
    }

    private func sendMessage() {
        let text = draftText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let chatId = chat.id else { return }
        let senderName = authManager.user?.displayName ?? "User"
        draftText = ""
        draftService.clearDraft(chatId: chatId)
        Task {
            try? await chatService.sendMessage(chatId: chatId, text: text, senderName: senderName)
        }
    }

    private func startListening() {
        guard let chatId = chat.id else { return }
        listener = chatService.listenToMessages(chatId: chatId) { incoming in
            messages = incoming
        } as AnyObject
    }

    private func stopListening() {
        if let reg = listener as? ListenerRegistration {
            reg.remove()
        }
        listener = nil
    }
}


private struct MessageBubble: View {
    let message: Message
    let isMe: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isMe { Spacer(minLength: 60) }

            VStack(alignment: isMe ? .trailing : .leading, spacing: 3) {
                if !isMe {
                    Text(message.senderName)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }

                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundColor(isMe ? .white : .black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(isMe ? Color("goodPurple") : Color.gray.opacity(0.15))
                    .cornerRadius(18)

                if let date = message.sentAt {
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                }
            }

            if !isMe { Spacer(minLength: 60) }
        }
    }
}
