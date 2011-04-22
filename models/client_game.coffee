AbstractGame = require './abstract_game'

module.exports = class ClientGame extends AbstractGame
	constructor: (@container)->
		@container.click (e) =>
			target = $(e.target)
			return unless target.is 'a'
			
			gameId = @container.attr 'id'
			target.attr "href", "/g/#{gameId}/set/#{target.data('edgeNum')}"
			$.getJSON target.attr('href')
			return false

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

