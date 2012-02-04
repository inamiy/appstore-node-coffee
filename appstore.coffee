debug = false

_ = require 'underscore'
request = require 'request'
require 'coffee-script'
argv = require('optimist').argv

# stores
list = require './appstore-list.coffee'
stores = list.stores

# products
products = require './appstore-apps.json'

# argv
if argv._[0]?
	productId = products[argv._[0]]
else
	productId = products[0]
	
if not productId?
	console.error('Error: no productId')
	return

# request
for country, storeId of stores

	if debug
		console.log "requesting AppStore #{country} (#{storeId})..."
		console.log ""
	
	request {
		'uri': "http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?sortOrdering=4&onlyLatestVersion=false&sortAscending=true&pageNumber=0&type=Purple+Software&id=#{productId}", 
		'headers': {
			'User-Agent': 'iTunes-iPhone/2.2 (2)',
			'X-Apple-Store-Front': "#{storeId}-1"
		}
	}, 
	(err, response, body) ->
		
		#console.log response
		#return
		
		responseStoreId = (Number) response.headers['x-apple-request-store-front'].replace /([0-9]*)-1$/, (str, $1) ->
			$1
		responseCountry = key for key, value of stores when value is responseStoreId
		
		console.log "=================================================="
		console.log "AppStore #{responseCountry}"
		console.log ""
		
		if err?
			console.log err
			return
			
		if 0
			console.log body
			return
		
		#----------------------------------------
		# ratings
		#----------------------------------------
		regex = /<HBoxView rightInset="5" alt="([0-9]*) stars?, ([0-9]*) ratings?">/g
		
		filteredArray = body.match regex
		if filteredArray?
			for filtered in filteredArray
				filtered = filtered.replace regex, (str, $1, $2) ->
					' * ' + $1 + " stars = " + $2
				console.log filtered
			console.log ""
		else
			console.log "no rating"
		
		#----------------------------------------
		# user's comment
		#----------------------------------------
		regex = /<TextView topInset="2" leftInset="0" rightInset="0" styleSet="normal11" textJust="left"><SetFontStyle normalStyle="textColor">([\s\S]*?)<\/SetFontStyle><\/TextView>/g
		
		filteredArray = body.match regex
		if filteredArray?
			for filtered in filteredArray
			
				# trim regex
				filtered = filtered.replace regex, (str, $1) ->
					$1	
					
				# trim tags
				filtered = filtered.replace /(<.*|.*>)/g, (str, $1) ->
					""
					
				#trim empty line
				filtered = filtered.replace /(\s*\n)/g, (str, $1) ->
					"\n"
					
				#trim initial spaces
				filtered = filtered.replace /^(\s*)/g, (str, $1) ->
					""
				
				console.log filtered
				console.log "--------------------"
		else
			console.log "no comment"
			
		console.log ""