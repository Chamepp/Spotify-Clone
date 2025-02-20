import Alamofire
import Foundation

class APIFetchingUserInfo {

  enum UserEndpointInAPI {
    case checkIfUserFollows(mediaType: ValidMediaType, mediaID: String)
    case changeFollowingState(state: FollowingState, mediaType: ValidMediaType, mediaID: String)
    case getNumberOfLikedSongs
    case getNumberOfSavedEpisodes
  }

  enum UserStatsResult {
    case follows(Bool)
    case likes(Int)
  }

  enum ValidMediaType: Hashable {
    case track
    case album
    case show
    case episode
    case playlist(userID: String)
    case artist
  }

  enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
  }

  enum FollowingState {
    case follow
    case unfollow
    case checkUserFollowStatus
  }

  func checkUserStats(
    using endpoint: UserEndpointInAPI,
    with accessToken: String,
    completionHandler: @escaping (UserStatsResult) -> Void
  ) {

    var baseURL: String
    var apiEndpoint: Utility.APIEndpoint
    var currentUserID: String?

    switch endpoint {
    case .checkIfUserFollows(let mediaType, let mediaID):
      baseURL = constructBaseURL(
        mediaType: mediaType, mediaID: mediaID, userID: currentUserID ?? "")
      apiEndpoint = .checkIfUserFollows
      fetchUserFollowData(
        baseURL: baseURL,
        accessToken: accessToken,
        apiEndpoint: apiEndpoint,
        method: .checkUserFollowStatus
      ) { userIsFollowing in
        completionHandler(.follows(userIsFollowing))
      }
    case .changeFollowingState(let followingState, let mediaType, let mediaID):
      baseURL = constructBaseURL(
        mediaType: mediaType, mediaID: mediaID, userID: currentUserID ?? "")
      apiEndpoint = .changeFollowingState
      fetchUserFollowData(
        baseURL: baseURL,
        accessToken: accessToken,
        apiEndpoint: apiEndpoint,
        method: followingState
      ) { changeFollowingState in
        completionHandler(.follows(changeFollowingState))
      }
    case .getNumberOfLikedSongs:
      baseURL = "https://api.spotify.com/v1/me/tracks?limit=1"
      apiEndpoint = .getNumberOfLikedSongs
      fetchUserLikeData(
        baseURL: baseURL,
        accessToken: accessToken,
        apiEndpoint: apiEndpoint
      ) { numberOfLikes in
        completionHandler(.likes(numberOfLikes))
      }
    case .getNumberOfSavedEpisodes:
      baseURL = "https://api.spotify.com/v1/me/episodes?limit=1"
      apiEndpoint = .getNumberOfSavedEpisodes
      fetchUserLikeData(
        baseURL: baseURL,
        accessToken: accessToken,
        apiEndpoint: apiEndpoint
      ) { numberOfEpisodes in
        completionHandler(.likes(numberOfEpisodes))
      }
    }
  }

  // MARK: - Helper Functions

  private func fetchUserFollowData(
    baseURL: String,
    accessToken: String,
    apiEndpoint: Utility.APIEndpoint,
    method: FollowingState,
    completionHandler: @escaping (Bool) -> Void
  ) {

    var urlRequest = URLRequest(url: URL(string: baseURL)!)
    urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    switch method {
    case .follow:
      urlRequest.httpMethod = HTTPMethod.put.rawValue
    case .unfollow:
      urlRequest.httpMethod = HTTPMethod.delete.rawValue
    case .checkUserFollowStatus:
      urlRequest.httpMethod = HTTPMethod.get.rawValue
    }

    AF.request(urlRequest)
      .validate()
      .responseJSON { response in
        switch response.result {
        case .success:
          guard let data = response.data else {
            return completionHandler(false)
          }
          let decoder = JSONDecoder()
          let responseArray = try? decoder.decode([Bool].self, from: data)

          guard let responseArray = responseArray, !responseArray.isEmpty else {
            return completionHandler(false)
          }

          let responseStatus = Utility.getResponseStatusCode(
            forValue: responseArray,
            responseItemsCount: responseArray.count,
            apiEndpoint: apiEndpoint
          )

          guard responseStatus != .empty else {
            return completionHandler(false)
          }

          completionHandler(responseArray.first ?? false)

        case .failure(let error):
          print("DEBUG: Request failed - \(error.localizedDescription)")

          if let statusCode = response.response?.statusCode {
            print("DEBUG: HTTP Status Code: \(statusCode)")
          }

          completionHandler(false)
        }
      }
  }

  private func fetchUserLikeData(
    baseURL: String,
    accessToken: String,
    apiEndpoint: Utility.APIEndpoint,
    completionHandler: @escaping (Int) -> Void
  ) {
    let urlRequest = Utility.createStandardURLRequest(url: baseURL, accessToken: accessToken)

    AF.request(urlRequest)
      .validate()
      .responseDecodable(of: NumberOfSavedItemsResponse.self) { response in
        let responseStatus = Utility.getResponseStatusCode(
          forValue: response.value,
          responseItemsCount: response.value?.total,
          apiEndpoint: apiEndpoint
        )
        guard responseStatus != .empty else { return completionHandler(Int()) }

        completionHandler(response.value!.total)
      }
  }

  private func constructBaseURL(mediaType: ValidMediaType, mediaID: String, userID: String)
    -> String {
    switch mediaType {
    case .track:
      return "https://api.spotify.com/v1/me/tracks/contains?ids=\(mediaID)"
    case .album:
      return "https://api.spotify.com/v1/me/albums/contains?ids=\(mediaID)"
    case .show:
      return "https://api.spotify.com/v1/me/shows/contains?ids=\(mediaID)"
    case .episode:
      return "https://api.spotify.com/v1/me/episodes/contains?ids=\(mediaID)"
    case .playlist(let userID):
      guard userID == userID else {
        return "DEBUG: Invalid userID for playlist"
      }
      return "https://api.spotify.com/v1/playlists/\(mediaID)/followers/contains?ids=\(userID)"
    case .artist:
      return "https://api.spotify.com/v1/me/following/contains?type=artist&ids=\(mediaID)"
    }
  }
}
