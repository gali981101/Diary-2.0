//
//  Diary.swift
//  Diary
//

//  Created by Terry Jason on 2023/12/21.
//

import Foundation
import CoreData

public class Diary: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Diary> {
        return NSFetchRequest<Diary>(entityName: "Diary")
    }
    
    @NSManaged public var title: String
    @NSManaged public var location: String
    @NSManaged public var date: String
    @NSManaged public var weather: String
    @NSManaged public var summary: String
    @NSManaged public var image: Data
    @NSManaged public var moodText: String?
    @NSManaged public var isFavorite: Bool
    
}

extension Diary {
    
    enum Mood: String {
        case awesome, nice, soso, sad, hate
        
        var rawValue: String {
            switch self {
            case .awesome:
                return "awesome"
            case .nice:
                return "nice"
            case .soso:
                return "soso"
            case .sad:
                return "sad"
            case .hate:
                return "hate"
            }
        }
    }
    
    var mood: Mood? {
        get {
            guard let moodText = moodText else { return nil }
            return Mood(rawValue: moodText)
        }
        
        set {
            self.moodText = newValue?.rawValue
        }
    }
    
}
