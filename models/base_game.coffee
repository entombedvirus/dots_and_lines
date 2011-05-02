StateMachine = require './state_machine'

module.exports = class BaseGame
	resetBoard: ->
		@totalMoves = 0
		@alpha = 2 * @size - 1
		@num_edges = 2 * @size * (@size - 1)
		@board = new Array @num_edges
		@players = new StateMachine
		@scoreCard = {}

	addPlayer: (clientId, uid) ->
		if @scoreCard[uid]?
			@scoreCard[uid].clientId = clientId
		else
			@scoreCard[uid] = 
				clientId: clientId
				score: 0

		@players.addState uid
	
	removePlayer: (uid) ->
		@players.removeState uid
	
	isVerticalEdge: (edgeNum) ->
		(edgeNum % @alpha) >= Math.floor(@alpha / 2)

	isOnPerimeter: (direction, edgeNum) ->
		switch direction
			when 'left'
				edgeNum % @alpha == @size - 1
			when 'right'
				edgeNum % @alpha == @alpha - 1
			when 'top'
				edgeNum in [0...@size]
			when 'bottom'
				edgeNum in [(@num_edges - @size + 1)..@num_edges]

	fillEdge: (edgeNum) ->
		throw "Edge #{edgeNum} is out of bounds. total: #{@num_edges}" unless 0 <= edgeNum < @num_edges

		left = right = top = bottom = false
		@totalMoves++;
		@board[edgeNum] = true

		if @isVerticalEdge edgeNum
			left = @checkSquare 'left', edgeNum unless @isOnPerimeter 'left', edgeNum
			right = @checkSquare 'right', edgeNum unless @isOnPerimeter 'right', edgeNum
		else
			top = @checkSquare 'top', edgeNum unless @isOnPerimeter 'top', edgeNum
			bottom = @checkSquare 'bottom', edgeNum unless @isOnPerimeter 'bottom', edgeNum

		uid = @players.getCurrentState()
		@scoreCard[uid].score += 1 for completed in [left, right, top, bottom] when completed is true

		pointScored = left or right or top or bottom
		@players.nextState() unless pointScored

		# return whether this move resulted in atleast one point
		pointScored

	checkSquare: (direction, edgeNum) ->
		coordinates = switch direction
			when 'left'
				[edgeNum - 1, edgeNum - @size, edgeNum + (@size - 1)]
			when 'right'
				[edgeNum + 1, edgeNum + @size, edgeNum - (@size - 1)]
			when 'top'
				[edgeNum - @alpha, edgeNum - @size, edgeNum - (@size - 1)]
			when 'bottom'
				[edgeNum + @alpha, edgeNum + @size, edgeNum + (@size - 1)]

		for edge in coordinates
			# don't need to check out-of-bounds coordinates
			continue unless 0 <= edge < @num_edges
			
			# if one of the neighbor lines are not set, return false
			return false unless @board[edge]

		# if execution has gotten this far, all the neighbors are set
		true
