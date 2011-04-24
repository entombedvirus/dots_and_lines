{EventEmitter} = require 'events'

module.exports = class StateMachine extends EventEmitter
	constructor: ->
		@states = new Array
		@counter = 0
	
	addState: (newState) ->
		@states.push newState
		@emit 'stateAdded', newState
		this
	
	removeState: (aState) ->
		@states = @states.filter (currentState) ->
			currentState != aState
		@emit 'stateRemoved', aState
		this

	nextState: ->
		@counter++
		@emit 'stateChanged'
		this

	getCurrentState: ->
		idx = @counter % @states.length
		@states[idx]
	
