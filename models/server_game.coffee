BaseGame = require './base_game'

module.exports = class ServerGame extends BaseGame
	constructor: (options) ->
		@id = options.id
		@size = options.size
		@clients = options.clients

		@attachListeners()
		@resetBoard()

	attachListeners: ->
		game = this
		@clients.on 'connect', ->
			client = this
			clientId = client.user.clientId

			client.now.getSession (session) ->
				return unless session?
				game.addPlayer clientId, session.uid
				game.emit 'playerJoined', clientId, session.uid

		@clients.on 'disconnect', ->
			game.removePlayer @now.uid
			game.emit 'playerLeft', @now.uid

	emit: (eventName, data...) ->
		@clients.now.handleServerEvent eventName, data

	handleClientEvent: (client, eventName, data) ->
		switch eventName
			when 'fillEdge'
				# don't let the player have infinte moves if they are the
				# only one connected
				if @players.states.length < 2
					client.now.handleServerEvent 'needMorePlayers'
					return false

				if @players.getCurrentState() == client.now.uid
					edgeNum = data[0]
					@fillEdge edgeNum
				else
					client.now.handleServerEvent 'notYourTurn'

	fillEdge: (edgeNum) ->
		@emit 'fillEdge', edgeNum
		super
	
	checkSquare: (direction, edgeNum) ->
		squareCompleted = super
		return false if squareCompleted is false

		# if execution has gotten this far, all the neighbors are set
		@emit 'completeSquare'
		true
	
	forClient: ->
		size: @size
		alpha: @alpha
		num_edges: @num_edges
		board: @board
		players: @players
		scoreCard: @scoreCard
		totalMoves: @totalMoves
