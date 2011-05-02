BaseGame = require './base_game'
StateMachine = require './state_machine'
UI = require('./ui').getInstance()

module.exports = class ClientGame extends BaseGame
	constructor: (options)->
		@container = options.container
		@gameUrl = window.location.href
		this[attr] = options[attr] for attr in ['size', 'alpha', 'num_edges', 'board', 'totalMoves', 'scoreCard']

		@setupPlayerStateMachine options.players

	setupPlayerStateMachine: (serverStateMachine) ->
		@players = $.extend new StateMachine, serverStateMachine
		@players.on 'stateAdded', @refreshPlayerUI
		@players.on 'stateRemoved', @refreshPlayerUI
		@players.on 'stateChanged', @refreshPlayerUI
	
	refreshPlayerUI: =>
		$(document).ready =>
			players = @container.find('.players').empty()
			for clientId, score of @scoreCard
				txt = if clientId == window.clientId
					"You"
				else
					"Player #{clientId}"

				li = $("<li/>").text txt + ": " + score
				li.addClass('offline') unless clientId in @players.states
				li.addClass 'currentTurn' if @players.getCurrentState() == clientId
				players.append li
			null

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

			when 'completeSquare'
				@refreshPlayerUI()

	render: ->
		$.get "/game.pde", (res) =>
			jsCode = Processing.compile res
			new Processing @container.find("canvas").get(0), jsCode

		@renderPlayerUI()
		
	renderPlayerUI: ->
		list = $("<ol class='players'></ol>")
		list.appendTo @container

