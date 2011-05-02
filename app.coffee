express = require 'express'
nowjs   = require 'now'
fs      = require 'fs'

ServerGame = require './models/server_game'

app = module.exports = express.createServer()

DEFAULT_BOARD_SIZE = 6
DEFAULT_PORT = 3000

all_games = {}

createNewGame = (gameId) ->
	room = nowjs.getGroup gameId
	new ServerGame
		id: gameId
		size: DEFAULT_BOARD_SIZE
		clients: room


# Configuration
app.configure ->
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	# app.use express.logger()
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use app.router
	app.use express.static __dirname + '/public'
	app.use require('browserify')
		base : __dirname + '/models'
		mount : '/browserify.js'
	

app.get '/games', (req, res) ->
	res.local 'all_games', all_games
	res.render 'games/index'

app.get '/g/:game_id', (req, res) ->
	gid = req.params.game_id
	all_games[gid] ||= createNewGame gid
	res.local 'game_id', gid
	res.local 'game', all_games[gid]
	res.render 'games/show'

# Only listen on $ node app.js
unless module.parent
	app.listen DEFAULT_PORT
	console.log "Express server listening on port %d", app.address().port

	# Start the dnode listener for persistent connections
	everyone = nowjs.initialize app
	everyone.now.handleClientEvent = ->
		gameId = @now.gameId
		game = all_games[gameId]
		ServerGame::handleClientEvent.call game, this, arguments...

	everyone.connected ->
		gameId = @now.gameId
		return unless gameId?

		room = nowjs.getGroup gameId
		room.addUser @user.clientId
		@now.initializeClientGame all_games[gameId].forClient()

	everyone.disconnected ->
		gameId = @now.gameId
		room = nowjs.getGroup gameId
		room.removeUser @user.clientId
