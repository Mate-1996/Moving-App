//
//  MoveNoteService.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-28.
//

import CoreData
import Foundation

class MoveNoteService {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func addNote(text: String, requestId: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let note = MoveNote(context: context)
        note.requestId  = requestId
        note.text = text
        note.createdAt = Date()

        save()
    }

    func fetchNotes(for requestId: String) -> [MoveNote] {
        let request: NSFetchRequest<MoveNote> = MoveNote.fetchRequest()
        request.predicate = NSPredicate(format: "requestId == %@", requestId)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func deleteNote(_ note: MoveNote) {
        context.delete(note)
        save()
    }

    private func save() {
        guard context.hasChanges else { return }
        try? context.save()
    }
}
