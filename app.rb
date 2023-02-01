# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

    get "/albums" do
      repo = AlbumRepository.new
      # changed albums into an instance variable
      @albums = repo.all 

      # response = albums.map do |album|
      #   album.title
      # end.join(', ')

      return erb(:albums)
    end

    #defined before so it doesn;t get picked up by /:id
    get "/albums/new" do
      return erb(:new_album)
    end

    get "/albums/:id" do
      repo = AlbumRepository.new
      artist_repo = ArtistRepository.new

      @album = repo.find(params[:id])
      @artist = artist_repo.find(@album.artist_id)

      return erb(:album)
    end

    post "/albums" do
      if invalid_album_params?
        status 400
      end

      title = params[:title]
      release_year = params[:release_year]
      artist_id = params[:artist_id]

      repo = AlbumRepository.new
      new_album = Album.new

      new_album.title = title
      new_album.release_year = release_year
      new_album.artist_id = artist_id

      repo.create(new_album)

      return erb(:album_created)
    end

    get "/artists" do
      repo = ArtistRepository.new
      @artists = repo.all 

      # response = artists.map do |artist|
      #   artist.name
      # end.join(', ')
      return erb(:artists)
    end

    get "/artists/new" do
      return erb(:new_artist)
    end

    get "/artists/:id" do
      repo = ArtistRepository.new

      @artist = repo.find(params[:id])

      return erb(:artist)
    end

    post "/artists" do
      if invalid_artist_params?
        status 400
      end

      repo = ArtistRepository.new
      new_artist = Artist.new
      new_artist.name = params[:name]
      new_artist.genre = params[:genre]

      repo.create(new_artist)



      return erb(:artist_created)
    end

    def invalid_album_params?
      return (params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil)
      # return true if params[:title] == "" || params[:relesea_year] == "" || params[:artist_id = ""] - empty check
    end

    def invalid_artist_params?
      return (params[:name] == nil || params[:genre] == nil)
      # return true if params[:name] == "" || params[:genre] == ""  - empty check
    end

end