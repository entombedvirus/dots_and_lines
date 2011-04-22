AbstractGame = require './abstract_game'

module.exports = class ServerGame extends AbstractGame
	constructor: (options) ->
		@id = options.id
		@size = options.size
		@clients = options.clients
		@resetBoard()

	emit: (eventName, data...) ->
		@clients.now.handleServerEvent eventName, data

	handleClientEvent: (client, eventName, data) ->
		switch eventName
			when 'fillEdge'
				edgeNum = data[0]
				@fillEdge edgeNum

	fillEdge: (edgeNum) ->
		error = super
		return false if error is false

		@emit 'fillEdge', edgeNum
		true
	
	checkSquare: (direction, edgeNum) ->
		squareCompleted = super
		return false if squareCompleted is false

		# if execution has gotten this far, all the neighbors are set
		@emit 'completeSquare'
		true
	
	forClient: ->
		size: @size
		alpha: @alpha
		board: @board
