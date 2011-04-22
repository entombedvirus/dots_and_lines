AbstractGame = require './abstract_game'

module.exports = class ClientGame extends AbstractGame
	constructor: (options)->
		@container = options.container
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
		switch eventName
			when 'fillEdge'
				edgeNum = data[0];
				edges = @container.find('a');
				$(edges.get(edgeNum)).addClass 'filled'
				true

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

