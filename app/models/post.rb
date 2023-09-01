class Post < ApplicationRecord
  belongs_to :user
  validate :valid_spotify_link
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :favourite_posts, dependent: :destroy
  before_save :spotify_call

  def self.feed_posts(user)
    friend_ids = user.friendships_as_follower.where(accepted: true).pluck(:followee_id)
    Post.where(user_id: friend_ids, post_date: Date.today)
  end

  def spotify_call
    link_id = self.link.split('/').last.split('?').first # this should be a method in the model post
    song = RSpotify::Track.find(link_id) # this can also be in model
    song_title = song.name
    song_artists = song.artists
    preview = song.preview_url
    artist = song_artists.map { |artist| artist.name }.join(', ')
    album_art = song.album.images.first["url"]
    self.song_name = song_title
    self.artist = artist
    self.genre = preview
    self.image_url = album_art
    self.post_date = Date.today
  end

  def valid_spotify_link
    logger.debug "Inside valid_spotify_link method" # Add this line
    # Use a regular expression to check if the link matches a Spotify track URL
    spotify_url_regex = %r{^(spotify:|https:\/\/[a-z]+\.spotify\.com\/)}

    unless link =~ spotify_url_regex
      errors.add(:link, "must be a valid Spotify track URL")
    end
  end
end
