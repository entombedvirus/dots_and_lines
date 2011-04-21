Client ?= {}

class Client.Game
	constructor: (@container)->
		@container.click (e) =>
			target = $(e.target)
			return unless target.is 'a'
			
			gameId = @container.attr 'id'
			target.attr "href", "/g/#{gameId}/set/#{target.data('edgeNum')}"
			return true

		console.log "Client game construction detected"
	
	render: ->
		console.log "render triggered on client game"
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
