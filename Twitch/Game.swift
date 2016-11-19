//
//  Game.swift
//  Twitch
//
//  Created by Jim Campagno on 10/30/16.
//  Copyright © 2016 Gamesmith, LLC. All rights reserved.
//

import Foundation
import UIKit

final class Game {
    
    private static let defaultValue: String = "n/a"
    
    let id: String
    let name: String
    var channels: String
    var viewers: String
    var largeImage: Image
    var smallImage: Image
    weak var delegate: ImageStateDelegate?
    
    init?(json: JSON) {
        
        guard let game = json["game"] as? JSON,
            let id = game["_id"] as? String,
            let box = game["box"] as? JSON else { return nil }
        
        self.id = id
        self.name = game["name"] as? String ?? Game.defaultValue
        self.viewers = json["viewers"] as? String ?? Game.defaultValue
        self.channels = json["channels"] as? String ?? Game.defaultValue
        
        let largeImageURLString = box["large"] as? String ?? Game.defaultValue
        let smallImageURLString = box["small"] as? String ?? Game.defaultValue
        
        self.largeImage = Image(imageSize: .large, url: URL(string: largeImageURLString))
        self.smallImage = Image(imageSize: .small, url: URL(string: smallImageURLString))
        
        largeImage.delegate = self
        smallImage.delegate = self
    }
    
}



// MARK: - DownloadStateDelegate
extension Game: DownloadStateDelegate {
    
    func downloadStateHasChanged(with image: Image) {
        
        delegate?.imageStateChange(with: image)
        
    }

}


protocol DownloadStateDelegate: class {
    
    func downloadStateHasChanged(with image: Image)
    
}





