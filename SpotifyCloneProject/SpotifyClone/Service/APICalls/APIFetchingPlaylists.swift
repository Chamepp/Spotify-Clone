//
//  APIFetchingPlaylists.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/29/21.
//

import Foundation
import Alamofire

class APIFetchingPlaylists {

  enum PlaylistsEndpointInAPI {
    case featuredPlaylists
    case playlistWithKeyword(keyWord: String)
    case currentUserPlaylists
  }

  func getPlaylist(using endPoint: PlaylistsEndpointInAPI,
                   with accessToken: String,
                   limit: Int = 10,
                   offset: Int = 0,
                   completionHandler: @escaping ([SpotifyModel.MediaItem]) -> Void) {

    let country = "US"
    let baseUrl: String

    switch endPoint {
    case .featuredPlaylists:
      baseUrl = "https://api.spotify.com/v1/browse/featured-playlists?country=\(country)&limit=\(limit)&offset=\(offset)"

    case .playlistWithKeyword(let keyWord):
      let keyWord = keyWord.replacingOccurrences(of: " ", with: "+")
      let type = "playlist"
      baseUrl = "https://api.spotify.com/v1/search?q=\(keyWord)&type=\(type)&market=\(country)&limit=\(limit)&offset=\(offset)"

    case .currentUserPlaylists:
      baseUrl = "https://api.spotify.com/v1/me/playlists"
    }

    var urlRequest = URLRequest(url: URL(string: baseUrl)!)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    urlRequest.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad

    var trackItems = [SpotifyModel.MediaItem]()

    AF.request(urlRequest)
      .validate()
      .responseDecodable(of: PlaylistResponse.self) { response in
        parseResponse(response)
      }

    func parseResponse(_ response: DataResponse<PlaylistResponse, AFError>) {

      guard let data = response.value else {
        fatalError("Error receiving playlists from API.")
      }

      let numberOfPlaylists = data.playlists.count

      guard numberOfPlaylists != 0 else {
        completionHandler(trackItems)
        print("The API response was corrects but empty. We'll just return []")
        return
      }

      for playlistIndex in 0 ..< numberOfPlaylists {
        let playlist = data.playlists[playlistIndex]

        let sectionTitle = data.message
        let title = playlist.name
        let imageURL = playlist.images[0].url
        let id = playlist.id

        let description = playlist.description
        let playlistTracks = playlist.tracks
        let mediaOwner = playlist.owner

        let infoAboutTracksInPlaylist = SpotifyModel.PlaylistTracks(numberOfSongs: playlistTracks.total, href: playlistTracks.href)
        let playlistOwner = SpotifyModel.MediaOwner(displayName: mediaOwner.display_name, id: mediaOwner.id)
        let playlistDetails = SpotifyModel.PlaylistDetails(description: description,
                                                           playlistTracks: infoAboutTracksInPlaylist,
                                                           owner: playlistOwner,
                                                           id: id)

        let playlistItem = SpotifyModel.MediaItem(title: title,
                                                  previewURL: sectionTitle ?? "You Might Like",
                                                  imageURL: imageURL,
                                                  authorName: [mediaOwner.display_name],
                                                  mediaType: .playlist,
                                                  id: id,
                                                  details: SpotifyModel.DetailTypes.playlists(playlistDetails: playlistDetails))
        trackItems.append(playlistItem)
      }
      completionHandler(trackItems)
    }

  }

}
