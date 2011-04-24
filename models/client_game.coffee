BaseGame = require './base_game'
StateMachine = require './state_machine'
UI = require('./ui').getInstance()

module.exports = class ClientGame extends BaseGame
	constructor: (options)->
		@container = options.container
		@gameUrl = window.location.href
		this[attr] = options[attr] for attr in ['size', 'alpha', 'num_edges', 'board', 'totalMoves']

		@setupPlayerStateMachine options.players
		@attachListeners()

	setupPlayerStateMachine: (serverStateMachine) ->
		@players = $.extend new StateMachine, serverStateMachine
		@players.on 'stateAdded', @refreshPlayerUI
		@players.on 'stateRemoved', @refreshPlayerUI
		@players.on 'stateChanged', @refreshPlayerUI
	
	refreshPlayerUI: =>
		$(document).ready =>
			players = @container.find('.players').empty()
			for state, idx in @players.states
				txt = if state == window.clientId
					"You"
				else
					"Player #{idx + 1}"
				li = $("<li/>").text txt

				li.addClass 'currentTurn' if @players.getCurrentState() == state
				players.append li
			null

	attachListeners: ->
		@container.click (e) =>
			target = $(e.target)
			return unless target.is 'a'
			
			gameId = @container.attr 'id'
			edgeNum = target.data 'edgeNum'
			@emit 'fillEdge', edgeNum

			return false
	
	emit: (eventName, data...) ->
		window.now.handleClientEvent eventName, data

	handleServerEvent: (eventName, data) ->
		console.log "server said", eventName, data
		switch eventName
			when 'needMorePlayers'
				UI.showMessage '''
					You're the only one connected
					to this game right now. Invite someone to play
					with you by sending them a link to this page.
				'''
			when 'notYourTurn'
				UI.showMessage '''
					It's not your turn...
				'''
			when 'playerJoined'
				clientId = data[0]
				@addPlayer clientId

			when 'playerLeft'
				clientId = data[0]
				@removePlayer clientId

			when 'fillEdge'
				edgeNum = data[0];
				@fillEdge edgeNum

	fillEdge: (edgeNum) ->
		super
		edges = @container.find('a');
		$(edges.get(edgeNum)).addClass 'filled'

	render: ->
		@renderBoard()
		@renderPlayerUI()
		
	renderBoard: ->
		board = $("<div class='board'></div>")

		for edge, edgeNum in @board
			link = $("<a></a>").html '&nbsp'
			currentOrientation = @isVerticalEdge edgeNum
			switching =  currentOrientation != @isVerticalEdge(edgeNum - 1)
			if currentOrientation
				link.addClass 'vert'
			else
				link.addClass 'horiz'
			link.css 'clear', 'left' if switching
			link.addClass 'filled' if @board[edgeNum]
			board.append link
			link.data 'edgeNum', edgeNum

		board.appendTo @container

	renderPlayerUI: ->
		list = $("<ol class='players'></ol>")
		list.appendTo @container

