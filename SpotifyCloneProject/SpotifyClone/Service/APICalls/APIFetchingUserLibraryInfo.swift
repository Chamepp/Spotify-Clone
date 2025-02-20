//
//  APIFetchingUserLibraryInfo.swift
//  SpotifyClone
//
//  Created by Gabriel on 10/27/21.
//

import Foundation
import Alamofire

class APIFetchingUserLibraryInfo {

  enum APIUserLibraryInEndpoint {
    case getNumberOfLikedSongs
    case getNumberOfSavedEpisodes
  }

  func fetchUserInfo(using endpoint: APIUserLibraryInEndpoint, with accessToken: String, completionHandler: @escaping (Int) -> Void) {
    var baseURL: String
    var apiEndpoint: Utility.APIEndpoint

    switch endpoint {
    case .getNumberOfLikedSongs:
      baseURL = "https://api.spotify.com/v1/me/tracks?limit=1"
      apiEndpoint = .getNumberOfLikedSongs
    case .getNumberOfSavedEpisodes:
      baseURL = "https://api.spotify.com/v1/me/episodes?limit=1"
      apiEndpoint = .getNumberOfSavedEpisodes
    }
    fetchUserData(baseURL: baseURL, accessToken: accessToken, apiEndpoint: apiEndpoint) { userData in
      completionHandler(userData)
    }
  }

  func fetchUserData(
    baseURL: String,
    accessToken: String,
    apiEndpoint: Utility.APIEndpoint,
    completionHandler: @escaping (Int) -> Void) {
    let urlRequest = Utility.createStandardURLRequest(url: baseURL, accessToken: accessToken)

    AF.request(urlRequest)
      .validate()
      .responseDecodable(of: NumberOfSavedItemsResponse.self) { response in
        let responseStatus = Utility.getResponseStatusCode(
          forValue: response.value,
          responseItemsCount: response.value?.total,
          apiEndpoint: apiEndpoint
        )
        guard responseStatus != .empty else { return completionHandler( Int() ) }

        completionHandler(response.value!.total)
      }
  }

}
