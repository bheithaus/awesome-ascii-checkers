require 'colorize'
require 'debugger'
# class Square
# 	attr_accessor :piece
# 	attr_reader :color

# 	def initialize(color, piece = nil)
# 		@color = color
# 		@piece = piece
# 	end

# 	def render
# 		"   ".colorize(:background => color)
# 	end  #   color = :black || :white


# end

class Board
	attr_reader :matrix

	def initialize(player1, player2)
		@matrix = Array.new(8) { [nil]*8 }
		@players = [player1, player2]
	end

	def [](coordinate)
		i, j = coordinate
		@matrix[i][j]
	end

	def []=(coordinate, set_to)
		i, j = coordinate
		@matrix[i][j] = set_to
	end

	def place_pieces
		@players.each do |player|
			player.pieces.each do |piece|
				self[piece.position] = piece
			end
		end
	end

	def render(coords)
		i, j = coords
		if i.even?
			color = j.odd? ? :black : :white
		else
			color = j.odd? ? :white : :black
		end
		if self[coords] == nil
			"  ".colorize(:background => color)
		else
			self[coords].render.colorize(:background => color)
		end
	end

	def make_move(move_coords)
		from, to = move_coords
		moving_piece = self[from]
		moving_piece.moves.each {|m| print m}

		self[to].implode if self[to]
		self[from].move_to(to)
		if (to[0] - from[0]).abs > 1
			delta = [(to[0] - from[0])/2, (to[1] - from[1])/2]
			##someone was under you
			debugger
			imploded_pos = [from[0] + delta[0], from[1] + delta[1]]
			self[imploded_pos].implode
			return true
		end
		false
	end

	def valid_move?(move_coords)  ##lolzzzz
		true
	end

	def in_bounds?(move_coords)
		(0..7).include?(move_coords[0]) && (0..7).include?(move_coords[1])
	end
end

class Game
	attr_reader :board

	def initialize
		@players = [HumanPlayer.create(:black, 1, self), HumanPlayer.create(:red, 2, self)]
		@board = Board.new(@players[0], @players[1])
		@players.each { |player| player.make_team } 
		@board.place_pieces ##?? is there a better way to deal with mutually dependent class creation
		play									### probably to avoid it...		
	end

	def play
		until won?
			one_turn
		end

	end

	def won?
		##stub
		false
	end

	def one_turn
		puts "Welcome to Checkers"
		puts "___________________"
		@players.each do |player|
			next if still_my_turn
			show_board
			still_my_turn = @board.make_move(player.take_turn)
		end
	end

	def show_board
		puts
		@board.matrix.each_with_index do |row, i|
			row.each_with_index do |square, j|
				print @board.render( [i, j] )
			end
			puts
		end
	end
end

class HumanPlayer
	attr_reader :pieces

	def HumanPlayer.create(color, number, game)
		HumanPlayer.new(color, self.get_name(number), game)
	end

	def HumanPlayer.get_name(number)
		puts "Player #{number} what is your name?"
		gets.chomp
	end

	def initialize(color, name = "humanoid", game)
		@game = game
		@name = name
		@color = color ## :red || :black
	end

	def take_turn(prompt = nil)
		prompt ||= "#{@name}, it is your turn"  ##syntax??
		puts prompt
		puts "please input a start square and end square to move your piece"
		####  01, 02

		move = gets.chomp
		moves = (move.split(',').each(&:strip!).map { |coord_str| coord_str.split(//)})
		moves.map! { |coord_array| coord_array.map(&:to_i) }
		if @game.board.valid_move?(moves) && @game.board[moves[0]].moves.include?(moves[1])
			return moves
		else
			self.take_turn("invalid move! please try again")  ##recursive input validation :)
		end
	end

	def make_team
		i_start = @color == :red ? 0 : 5

		@pieces = []
		i_start.upto(i_start+2) do |i|
			j_start = i.even? ? 0 : 1  ###if i is even we
			4.times do |count|
				j = 2*count + j_start
				@pieces << Piece.new(@color, [i,j], @game.board)
			end
		end
	end
end

class Piece
	attr_reader :position, :color

	def initialize(color, position, board, king = false)
		@color = color
		@position = position
		@board = board
	end

	def implode
		@board[@position] = nil
		@position = nil
	end

	def move_to(coord)
		@board[coord] = self
		@board[@position] = nil
		@position = coord
	end

	def forward
		@color == :red ? 1 : -1
	end

	def moves
		#return king_moves if king 
		###@position ====== [2,4]
		f = forward
		deltas = [[f, 1], [f, -1]]
		deltas.select! { |delta| @board.in_bounds?([delta[0] + position[0], delta[1] + position[1]]) }
		moves = []
		deltas.each do |delta|
			moves += get_moves_for_delta(delta, @position, @color)
		end

		moves
	end

	def get_moves_for_delta(delta, position, my_color) ###what is going on here? i recursively call a method
		moves = []										##that lives inside this instance of class  
														##does the new frame include instance variables from the caller object??
		move_to = [@position[0] + delta[0], @position[1] + delta[1]]
		if @board[move_to] != nil && @board[move_to].color != my_color
			moves += get_moves_for_delta(delta.map { |i| 2*i }, position, my_color) ##enemy
		elsif @board[move_to] == nil
			moves << move_to## nothing is there
		end
		moves
	end

	def king_moves


	end

	def render
		piece = @color == :red ? "R " : "B "
		piece.colorize(@color)
	end
end

g = Game.new