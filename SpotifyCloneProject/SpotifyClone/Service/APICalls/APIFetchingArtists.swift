//
//  APIFetchingArtists.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/29/21.
//

import Foundation
import Alamofire

class APIFetchingArtists {

  enum ArtistsEndpointInAPI {
    case userFavoriteArtists
    case userFollowedArtists
    case aritstInfo(artistsID: [String])
  }

  func getArtist(using endPoint: ArtistsEndpointInAPI,
                 with accessToken: String,
                 limit: Int = 10,
                 completionHandler: @escaping ([SpotifyModel.MediaItem]) -> Void) {

    let baseURL: String
    var apiEndpoint: Utility.APIEndpoint

    switch endPoint {
    case .userFavoriteArtists:
      baseURL = "https://api.spotify.com/v1/me/top/artists?limit=\(limit)"
      apiEndpoint = .userFavouriteTracks

      fetchArtistsData(baseURL: baseURL, accessToken: accessToken, apiEndpoint: apiEndpoint) { artists in
        completionHandler(artists)
      }

    case .userFollowedArtists:
      baseURL = "https://api.spotify.com/v1/me/following?type=artist"
      apiEndpoint = .userFollowedArtists

      fetchFollowedArtistsData(baseURL: baseURL, accessToken: accessToken, apiEndpoint: apiEndpoint) { artists in
        completionHandler(artists)
      }

    case .aritstInfo(let aritstsIDs):
      baseURL = "https://api.spotify.com/v1/artists?ids=\(aritstsIDs.joined(separator: "%2c"))" // %2c = comma
      apiEndpoint = .artistInfo

      fetchArtistsData(baseURL: baseURL, accessToken: accessToken, apiEndpoint: apiEndpoint) { artistInfo in
        completionHandler(artistInfo)
      }
    }
  }

  // MARK: - Auxiliary functions
  func fetchFollowedArtistsData(
    baseURL: String,
    accessToken: String,
    apiEndpoint: Utility.APIEndpoint,
    completionHandler: @escaping ([SpotifyModel.MediaItem]) -> Void) {

    let urlRequest = Utility.createStandardURLRequest(url: baseURL, accessToken: accessToken)

    AF.request(urlRequest)
      .validate()
      .responseDecodable(of: FollowedArtistResponse.self) { response in

        var artists = [SpotifyModel.MediaItem]()

        let responseStatus = Utility.getResponseStatusCode(
          forValue: response.value,
          responseItemsCount: response.value?.artists.items.count,
          apiEndpoint: .userFollowedArtists
        )
        guard responseStatus != .empty else { return completionHandler(artists) }

        let numberOfArtists = response.value!.artists.items.count

        for artistIndex in 0 ..< numberOfArtists {
          let artist = response.value!.artists.items[artistIndex]
          artists.append(self.parseArtistData(for: artist))
        }
        completionHandler(artists)
      }
  }

  func fetchArtistsData(
    baseURL: String,
    accessToken: String,
    apiEndpoint: Utility.APIEndpoint,
    completionHandler: @escaping ([SpotifyModel.MediaItem]) -> Void ) {

    let urlRequest = Utility.createStandardURLRequest(url: baseURL, accessToken: accessToken)

    AF.request(urlRequest)
      .validate()
      .responseDecodable(of: ArtistResponse.self) { response in

        var artists = [SpotifyModel.MediaItem]()

        let responseStatus = Utility.getResponseStatusCode(
          forValue: response.value,
          responseItemsCount: response.value?.items.count,
          apiEndpoint: .userFavouriteArtists
        )
        guard responseStatus != .empty else { return completionHandler(artists) }

        let numberOfArtists = response.value!.items.count

        for artistIndex in 0 ..< numberOfArtists {
          let artist = response.value!.items[artistIndex]
          artists.append(self.parseArtistData(for: artist))
        }

        completionHandler(artists)
      }
  }

  func parseArtistData(for artist: Artist) -> SpotifyModel.MediaItem {

    let title = artist.name
    let imageURL = artist.images?[0].url
    let id = artist.id

    let followers = artist.followers!.total
    let genres = artist.genres
    let popularity = artist.popularity

    let artistDetails = SpotifyModel.ArtistDetails(followers: followers, genres: genres!,
                                                   popularity: popularity!, id: id)

    let artistItem = SpotifyModel.MediaItem(title: title,
                                            previewURL: "",
                                            imageURL: imageURL ?? "",
                                            authorName: [title],
                                            mediaType: .artist,
                                            id: id,
                                            details: SpotifyModel.DetailTypes.artists(artistDetails: artistDetails))
    return artistItem
  }
}
