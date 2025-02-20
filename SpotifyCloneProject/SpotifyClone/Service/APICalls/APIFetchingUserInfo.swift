//
//  APIFetchingUserInfo.swift
//  SpotifyClone
//
//  Created by Gabriel on 10/13/21.
//

import Foundation
import Alamofire

class APIFetchingUserInfo {

  enum UserEndpointInAPI {
    case checkIfUserFollows
    case changeFollowingState(state: FollowingState)
  }

  enum ValidMediaType: Hashable {
    case track
    case album
    case show
    case episode
    case playlist(userID: String)
    case artist
  }

  enum FollowingState {
    case follow
    case unfollow
  }

  func checkUserFollow(using endpoint: UserEndpointInAPI,
                       in mediaType: ValidMediaType,
                       with accessToken: String,
                       mediaID: String,
                       completionHandler: @escaping (Bool) -> Void) {

    var baseURL: String
    var apiEndpoint: Utility.APIEndpoint
    var currentUserID: String?

    switch endpoint {
    case .checkIfUserFollows:
        print("DEBUG: check if user follows")
        baseURL = constructBaseURL(mediaType: mediaType, mediaID: mediaID, userID: currentUserID ?? "")
        apiEndpoint = .checkIfUserFollows
      
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        AF.request(urlRequest)
          .validate()
          .responseJSON { response in
            switch response.result {
            case .success:
                guard let data = response.data else {
                    print("DEBUG: Response data is nil")
                    return completionHandler(false)
                }

                let decoder = JSONDecoder()
                let responseArray = try? decoder.decode([Bool].self, from: data)

                guard let responseArray = responseArray, !responseArray.isEmpty else {
                    print("DEBUG: Decoding failed or response array is empty")
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

    case .changeFollowingState(let followingState):
        print("DEBUG: change following state")
        baseURL = constructBaseURL(mediaType: mediaType, mediaID: mediaID, userID: currentUserID ?? "")
        apiEndpoint = .changeFollowingState
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        print("DEBUG: Making a request from \(urlRequest)")

        switch followingState {
        case .follow:
          urlRequest.httpMethod = "PUT"
        case .unfollow:
          urlRequest.httpMethod = "DELETE"
        }

        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        AF.request(urlRequest)
          .validate()
          .responseJSON { response in
            switch response.result {
            case .success:
                print("DEBUG: Request succeeded")
                completionHandler(true)
            case .failure(let error):
                print("DEBUG: Request failed with error: \(error.localizedDescription)")

                if let statusCode = response.response?.statusCode {
                    print("DEBUG: HTTP Status Code: \(statusCode)")
                }

                completionHandler(false)
            }
          }

    }
  }

  func fetchUserData(
      urlRequest: URLRequest,
      apiEndpoint: Utility.APIEndpoint,
      completionHandler: @escaping (Bool) -> Void
  ) {
      AF.request(urlRequest)
          .validate()
          .responseJSON { response in
              // Always perform the status check
              let responseStatus = Utility.getResponseStatusCode(
                  forValue: response.data,
                  responseItemsCount: response.data?.count ?? 0,
                  apiEndpoint: apiEndpoint
              )

              // If the response status is empty, we return early
              guard responseStatus != .empty else {
                  completionHandler(false)
                  return
              }

              // If no data was received, we handle the error case
              guard let data = response.data else {
                  debugPrint(response.error?.localizedDescription ?? "Unknown error")
                  completionHandler(true) // Indicates failure
                  return
              }

              // Attempt to decode the response if data is available
              do {
                  let decoder = JSONDecoder()

                  if let decodedResponse = try? decoder.decode([Bool].self, from: data), !decodedResponse.isEmpty {
                      completionHandler(decodedResponse.first ?? false)
                  } else {
                      // If decoding fails, return false
                      completionHandler(false)
                  }

              } catch {
                  fatalError("Error decoding response.")
              }
          }
  }


  func constructBaseURL(mediaType: ValidMediaType, mediaID: String, userID: String) -> String {
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
          // Ensure userID is not nil for playlists
          guard userID == userID else {
                return "DEBUG: Invalid userID for playlist"
          }
          return "https://api.spotify.com/v1/playlists/\(mediaID)/followers/contains?ids=\(userID)"
      case .artist:
          return "https://api.spotify.com/v1/me/following/contains?type=artist&ids=\(mediaID)"
      }
  }
}
