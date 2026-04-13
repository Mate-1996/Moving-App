//
//  ImageUploadService.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-04-11.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseAuth

class ImageUploadService {
    private let storage = Storage.storage()

    static let imagePrefix = "img::"

    func uploadChatImage(_ image: UIImage, chatId: String) async throws -> String {
        guard Auth.auth().currentUser != nil else {
            throw UploadError.notAuthenticated
        }

        guard let data = image.jpegData(compressionQuality: 0.6) else {
            throw UploadError.compressionFailed
        }

        let filename = "\(UUID().uuidString).jpg"
        let path = "chatImages/\(chatId)/\(filename)"
        let ref = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return Self.imagePrefix + url.absoluteString
    }
}

enum UploadError: LocalizedError {
    case notAuthenticated
    case compressionFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:  return "You must be logged in to send images"
        case .compressionFailed: return "Could not process the image"
        }
    }
}
