//
//  Image.swift
//  Twitch
//
//  Created by Jim Campagno on 10/30/16.
//  Copyright © 2016 Gamesmith, LLC. All rights reserved.
//

import Foundation
import UIKit


final class Image {
    
    let imageSize: ImageSize
    
    var url: URL?
    
    weak var delegate: DownloadStateDelegate?

    var image: UIImage?
    
    var gamePoster: UIImage {
        get {
            switch downloadState {
            case .error: return #imageLiteral(resourceName: "Loading")
            case .notBegun: downloadImage { _ in }; return #imageLiteral(resourceName: "Loading")
            case .downloading: return #imageLiteral(resourceName: "Loading")
            case .complete: return image!
            }
        }
    }
    
    var downloadState: DownloadState {
        didSet {
            delegate?.downloadStateHasChanged(with: self)
        }
    }
    
    
    init(imageSize: ImageSize, url: URL?, downloadState: DownloadState = .notBegun) {
        self.imageSize = imageSize
        self.url = url
        self.downloadState = downloadState
    }
    
    func downloadImage(handler: @escaping (Bool) -> Void) {
        guard downloadState == .notBegun else { handler(false); return }
        
        downloadState = .downloading
        
        kickOffDownload { [unowned self] newImage, successfulDownload in
            DispatchQueue.main.async {
                if successfulDownload {
                    self.image = newImage
                    handler(true)
                    self.downloadState = .complete
                }
            }
        }
    }
    
}




// MARK: - Download
extension Image {
    
    fileprivate  func kickOffDownload(handler: @escaping (UIImage?, Bool) -> Void) {
        guard let imageURL = url else { handler(nil, false); return }
        
        let session = createSession()
        let request = createRequest(with: imageURL)
        
        resumeDataTask(session: session, request: request) { image, success in
            DispatchQueue.main.async {
                handler(image, success)
            }
        }
        
    }
    
    fileprivate func createSession() -> URLSession {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        return session
    }
    
    fileprivate func createRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    fileprivate  func resumeDataTask(session: URLSession, request: URLRequest, handler: @escaping (UIImage?, Bool) -> Void) {
        let dataTask =  session.dataTask(with: request) { data, response, error in
            guard let imageData = data,
                let image = UIImage(data: imageData) else { handler(nil, false); return }
            
            DispatchQueue.main.async {
                handler(image, true)
            }
        }
        
        dataTask.resume()
    }
    
}



enum ImageSize {
    
    case large
    case small
    case none
    
}


enum DownloadState: Int {
    
    case notBegun
    case complete
    case downloading
    case error
    
}
