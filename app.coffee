express = require 'express'
nowjs = require 'now'
Game = require './models/game'

app = module.exports = express.createServer()

# register a new mime type for client-side coffeescript
mime = require "mime"
mime.define
	'text/coffeescript': ['coffee']

DEFAULT_BOARD_SIZE = 6
DEFAULT_PORT = 3000

createNewGame = (gameId) ->
	room = nowjs.getGroup gameId
	new Game
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
	app.use express.compiler
		src: __dirname + "/client"
		dest: __dirname + "/public"
		enable: ["coffeescript"]
	app.use express.static __dirname + '/public'

all_games = {}

app.get '/games', (req, res) ->
	res.local 'all_games', all_games
	res.render 'games/index'

app.get '/g/:game_id', (req, res) ->
	gid = req.params.game_id
	all_games[gid] ||= createNewGame gid
	res.local 'game_id', gid
	res.local 'game', all_games[gid]
	res.render 'games/show'

app.get '/g/:game_id/set/:edge_num', (req, res) ->
	gid = req.params.game_id
	all_games[gid].fillEdge parseInt req.params.edge_num
	res.send true

# Only listen on $ node app.js
unless module.parent
	app.listen DEFAULT_PORT
	console.log "Express server listening on port %d", app.address().port

	# Start the dnode listener for persistent connections
	everyone = nowjs.initialize app

	everyone.connected ->
		gameId = @now.gameId
		room = nowjs.getGroup gameId
		room.addUser @user.clientId

	everyone.disconnected ->
		gameId = @now.gameId
		room = nowjs.getGroup gameId
		room.removeUser @user.clientId
