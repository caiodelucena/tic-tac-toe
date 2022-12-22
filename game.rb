module TypeOfGame
  PLAYER_VS_COMPUTER_GAME = 0
  PLAYER_VS_PLAYER_GAME = 1
  COMPUTER_VS_COMPUTER = 2

  def player_vs_player?
    @type_of_game == PLAYER_VS_PLAYER_GAME
  end

  def player_vs_computer?
    @type_of_game == PLAYER_VS_COMPUTER_GAME
  end

  def computer_vs_computer?
    @type_of_game == COMPUTER_VS_COMPUTER
  end

  def type_of_game_is_valid?
    player_vs_player? || player_vs_computer? || computer_vs_computer?
  end
end

module Player
  ONE = 0
  TWO = 1

  def current_player
    @turn.even? ? 'X' : 'O'
  end

  def current_computer
    @turn.even? ? 'X' : 'O'
  end

  def computer_mark
    computer_vs_computer? ? current_computer : @com
  end
end

module Level
  EASY = 0
  HARD = 1

  def easy_level?
    @level == EASY
  end

  def hard_level?
    @level == HARD
  end

  def level_valid?
    easy_level? || hard_level?
  end
end

class Game
  include Player
  include TypeOfGame
  include Level

  def initialize
    @board = %w[0 1 2 3 4 5 6 7 8]
    @com = 'O'
    @hum = 'X'
    @type_of_game = nil
    @level = nil
    @turn = ONE
  end

  def start_game
    choose_game

    display_board
    puts 'Enter [0-8]'

    until game_is_over(@board) || tie(@board)
      get_human_spot unless computer_vs_computer?

      eval_board if !game_is_over(@board) && !tie(@board) && !player_vs_player?

      increment_turn

      display_board
    end

    puts tie(@board) ? "It's a tie!" : 'Game over'
  end

  def get_human_spot
    spot = nil
    until spot
      turn_print
      spot = gets.chomp.to_i
      if valid_move?(spot)
        @board[spot] = player_vs_player? ? current_player : @hum
      else
        spot = nil
        puts 'Invalid move. Try again: '
      end
    end
  end

  def eval_board
    spot = nil
    until spot
      if @board[4] == '4'
        spot = 4
        @board[spot] = computer_mark
      else
        spot = get_move(@board, computer_mark)
        if @board[spot] != 'X' && @board[spot] != 'O'
          @board[spot] = computer_mark
        else
          spot = nil
        end
      end
    end
  end

  private

  def get_move(board, next_player)
    available_spaces = []
    best_move = nil
    board.each do |space|
      available_spaces << space if space != 'X' && space != 'O'
    end
    random_value = rand(0..available_spaces.count)

    unless easy_level? || computer_vs_computer?
      available_spaces.each do |as|
        board[as.to_i] = @com
        if game_is_over(board)
          best_move = as.to_i
          board[as.to_i] = as
          return best_move
        else
          board[as.to_i] = @hum
          if game_is_over(board)
            best_move = as.to_i
            board[as.to_i] = as
            return best_move
          else
            board[as.to_i] = as
          end
        end
      end
    end

    best_move || available_spaces[random_value].to_i
  end

  def game_is_over(b)
    [b[0], b[1], b[2]].uniq.length == 1 ||
    [b[3], b[4], b[5]].uniq.length == 1 ||
    [b[6], b[7], b[8]].uniq.length == 1 ||
    [b[0], b[3], b[6]].uniq.length == 1 ||
    [b[1], b[4], b[7]].uniq.length == 1 ||
    [b[2], b[5], b[8]].uniq.length == 1 ||
    [b[0], b[4], b[8]].uniq.length == 1 ||
    [b[2], b[4], b[6]].uniq.length == 1
  end

  def tie(b)
    b.all? { |s| s == 'X' || s == 'O' }
  end

  def choose_game
    puts "Enter type of game: \n0 -> Player vs Computer \n1 -> Player vs Player\n2 -> Computer vs Computer"
    @type_of_game = gets.chomp.to_i

    unless type_of_game_is_valid?
      puts 'Invalid game. Try again: '

      return choose_game
    end

    choose_level if player_vs_computer?
  end

  def choose_level
    puts "Enter level: \n0 -> Easy \n1 -> Hard\n"
    @level = gets.chomp.to_i

    unless level_valid?
      puts 'Invalid level. Try again: '

      choose_level
    end
  end

  def display_board
    puts "\n \n #{@board[0]} | #{@board[1]} | #{@board[2]} \n===+===+===\n #{@board[3]} | #{@board[4]} | #{@board[5]} \n===+===+===\n #{@board[6]} | #{@board[7]} | #{@board[8]} \n \n \n"
  end

  def increment_turn
    @turn += 1
  end

  def turn_print
    puts @turn.even? ? "First player's turn: " : "Second player's turn: " if player_vs_player?
  end

  def valid_move?(spot)
    @board.include?(spot.to_s) && @board[spot] != 'X' && @board[spot] != 'O'
  end
end

game = Game.new
game.start_game
