import Alamofire
import Foundation

class APIFetchingTracks {

  enum TrackEndpointInAPI {
    case userRecentlyPlayed
    case userFavoriteTracks
    case userLikedTracks
    case topTracksFromArtist(artistID: String)
    case tracksFromPlaylist(playlistID: String)
    case tracksFromAlbum(albumID: String)
  }

  func getTrack(
    using endPoint: TrackEndpointInAPI,
    with accessToken: String,
    limit: Int = 6,
    offset: Int = 0,
    completionHandler: @escaping ([SpotifyModel.MediaItem]) -> Void
  ) {

    let baseURL: String
    var apiEndpoint: Utility.APIEndpoint

    switch endPoint {
    case .userRecentlyPlayed:
      baseURL = "https://api.spotify.com/v1/me/player/recently-played?limit=20"
      apiEndpoint = .userRecentlyPlayed

    case .userFavoriteTracks:
      baseURL = "https://api.spotify.com/v1/me/top/tracks?limit=\(limit)&offset=\(offset)"
      apiEndpoint = .userFavouriteTracks

    case .userLikedTracks:
      baseURL = "https://api.spotify.com/v1/me/tracks?limit=\(limit)&offset=\(offset)"
      apiEndpoint = .userLikedTracks

    case .topTracksFromArtist(let artistID):
      baseURL = "https://api.spotify.com/v1/artists/\(artistID)/top-tracks?market=US"
      apiEndpoint = .topTracksFromArtist

    case .tracksFromPlaylist(let playlistID):
      baseURL =
        "https://api.spotify.com/v1/playlists/\(playlistID)/tracks?limit=\(limit)&offset=\(offset)"
      apiEndpoint = .tracksFromPlaylist

    case .tracksFromAlbum(let albumID):
      baseURL =
        "https://api.spotify.com/v1/albums/\(albumID)/tracks?limit=\(limit)&offset=\(offset)"
      apiEndpoint = .tracksFromAlbum
    }

    fetchTracksData(baseURL: baseURL, accessToken: accessToken, apiEndpoint: apiEndpoint) { tracks in
      completionHandler(tracks)
    }

  }

  // MARK: - Helper Functions

  private func fetchTracksData(
    baseURL: String,
    accessToken: String,
    apiEndpoint: Utility.APIEndpoint,
    completionHandler: @escaping ([SpotifyModel.MediaItem]) -> Void
  ) {
    let urlRequest = Utility.createStandardURLRequest(url: baseURL, accessToken: accessToken)

    AF.request(urlRequest)
      .validate()
      .responseDecodable(of: TrackResponse.self) { response in

        let responseStatus = Utility.getResponseStatusCode(
          forValue: response.value,
          responseItemsCount: response.value?.tracks.count,
          apiEndpoint: apiEndpoint
        )
        guard responseStatus != .empty else { return completionHandler([SpotifyModel.MediaItem]()) }

        completionHandler(self.parseResponse(response))
      }
  }

  private func parseResponse(_ response: DataResponse<TrackResponse, AFError>) -> [SpotifyModel
    .MediaItem] {

    var trackItems = [SpotifyModel.MediaItem]()
    let numberOfItems = response.value!.tracks.count

    for trackIndex in 0..<numberOfItems {
      let track = response.value!.tracks[trackIndex]

      let title = track.name
      let previewURL = track.preview_url
      let author = track.artists
      let id = track.id
      var authorName = [String]()

      let popularity = track.popularity
      let explicit = track.explicit
      let durationInMs = track.duration_ms

      let imageURL = track.album?.images?[0].url
      let lowResImageURL = track.album?.images?.last?.url
      let albumName = track.album?.name
      let albumID = track.album?.id
      let numberOfTracks = track.album?.total_tracks
      let releaseDate = track.album?.release_date

      for artistIndex in track.artists.indices {
        authorName.append(track.artists[artistIndex].name)
      }

      let albumDetails = SpotifyModel.AlbumDetails(
        name: albumName ?? "", numberOfTracks: numberOfTracks ?? 0,
        releaseDate: releaseDate ?? "0", id: albumID ?? "")
      let trackDetails = SpotifyModel.TrackDetails(
        popularity: popularity ?? 0, explicit: explicit,
        durationInMs: durationInMs, id: id, album: albumDetails)

      let trackItem =
        SpotifyModel
        .MediaItem(
          title: title, previewURL: previewURL ?? "", imageURL: imageURL ?? "",
          lowResImageURL: lowResImageURL ?? "", authorName: authorName, author: author,
          mediaType: .track, id: id,
          details: SpotifyModel.DetailTypes.tracks(trackDetails: trackDetails))

      trackItems.append(trackItem)
    }
    return trackItems
  }
}
