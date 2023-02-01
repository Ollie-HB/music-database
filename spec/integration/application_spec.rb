require "spec_helper"
require "rack/test"
require_relative '../../app'

# These tests are against our test database, hence the differing contents of the tables (creation, deletion etc)
# Do i need to add a table re-setter? I added them in

def reset_artists_table
  seed_sql = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods
  before(:each) do 
    reset_artists_table
    reset_albums_table
  end

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }



  context "GET /albums" do
    it "returns list of albums with 200 OK" do

      response = get("/albums")

      # expected_album_list = 
      # "Doolittle, Surfer Rosa, Waterloo, Super Trouper, Bossanova, Lover, Folklore, " + 
      # "I Put a Spell on You, Baltimore, Here Comes the Sun, Fodder on My Wings, Ring Ring"
      # not perfect but better than one line

      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/albums/1">Doolittle</a><br />')
      expect(response.body).to include('<a href="/albums/12">Ring Ring</a><br />')
    end
  end

  context "GET to albums/:id" do
    it "returns individual album info on web page for album 1" do
        response = get("/albums/1")

        expect(response.status).to eq(200)
        expect(response.body).to include('<h1>Doolittle</h1>')
        expect(response.body).to include('Release year: 1989')
        expect(response.body).to include('Artist: Pixies')  
    end

    it "returns individual album info on web page for album 2" do
      response = get("/albums/2")

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Surfer Rosa</h1>')
      expect(response.body).to include('Release year: 1988')
      expect(response.body).to include('Artist: Pixies')  
    end
  end

  context "GET /albums/new" do
    it "returns the form page for adding an album" do
      response = get('/albums/new')

      expect(response.status).to eq(200)
      expect(response.body).to include('<form action="/albums" method="POST">')
      expect(response.body).to include('<input type="text" name="title" />')
      expect(response.body).to include('<input type="text" name="release_year" />')
      expect(response.body).to include('<input type="text" name="artist_id" />')
    end
  end

  context "POST /albums" do
    it 'should validate album parameters, responding 400 if invalid' do
      response = post(
      '/albums',
      invalid_album_title: 'Blah blah',
      another_invalid_param: 157
      )
      # 400 is used when the client sends something incorrect or unexpected to the server
      expect(response.status).to eq(400)
    end

    it 'returns a success page when an album is successfully added' do
      response = post('/albums',
      title: 'Illmatic',
      release_year: 1994,
      artist_id: 8
      )
      expect(response.status).to eq(200)
      expect(response.body).to include('<p>Album added successfully.</p>')
      expect(response.body).to include('<a href="/albums">Go to album page</a>')
    end

    it "creates new album that displays in list, returns 200 OK" do

      response = post("/albums", title: "Voyage", release_year: "2022", artist_id: "2")

      expect(response.status).to eq(200)

      albums_list = get("albums")

      expect(albums_list.body).to include("Voyage")
    end
  end

  context "GET /artists" do
    it "returns list of artists with 200 OK" do

      response = get("/artists")

      # expected_artist_list = 
      # "Pixies, ABBA, Taylor Swift, Nina Simone"

      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/artists/1">Pixies</a><br />')
      expect(response.body).to include('<a href="/artists/4">Nina Simone</a><br />')
    end
  end

  context "GET /artists/new" do
    it "returns the form page for adding an artist" do
      response = get('/artists/new')

      expect(response.status).to eq(200)
      expect(response.body).to include('<form action="/artists" method="POST">')
      expect(response.body).to include('<input type="text" name="name" />')
      expect(response.body).to include('<input type="text" name="genre" />')
    end
  end

  context "GET to artists/:id" do
    it "returns individual artist info on web page for artist 1" do
        response = get("/artists/1")

        expect(response.status).to eq(200)
        expect(response.body).to include('<h1>Name: Pixies</h1>')
        expect(response.body).to include('Genre: Rock') 
    end

    it "returns individual artist info on web page for artist 4" do
      response = get("/artists/4")

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Name: Nina Simone</h1>')
      expect(response.body).to include('Genre: Pop')
    end
  end

  context "POST /artists" do
    it 'should validate artist parameters' do
      response = post(
      '/artists',
      invalid_artist_name: 'Blah blah',
      another_invalid_param: 157
      )
      # 400 is used when the client sends something incorrect or unexpected to the server
      expect(response.status).to eq(400)
    end

    it 'returns a success page when an artist is successfully added' do
      response = post('/artists',
      name: 'Biggie',
      genre: 'Hip-Hop'
      )
      expect(response.status).to eq(200)
      expect(response.body).to include('<p>Artist added successfully.</p>')
      expect(response.body).to include('<a href="/artists">Go to artist page</a>')
    end

    it "creates new artist that displays in artists list, plus returns 200 OK" do

      response = post("/artists", name: "Wild nothing", genre: "Indie")

      expect(response.status).to eq(200)

      artists_list = get("artists")

      expect(artists_list.body).to include("Wild nothing")
    end
  end
end
