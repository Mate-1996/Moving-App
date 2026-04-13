//
//  ChatView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-28.
//

import SwiftUI
import CoreData
import FirebaseFirestore
import PhotosUI


actor ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]
    func get(_ key: String) -> UIImage? { cache[key] }
    func set(_ key: String, image: UIImage) { cache[key] = image }
}

struct CachedAsyncImage: View {
    let urlString: String
    @State private var image:  UIImage? = nil
    @State private var failed  = false

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img).resizable()
            } else if failed {
                Label("Image unavailable", systemImage: "photo")
                    .font(.caption).foregroundColor(.gray)
            } else {
                ZStack {
                    Color.gray.opacity(0.15)
                    ProgressView()
                }
            }
        }
        .task(id: urlString) { await load() }
    }

    private func load() async {
        if let cached = await ImageCache.shared.get(urlString) { image = cached; return }
        guard let url = URL(string: urlString) else { failed = true; return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let img = UIImage(data: data) {
                await ImageCache.shared.set(urlString, image: img)
                image = img
            } else { failed = true }
        } catch { failed = true }
    }
}


struct ChatListView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var chats: [Chat] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var chatToDelete: Chat?   = nil
    @State private var showDeleteAlert = false

    private let chatService = ChatService()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                if isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView("Loading"); Spacer() }
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
                            .font(.headline).foregroundColor(.gray)
                        Text("A group chat is created once your move request is accepted and a mover is assigned.")
                            .font(.caption).foregroundColor(.gray)
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
                                .contextMenu {
                                    if authManager.user?.role == .admin {
                                        Button(role: .destructive) {
                                            chatToDelete  = chat
                                            showDeleteAlert = true
                                        } label: {
                                            Label("Delete Chat", systemImage: "trash")
                                        }
                                    }
                                }
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
        .alert("Delete Chat", isPresented: $showDeleteAlert, presenting: chatToDelete) { chat in
            Button("Delete", role: .destructive) {
                Task { await deleteChat(chat) }
            }
            Button("Cancel", role: .cancel) { chatToDelete = nil }
        } message: { _ in
            Text("This will permanently delete the chat and all its messages for everyone. This cannot be undone.")
        }
    }

    private func loadChats() async {
        guard let uid = authManager.user?.id else { return }
        isLoading = true; errorMessage = nil
        do {
            chats = try await chatService.fetchChats(for: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func deleteChat(_ chat: Chat) async {
        guard let id = chat.id else { return }
        do {
            try await chatService.deleteChat(chatId: id)
            chats.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


private struct ChatRow: View {
    let chat: Chat
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 20)).foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Color("goodPurple")).cornerRadius(12)
            VStack(alignment: .leading, spacing: 4) {
                Text("Move Chat")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
                Text(previewText(chat.lastMessage))
                    .font(.system(size: 13)).foregroundColor(.gray).lineLimit(1)
            }
            Spacer()
            if let date = chat.lastMessageAt {
                Text(date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2).foregroundColor(.gray)
            }
        }
        .padding().background(Color.gray.opacity(0.06)).cornerRadius(14)
    }

    private func previewText(_ text: String?) -> String {
        guard let text else { return "Chat started" }
        if text.hasPrefix(ImageUploadService.imagePrefix) { return "Photo" }
        return text
    }
}


