
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
		prompt ||= "#{@name}, it is your turn"
		puts prompt
		puts "please input a start square and end square to move your piece"
		moves = get_move # "01, 02"
		if @game.board[moves[0]].moves.include?(moves[1])
			return moves
		else
			self.take_turn("invalid move! please try again")  ## recursive input validation :)
		end
	end

	def get_move(input = nil)
		input ||= gets.chomp
		moves = (input.split(',').each(&:strip!).map { |coord_str| coord_str.split(//)})
		moves.map { |coord_array| coord_array.map(&:to_i) }
	end

	def make_team
		i_start = @color == :red ? 0 : 5
		@pieces = []
		i_start.upto(i_start+2) do |i|
			j_start = i.even? ? 0 : 1
			4.times do |count|
				j = 2*count + j_start
				@pieces << Piece.new(@color, [i,j], @game.board)
			end
		end
	end
end