
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
		self[to].implode if self[to]
		self[from].move_to(to)
		if (to[0] - from[0]).abs > 1
			delta = [(to[0] - from[0])/2, (to[1] - from[1])/2]
			##someone was under that move
			imploded_pos = [from[0] + delta[0], from[1] + delta[1]]
			self[imploded_pos].implode
			self[to].moves
			return true if self[to].jump_move?
		end
		false
	end

	def in_bounds?(move_coords)
		(0..7).include?(move_coords[0]) && (0..7).include?(move_coords[1])
	end
end