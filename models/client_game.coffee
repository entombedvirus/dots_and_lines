BaseGame = require './base_game'
UI = require('./ui').getInstance()

module.exports = class ClientGame extends BaseGame
	constructor: (options)->
		@container = options.container
		@gameUrl = window.location.href
		@attachListeners()

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

			when 'fillEdge'
				edgeNum = data[0];
				@fillEdge edgeNum

	fillEdge: (edgeNum) ->
		super
		edges = @container.find('a');
		$(edges.get(edgeNum)).addClass 'filled'

	render: ->
		for edge, edgeNum in @board
			link = $("<a></a>").html '&nbsp'
			currentOrientation = @isVerticalEdge edgeNum
			switching =  currentOrientation != @isVerticalEdge(edgeNum - 1)
			if currentOrientation
				link.addClass 'vert'
			else
				link.addClass 'horiz'
			@container.append link
			link.css 'clear', 'left' if switching
			link.addClass 'filled' if @board[edgeNum]
			link.data 'edgeNum', edgeNum
