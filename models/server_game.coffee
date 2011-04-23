AbstractGame = require './abstract_game'

module.exports = class ServerGame extends AbstractGame
	constructor: (options) ->
		@id = options.id
		@size = options.size
		@clients = options.clients
		@connectedPlayers = {}
		@attachListeners()
		@resetBoard()

	attachListeners: ->
		@clients.on 'connect', @onPlayerConnected
		@clients.on 'disconnect', @onPlayerDisconnected

	onPlayerConnected: (clientId) =>
		@connectedPlayers[clientId] = true
	
	onPlayerDisconnected: (clientId) =>
		delete @connectedPlayers[clientId]

	emit: (eventName, data...) ->
		@clients.now.handleServerEvent eventName, data

	handleClientEvent: (client, eventName, data) ->
		switch eventName
			when 'fillEdge'
				# don't let the player have infinte moves if they are the
				# only one connected
				if Object.keys(@connectedPlayers).length < 2
					client.now.handleServerEvent 'needMorePlayers'
					return false

				if @isCurrentClientsTurn client
					edgeNum = data[0]
					@fillEdge edgeNum
				else
					client.now.handleServerEvent 'notYourTurn'

	isCurrentClientsTurn: (client) ->
		players = Object.keys @connectedPlayers
		currentPlayerIdx = @totalMoves % players.length
		currentPlayerClientId = players[currentPlayerIdx]
		client.user.clientId == currentPlayerClientId

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
		totalMoves: @totalMoves
