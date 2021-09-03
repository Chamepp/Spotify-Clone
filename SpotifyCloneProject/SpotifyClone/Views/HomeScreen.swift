//
//  HomeScreen.swift
//  SpotifyClone
//
//  Created by Gabriel on 8/31/21.
//

// TODO: Reduce duplicated code
// TODO: Convert to arrays and render using ForEach
// TODO: Separate into different items

import SwiftUI

struct HomeScreen: View {
  var body: some View {
    RadialGradientBackground()
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading) {
        SmallSongCardsGrid()
          .padding(.horizontal, lateralPadding)
          .padding(.bottom, paddingSectionSeparation)
        RecentlyPlayedScrollView()
          .padding(.bottom, paddingSectionSeparation)
        TopPodcastsScrollView()
          .padding(.bottom, paddingSectionSeparation)
        RecommendedArtistScrollView()
          .padding(.bottom, paddingSectionSeparation)
        BigSongCoversScrollView()
          .padding(.bottom, paddingBottomSection)
      }.padding(.vertical, lateralPadding)
    }
  }
}

struct RadialGradientBackground: View {
  let backgroundGradientColor = Color(red: 0.051, green: 0.608, blue: 0.784)

  var body: some View {
    RadialGradient(gradient: Gradient(colors: [backgroundGradientColor.opacity(0.35), backgroundGradientColor.opacity(0.0)]),
                   center: .topLeading,
                   startRadius: 10,
                   endRadius: 600)
      .ignoresSafeArea()
  }
}

struct SmallSongCardsGrid: View {
  var body: some View {
    VStack(spacing: spacingSmallItems) {
      HStack {
        Text("Good Evening")
          .spotifyTitle(withPadding: true)
        Image("settings")
          .resizeToFit()
          .padding(5)
      }.frame(height: 30)
      VStack(spacing: spacingSmallItems) {
        HStack(spacing: spacingSmallItems) {
          SmallSongCard(image: Image("shape-of-you-cover"),
                        title: "Shape of You")
          SmallSongCard(image: Image("prayer-in-c-cover"),
                        title: "Prayer in C")
        }
        HStack(spacing: spacingSmallItems) {
          SmallSongCard(image: Image("la-casa-de-papel-cover"),
                        title: "La Casa de Papel Soundtrack")
          SmallSongCard(image: Image("this-is-logic-cover"),
                        title: "This is Logic")
        }
        HStack(spacing: spacingSmallItems) {
          SmallSongCard(image: Image("your-mix-1-cover"),
                        title: "Your Mix 1")
          SmallSongCard(image: Image("bohemian-rhapsody-cover"),
                        title: "Bohemian Rhapsody")
        }
      }
    }
  }
}

struct RecentlyPlayedScrollView: View {
  var body: some View {
    VStack(spacing: spacingSmallItems) {
      Text("Recently Played")
        .spotifyTitle(withPadding: true)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: spacingBigItems) {
          Spacer(minLength: 5)
          SmallSongItem(coverImage: Image("hip-hop-controller-cover"),
                        title: "Hip Hop Controller")
          SmallSongItem(coverImage: Image("iu-cover"),
                        title: "IU",
                        isArtistProfile: true)
          SmallSongItem(coverImage: Image("liked-songs-cover"),
                        title: "Liked Songs")
          SmallSongItem(coverImage: Image("late-night-lofi-cover"),
                        title: "Late Night Lofi")
          SmallSongItem(coverImage: Image("we-love-you-tecca-cover"),
                        title: "We Love You Tecca")
          SmallSongItem(coverImage: Image("avicii-cover"),
                        title: "AVICII",
                        isArtistProfile: true)
          SmallSongItem(coverImage: Image("sweetener-cover"),
                        title: "Sweetener")
          SmallSongItem(coverImage: Image("viral-hits-cover"),
                        title: "Viral Hits")
        }
      }
    }
  }
}

