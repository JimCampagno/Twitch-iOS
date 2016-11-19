//
//  TwitchClient.swift
//  TwitchTheTatMan
//
//  Created by Jim Campagno on 10/13/16.
//  Copyright © 2016 Gamesmith, LLC. All rights reserved.
//

import Foundation

typealias JSON = [String : Any]

struct Twitch {
    
    fileprivate static let baseURL: String = "https://api.twitch.tv/kraken"
    
    func get(request: TwitchRequest, handler: @escaping ([Stream]?) -> Void) {
        let urlRequest = generateURLRequest(with: request.url)
        let urlSession = generateURLSession()
        
        generateJSON(withSession: urlSession, request: urlRequest) { json in
            guard let json = json else { handler(nil); return }
            // TODO: Based upon type of TwitchRequest", create necessary structures and pass along to handler.
            print(json)
        }
    }
    
}


// MARK: - API Call Methods
extension Twitch {
    
    func generateURLRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/vnd.twitchtv.v3+json", forHTTPHeaderField: "Accept")
        request.addValue(R.clientID, forHTTPHeaderField: "Client-ID")
        return request
    }
    
    func generateURLSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        return session
    }
    
    func generateJSON(withSession session: URLSession, request: URLRequest, handler: @escaping (JSON?) -> Void) {
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data else { handler(nil); return }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! JSON else { handler(nil); return }
                handler(json)
            }
            }.resume()
    }
    
}

// MARK: Other Data Types (yo)
enum TwitchRequest {
    
    case topGames
    case topVideos
    case featuredGames
    case searchStreams(query: ValidTwitchSearch)
    case searchGames(query: ValidTwitchSearch)
    case searchChannels(query: ValidTwitchSearch)
    
    var url: URL {
        switch self {
        case .topGames:
            return URL.twitchURL(withEndpoint: "/games/top")
        case .topVideos:
            return URL.twitchURL(withEndpoint: "/videos/top")
        case .featuredGames:
            return URL.twitchURL(withEndpoint: "/streams/featured")
        case let .searchStreams(query):
            return URL.twitchURL(withEndpoint: "/search/streams?q=\(query.string)")
        case let .searchGames(query):
            return URL.twitchURL(withEndpoint: "/search/games?q=\(query.string)&type=suggest")
        case let .searchChannels(query):
            return URL.twitchURL(withEndpoint: "/search/channels?q=\(query.string)")
        }
    }
    
}

struct ValidTwitchSearch {
    
    let string: String
    
    init?(_ string: String) {
        guard let escapedString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return nil }
        self.string = escapedString
    }
    
}

extension URL {
    
    static func twitchURL(withEndpoint endpoint: String) -> URL {
        return URL(string: Twitch.baseURL + endpoint)!
    }
    
}
