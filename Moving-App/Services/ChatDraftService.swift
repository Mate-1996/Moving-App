//
//  ChatDraftService.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-28.
//

import CoreData
import Foundation

class ChatDraftService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func saveDraft(_ text: String, chatId: String) {
        let draft = fetchOrCreate(chatId: chatId)
        draft.text   = text
        draft.chatId = chatId
        try? context.save()
    }

    func loadDraft(chatId: String) -> String {
        let request: NSFetchRequest<ChatDraft> = ChatDraft.fetchRequest()
        request.predicate = NSPredicate(format: "chatId == %@", chatId)
        request.fetchLimit = 1
        return (try? context.fetch(request).first)?.text ?? ""
    }

    func clearDraft(chatId: String) {
        let request: NSFetchRequest<ChatDraft> = ChatDraft.fetchRequest()
        request.predicate = NSPredicate(format: "chatId == %@", chatId)
        if let draft = try? context.fetch(request).first {
            context.delete(draft)
            try? context.save()
        }
    }

    private func fetchOrCreate(chatId: String) -> ChatDraft {
        let request: NSFetchRequest<ChatDraft> = ChatDraft.fetchRequest()
        request.predicate = NSPredicate(format: "chatId == %@", chatId)
        request.fetchLimit = 1
        if let existing = try? context.fetch(request).first {
            return existing
        }
        return ChatDraft(context: context)
    }
}
