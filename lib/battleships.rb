require 'sinatra/base'
require_relative 'game'
require_relative 'player'
require_relative 'ship'
require_relative 'board'
require_relative 'cell'

class BattleShips < Sinatra::Base

  enable :sessions

  set :views, File.expand_path('../../views', __FILE__)

  game = Game.new

  # routes 

  get '/' do
    erb :index
  end

  get '/new_game' do 
    erb :new_game
  end

  # we are giving each player a name and setting it in session (cookies)

  post '/form' do # rename to register
    name = params[:player]
    if name.nil? || name.empty?
      redirect '/new_game'
    else
      @player = Player.new
      @player.name = name
      session[:me] = name
      session[:player_id] = @player.object_id
      game.add_player(@player)
      redirect '/setup_game'
    end
    erb :new_game
  end

  post '/set_ships' do 
    player = ObjectSpace._id2ref(session[:player_id])
    player.board.place(Ship.battleship, params[:coord].to_sym, params[:orientation].to_sym) 
    if game.player2
      redirect "/start"
    else
      redirect "/waiting" 
    end
  end

  get '/waiting' do 
    if game.player2 && game.both_players_have_ships?
      redirect '/start' 
    else
      erb :waiting
    end
  end


  get '/setup_game' do # rename to play game
    session[:board] = (Board.new(Cell)).object_id
    session[:fleet] = [Ship.battleship].object_id
    player = ObjectSpace._id2ref(session[:player_id])
    player.board = ObjectSpace._id2ref(session[:board])
    erb :setup_game 
  end

  get "/start" do 
    if game.ready?
      puts "ready"
    end
    erb :start
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
  
end
