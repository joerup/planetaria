//
//  Photo.swift
//
//
//  Created by Joe Rupertus on 1/20/24.
//

import Foundation

public struct Photo: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var source: String
    public var desc: String
    
    public static func decode(from fileName: String) async -> [Photo] {
        guard let file = Bundle.main.path(forResource: fileName, ofType: "json"),
              let json = try? String(contentsOfFile: file),
              let data = json.data(using: .utf8),
              let photos = try? JSONDecoder().decode([Photo].self, from: data)
        else { return [] }
        return photos
    }
}
