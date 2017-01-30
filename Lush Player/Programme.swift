//
//  Programme.swift
//  Lush Player
//
//  Created by Simon Mitchell on 02/12/2016.
//  Copyright © 2016 ThreeSidedCube. All rights reserved.
//

import Foundation

/// An structual representation of a radio or TV programme back from the LUSH API
struct Programme {
    
    /// An enum representing the media type of the programme
    ///
    /// - TV: The programme is a TV episode
    /// - radio: The programme is a Radio episode
    enum Media: String {
        case TV = "tv_program"
        case radio = "radio_program"
        
        func displayString() -> String {
            switch self {
            case .TV:
                return "TV"
            case .radio:
                return "RADIO"
            }
        }
        
        /// Override the default initialiser for raw values. The Home channels use "tv_program" and "radio_program" as their types but the categories endpoint uses "tv" and "radio"
        ///
        /// - Parameter rawValue: The string that defines the type for
        init?(rawValue: String) {
            switch rawValue {
                case "tv_program": self = .TV
                case "tv": self = .TV
                case "radio_program": self = .radio
                case "radio": self = .radio
                default: return nil
            }
        }
    }
    
    /// A unique ID for the programme
    let id: String
    
    /// The global unique ID for the programme
    var guid: String?
    
    /// The title of the programme
    var title: String?
    
    /// A short description of the programme
    var description: String?
    
    /// A URL to the thumbnail data for the programme
    var thumbnailURL: URL?
        
    /// A file which can be used to play the programme
    /// - Note: This should only be present for Radio programmes
    var file: URL?
    
    /// The date of the programme
    var date: Date?
    
    /// A string representation of the programme date
    var dateString: String?
    
    /// A string describing the duration of the programme
    var duration: String?
    
    /// The media type of the programme
    let media: Media
    
    /// Initialises a new Programme with a dictionary representation and media type
    ///
    /// - Note: This is an optional initialiser, and will return nil if there was no unique id for the programme,
    /// as it is then un-usable with API calls.
    ///
    /// - Parameter dictionary: A dictionary representation of the programme
    /// - Parameter media: The media type of the programme
    init?(dictionary: [AnyHashable : Any], media: Media) {
        
        guard let _id = dictionary["id"] as? String else { return nil }
        
        self.media = media
        id = _id
        
        guid = dictionary["guid"] as? String
        
        if let fileString = dictionary["file"] as? String {
            file = URL(string: fileString)
        }
        
        if file == nil, let urlString = dictionary["url"] as? String {
            file = URL(string: urlString)
        }
        
        title = (dictionary["title"] as? String)?.htmlUnescape()
        description = (dictionary["description"] as? String)?.htmlUnescape()
        if let url = dictionary["thumbnail"] as? String {
            thumbnailURL = URL(string: url)
        }
        
        duration = dictionary["duration"] as? String
        
        dateString = dictionary["date"] as? String
        if let dateString = dateString {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            date = dateFormatter.date(from: dateString)
        }
    }
}