struct ChatRoomView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.managedObjectContext) private var context

    let chat: Chat

    @State private var messages:  [Message] = []
    @State private var listener:  AnyObject? = nil
    @State private var draftText  = ""

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showCamera = false
    @State private var isUploadingPhoto = false
    @State private var uploadError: String? = nil
    @State private var showGallery = false

    private let chatService   = ChatService()
    private let uploadService = ImageUploadService()
    private var draftService: ChatDraftService { ChatDraftService(context: context) }

    private var imageURLs: [String] {
        messages
            .filter { $0.text.hasPrefix(ImageUploadService.imagePrefix) }
            .reversed()
            .map { String($0.text.dropFirst(ImageUploadService.imagePrefix.count)) }
    }

    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            MessageBubble(
                                message: message,
                                isMe:    message.senderId == authManager.user?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                .defaultScrollAnchor(.bottom)
                .onChange(of: messages.count) {
                    if let lastId = messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            if isUploadingPhoto {
                HStack(spacing: 8) {
                    ProgressView().tint(Color("goodPurple"))
                    Text("Sending photo").font(.caption).foregroundColor(.secondary)
                }
                .padding(.horizontal, 16).padding(.vertical, 6)
            }

            if let err = uploadError {
                Text(err).font(.caption).foregroundColor(.red).padding(.horizontal, 16)
            }

            Divider()

            HStack(spacing: 10) {
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 22)).foregroundColor(Color("goodPurple"))
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    guard let newItem else { return }
                    Task { await sendPickedPhoto(newItem) }
                }

                Button(action: { showCamera = true }) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22)).foregroundColor(Color("goodPurple"))
                }

                TextField("Message", text: $draftText, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                    .onChange(of: draftText) {
                        draftService.saveDraft(draftText, chatId: chat.id ?? "")
                    }

                Button(action: sendTextMessage) {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showGallery = true }) {
                    Image(systemName: "photo.stack")
                        .foregroundColor(Color("goodPurple"))
                }
                .disabled(imageURLs.isEmpty)
            }
        }
        .onAppear {
            draftText = draftService.loadDraft(chatId: chat.id ?? "")
            startListening()
        }
        .onDisappear { stopListening() }
        .sheet(isPresented: $showCamera) {
            CameraView { image in Task { await sendImage(image) } }
        }
        .sheet(isPresented: $showGallery) {
            ChatGalleryView(imageURLs: imageURLs)
        }
    }

    private func sendTextMessage() {
        let text = draftText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let chatId = chat.id else { return }
        let name = authManager.user?.displayName ?? "User"
        draftText = ""
        draftService.clearDraft(chatId: chatId)
        Task { try? await chatService.sendMessage(chatId: chatId, text: text, senderName: name) }
    }

    private func sendPickedPhoto(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        selectedPhotoItem = nil
        await sendImage(image)
    }

    private func sendImage(_ image: UIImage) async {
        guard let chatId = chat.id else { return }
        let name = authManager.user?.displayName ?? "User"
        isUploadingPhoto = true; uploadError = nil
        do {
            let urlString = try await uploadService.uploadChatImage(image, chatId: chatId)
            try? await chatService.sendMessage(chatId: chatId, text: urlString, senderName: name)
        } catch { uploadError = error.localizedDescription }
        isUploadingPhoto = false
    }

    private func startListening() {
        guard let chatId = chat.id else { return }
        listener = chatService.listenToMessages(chatId: chatId) { incoming in
            messages = incoming
        } as AnyObject
    }

    private func stopListening() {
        if let reg = listener as? ListenerRegistration { reg.remove() }
        listener = nil
    }
}

private struct MessageBubble: View {
    let message: Message
    let isMe:    Bool

    private var isImage: Bool { message.text.hasPrefix(ImageUploadService.imagePrefix) }
    private var imageURLString: String {
        String(message.text.dropFirst(ImageUploadService.imagePrefix.count))
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isMe { Spacer(minLength: 60) }

            VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
                if !isMe {
                    Text(message.senderName)
                        .font(.caption2).foregroundColor(.gray).padding(.leading, 4)
                }

                if isImage {
                    CachedAsyncImage(urlString: imageURLString)
                        .scaledToFill()
                        .frame(maxWidth: 220, maxHeight: 280)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    Text(message.text)
                        .font(.system(size: 15))
                        .foregroundColor(isMe ? .white : .black)
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(isMe ? Color("goodPurple") : Color.gray.opacity(0.15))
                        .cornerRadius(18)
                }

                if let date = message.sentAt {
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 10))
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(isMe ? .trailing : .leading, 4)
                }
            }

            if !isMe { Spacer(minLength: 60) }
        }
    }
}

struct ChatGalleryView: View {
    let imageURLs: [String]
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if imageURLs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundColor(Color(.systemGray3))
                        Text("No photos yet")
                            .font(.headline).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        GeometryReader { geo in
                            let size = (geo.size.width - 4) / 3
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(imageURLs, id: \.self) { urlString in
                                    CachedAsyncImage(urlString: urlString)
                                        .scaledToFill()
                                        .frame(width: size, height: size)
                                        .clipped()
                                }
                            }
                        }
                        .frame(minHeight: 300)
                    }
                }
            }
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera; picker.delegate = context.coordinator
        picker.allowsEditing = false; return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        init(onCapture: @escaping (UIImage) -> Void) { self.onCapture = onCapture }
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { onCapture(image) }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
