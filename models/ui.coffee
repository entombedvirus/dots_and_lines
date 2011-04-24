class UI
	constructor: ->
		$(document).ready =>
			@container = $("<div id='notifications'><p></p></div>")
			@container.prependTo $('body')
			@container.click @hideMessage

	showMessage: (msg) ->
		@container.find('p:first').text msg
		@container.fadeIn('fast')
		@restartHideTimer()
	
	hideMessage: =>
			@container.fadeOut 'slow'
	
	restartHideTimer: ->
		clearTimeout @timer if @timer?
		@timer = setTimeout @hideMessage, 3000


instance = null
module.exports =
	getInstance: ->
		instance ||= new UI

