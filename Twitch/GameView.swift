//
//  GameView.swift
//  Twitch
//
//  Created by Jim Campagno on 11/2/16.
//  Copyright © 2016 Gamesmith, LLC. All rights reserved.
//

import UIKit

class GameView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var gamePosterImageView: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var channelsLabel: UILabel!
    
    var game: Game! {
        didSet {
            gamePosterImageView.image = game.largeImage.gamePoster
            gameNameLabel.text = game.name
            viewersLabel.text = game.viewers
            channelsLabel.text = game.channels
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("GameView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.constrainEdges(to: self)
    }
    
    
}


// MARK: - ImageStateDelegate
extension GameView: ImageStateDelegate {
    
    func imageStateChange(with image: Image) {
        
        
        
        switch image.downloadState {
        case .downloading, .error, .notBegun: gamePosterImageView.image = #imageLiteral(resourceName: "Loading")
        case .complete:
            
            
            
            gamePosterImageView.image = game.largeImage.image!
        }
        
        
        
    }
    
   
}



protocol ImageStateDelegate: class {
    
    func imageStateChange(with image: Image)
    
}



extension UIView {
    
    func constrainEdges(to view: UIView) {
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
}
