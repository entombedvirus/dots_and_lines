BaseGame = require './base_game'
StateMachine = require './state_machine'
UI = require('./ui').getInstance()

module.exports = class ClientGame extends BaseGame
	constructor: (options)->
		@container = options.container
		@gameUrl = window.location.href
		this[attr] = options[attr] for attr in ['size', 'alpha', 'num_edges', 'board', 'totalMoves', 'scoreCard', 'clientId', 'completedSquares']

		@setupPlayerStateMachine options.players

	setupPlayerStateMachine: (serverStateMachine) ->
		@players = $.extend new StateMachine, serverStateMachine
		@players.on 'stateAdded', @refreshPlayerUI
		@players.on 'stateRemoved', @refreshPlayerUI
		@players.on 'stateChanged', @refreshPlayerUI
	
	refreshPlayerUI: =>
		$(document).ready =>
			players = @container.find('.players').empty()
			for uid, score of @scoreCard
				txt = "<fb:profile-pic uid='#{uid}'></fb:profile-pic>"
				txt += "<span>#{score}</span>"
				li = $("<li/>").html txt

				li.addClass('offline').attr('title', 'offline') unless uid in @players.states
				li.addClass('currentTurn').attr('title', 'Current Turn') if @players.getCurrentState() == uid
				players.append li

			FB.XFBML.parse(@container.get(0))
	
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
				uid = data[1]
				@addPlayer clientId, uid

			when 'playerLeft'
				uid = data[0]
				@removePlayer uid

			when 'fillEdge'
				edgeNum = data[0];
				@fillEdge edgeNum

			when 'completeSquare'
				@refreshPlayerUI()

			when 'gtfo'
				msg = data[0]
				UI.showMessage "Server kicked you. Reason: #{msg}", true
				window.socket?.disconnect()

	render: ->
		$.get "/game.pde", (res) =>
			jsCode = Processing.compile res
			new Processing @container.find("canvas").get(0), jsCode

		@renderPlayerUI()
		
	renderPlayerUI: ->
		list = $("<ul class='players'></ul>")
		list.appendTo @container

