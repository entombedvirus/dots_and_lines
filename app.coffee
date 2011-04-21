express = require 'express'
Game = require './models/game'

app = module.exports = express.createServer()

# register a new mime type for client-side coffeescript
mime = require "mime"
mime.define
	'text/coffeescript': ['coffee']

DEFAULT_BOARD_SIZE = 6

createNewGame = ->
	g = new Game DEFAULT_BOARD_SIZE
	g.on 'completeSquare', ->
		console.log "Square Completed!!"
	g

# Configuration
app.configure ->
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	# app.use express.logger()
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use app.router
	app.use express.static __dirname + '/public'

all_games = {}

app.get '/games', (req, res) ->
	res.local 'all_games', all_games
	res.render 'games/index'

app.get '/g/:game_id', (req, res) ->
	gid = req.params.game_id
	all_games[gid] ||= createNewGame()
	res.local 'game_id', gid
	res.local 'game', all_games[gid]
	res.render 'games/show'

app.get '/g/:game_id/set/:edge_num', (req, res) ->
	gid = req.params.game_id
	all_games[gid].fillEdge parseInt req.params.edge_num
	res.redirect "/g/#{gid}"

# Only listen on $ node app.js
unless module.parent
	app.listen 3000
	console.log "Express server listening on port %d", app.address().port