struct TopPodcastsScrollView: View {
  var body: some View {
    VStack(spacing: spacingSmallItems) {
      Text("Top Podcasts")
        .spotifyTitle(withPadding: true)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top,spacing: spacingBigItems) {
          Spacer(minLength: 5)
          BigSongItem(coverImage: Image("joe-rogan-cover"),
                        title: "Joe Rogan Experience",
                        artist: "Joe Rogan",
                        isPodcast: true)
          BigSongItem(coverImage: Image("the-daily-cover"),
                        title: "The Daily",
                        artist: "The New York Times",
                        isPodcast: true)
          BigSongItem(coverImage: Image("dateline-cover"),
                        title: "Dateline",
                        artist: "NBC News",
                        isPodcast: true)
          BigSongItem(coverImage: Image("distractable-cover"),
                        title: "Distractable",
                        artist: "Wood Elf",
                        isPodcast: true)
          BigSongItem(coverImage: Image("ted-talks-daily-cover"),
                        title: "Ted Talks Daily",
                        artist: "TED",
                        isPodcast: true)
          BigSongItem(coverImage: Image("smartless-cover"),
                        title: "Smartless",
                        artist: "Jason Bateman, Sean Hayes, Will Arnett",
                        isPodcast: true)
          BigSongItem(coverImage: Image("lex-fridman-cover"),
                        title: "Lex Fridman Podcast",
                        artist: "Lex Fridman",
                        isPodcast: true)
          BigSongItem(coverImage: Image("youre-wrong-cover"),
                        title: "You're Wrong About",
                        artist: "Michael Hobbes & Sarah Marshall",
                        isPodcast: true)
          BigSongItem(coverImage: Image("need-a-friend-cover"),
                        title: "Conan O'Brien Need a Friend",
                        artist: "Team Coco & Earwolf",
                        isPodcast: true)
        }
      }
    }
  }
}

struct RecommendedArtistScrollView: View {
  var body: some View {
    VStack(spacing: spacingSmallItems) {
      HStack(alignment: .top, spacing: spacingSmallItems) {
        Circle()
          .overlay(Image("david-guetta").resizeToFit())
          .aspectRatio(contentMode: .fit)
          .mask(Circle())
          .padding(3)
        VStack(alignment: .center) {
          Spacer()
          Text("FOR THE FANS OF").font(.avenir(.book, size: 14))
            .opacity(0.7)
            .frame(maxWidth: .infinity, alignment: .leading)
          Text("David Guetta")
            .spotifyTitle()
        }.frame(maxWidth: .infinity, alignment: .topLeading)
      }
      .frame(height: 60)
      .aspectRatio(contentMode: .fit)
      .padding(.leading, lateralPadding)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top,spacing: spacingBigItems) {
          Spacer(minLength: 5)
          BigSongItem(coverImage: Image("nothing-but-the-beat-cover"),
                        title: "Nothing But The Beat")
          BigSongItem(coverImage: Image("bed-cover"),
                        title: "BED")
          BigSongItem(coverImage: Image("this-is-david-guetta-cover"),
                        title: "This is David Guetta")
          BigSongItem(coverImage: Image("hero-cover"),
                        title: "Hero")
          BigSongItem(coverImage: Image("memories-cover"),
                        title: "Memories")
          BigSongItem(coverImage: Image("heartbreak-anthem-cover"),
                        title: "Heartbreak Anthem")
          BigSongItem(coverImage: Image("titanium-cover"),
                        title: "Titanium")
        }
      }
    }
  }
}

struct BigSongCoversScrollView: View {
  var body: some View {
    VStack(spacing: spacingSmallItems) {
      Text("Rock Classics")
        .spotifyTitle(withPadding: true)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top,spacing: spacingBigItems) {
          Spacer(minLength: 5)
          BigSongItem(coverImage: Image("bohemian-rhapsody-cover"),
                        title: "Bohemian Rhapsody",
                        artist: "Queen")
          BigSongItem(coverImage: Image("back-in-black-cover"),
                        title: "Back in Black",
                        artist: "AC/DC")
          BigSongItem(coverImage: Image("born-in-the-usa-cover"),
                        title: "Born in The USA",
                        artist: "Bruce Springsteen")
          BigSongItem(coverImage: Image("fortunate-son-cover"),
                        title: "Fortunate Son",
                        artist: "Creedence Clearwater Revival")
          BigSongItem(coverImage: Image("hotel-california-cover"),
                        title: "Hotel California",
                        artist: "Eagles")
          BigSongItem(coverImage: Image("sweet-home-alabama-cover"),
                        title: "Sweet Home Alabama",
                        artist: "Lynyrd Skynyrd")
          BigSongItem(coverImage: Image("come-as-you-are-cover"),
                        title: "Comer as You Are",
                        artist: "Nirvana")
          BigSongItem(coverImage: Image("final-countdown-cover"),
                        title: "Final Countdown",
                        artist: "Europe")
          BigSongItem(coverImage: Image("november-rain-cover"),
                      title: "November Rain",
                      artist: "Guns N' Roses")
        }
      }
    }
  }
}



// MARK: - Constants

var lateralPadding: CGFloat = 25
var titleFontSize: CGFloat = 26
var paddingBottomSection: CGFloat = 135

fileprivate var spacingSmallItems: CGFloat = 12
fileprivate var spacingBigItems: CGFloat = 20
fileprivate var paddingSectionSeparation: CGFloat = 50

