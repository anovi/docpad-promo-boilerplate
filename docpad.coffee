path = require("path")
normalizedPath = path.join(__dirname, "data")
dataObj = {}

require("fs").readdirSync(normalizedPath).forEach (file) =>
	dataObj[path.basename(file)] = require('./data/' + file)
	ext = path.extname(file)
	dataObj[path.basename(file, ext)] = dataObj[path.basename(file)]


# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig =

	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:

		data: dataObj

		# Specify some site properties
		site:
			# The production url of our website
			# If not set, will default to the calculated site URL (e.g. http://localhost:9778)
			url: "http://superduper.com"

			# Here are some old site urls that you would like to redirect from
			# oldUrls: [
			# 	'www.website.com',
			# 	'website.herokuapp.com'
			# ]

			# The default title of our website
			title: "SuperDuper"

			# The website description (for SEO)
			description: """
				The best site ever.

				"""

			# The website keywords (for SEO) separated by commas
			keywords: """
				one, two, three
				"""

			links:
				twitter: 'https://twitter.com/'
				facebook: 'https://www.facebook.com/'

			sharing:
				og:
					title       : "SuperDuper"
					type        : "website"
					url         : "http://superduper.com/"
					image       : "http://superduper.com/super-duper.png"
					description : "The best site ever."
				twitter:
					card        : "summary_large_image"
					site        : "@super_duper"
					creator     : "@super_duper"
					url         : "http://superduper.com/"
					title       : "SuperDuper"
					description : "Description on card. The best site ever."
					text        : "Tweet text with link — http://superduper.com/"
					image       : "http://superduper.com/img/optima-share-og.png"

			# The common website's styles. Will be concatenated
			styles: [
				'/vendor/normalize.css'
				'/styles/style.css'
			]

			# The common website's scripts. Will be concatenated
			scripts: [
				'/vendor/log.js'
				'/scripts/likes.js'
				'/scripts/common.js'
			]


		# -----------------------------
		# Helper Functions

		# Get the prepared site/document title
		# Often we would like to specify particular formatting to our page's title
		# we can apply that formatting here
		getPreparedTitle: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.title
				"#{@document.title} | #{@site.title}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.title

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')

		getMetaSharing: ->
			content = ""
			for key, val of @site.sharing.og
				if @document.og?[key]
					val = @document.og[key]
				else if @document.basename isnt 'index'
					val = @document.title if key is 'title'
					val = @document.url if key is 'url'
					val = @document.description if key is 'description' and @document.description
					continue if key is 'image'
				pre = if key is 'url' or key is 'image' then @site.url else ''
				content += "<meta property=\"og:#{key}\" content=\"#{pre}#{val}\" />\n"
			for key, val of @site.sharing.twitter
				if @document.twitter?[key]
					val = @document.twitter[key]
				else if @document.og?[key]
					val = @document.og[key]
				else if @document.basename isnt 'index'
					val = @document.title if key is 'title'
					val = @document.title if key is 'text'
					val = @document.url if key is 'url'
					val = @document.description if key is 'description' and @document.description
					continue if key is 'image'
				pre = if key is 'url' or key is 'image' then @site.url else ''
				content += "<meta name=\"twitter:#{key}\" content=\"#{pre}#{val}\" />\n"
			content

		beautifyDate: (date) ->
			moment = require('moment');
			moment.locale('ru');
			return moment(date).format('D MMMM YYYY');

		# Get the Absolute URL of a document
		getDocUrl: (document) ->
			return @site.url + (document.url or document.get?('url'))


	# =================================
	# Collections

	# Here we define our custom collections
	# What we do is we use findAllLive to find a subset of documents from the parent collection
	# creating a live collection out of it
	# A live collection is a collection that constantly stays up to date
	# You can learn more about live collections and querying via
	# http://bevry.me/queryengine/guide

	collections:

		# Create a collection called blog
		# That contains all the documents that will be going to the out path posts
		blog: ->
			@getCollection('documents').findAllLive({relativeOutDirPath: 'blog', basename: $ne: 'index'}, [{date:-1}])

		mainMenu: ->
			@getCollection('html').findAllLive({menuOrder: $exists: true})


	# =================================
	# Environments

	# DocPad's default environment is the production environment
	# The development environment, actually extends from the production environment

	# The following overrides our production url in our development environment with false
	# This allows DocPad's to use it's own calculated site URL instead, due to the falsey value
	# This allows <%- @site.url %> in our template data to work correctly, regardless what environment we are in

	environments:
		production:
			plugins:
				cleanurls:
					trailingSlashes: false
					static: true
		development:
			templateData:
				site:
					url: false

	plugins:
		rss:
			default:
				collection: 'blog'
				url: '/rss.xml'
		cleanurls:
			trailingSlashes: false
			static: true
		stylus:
			stylusOptions:
				compress: false
		gulp:
			environments:
				static:
					enabled: true
				development:
					enabled: false
		menu:
			menuOptions:
				optimize: true
				skipEmpty: true
				skipFiles: ///\.js|\.scss|\.css/// #regexp are delimited by three forward slashes in coffeescript



	# =================================
	# DocPad Events

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki

	events:

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad

			# As we are now running in an event,
			# ensure we are using the latest copy of the docpad configuraiton
			# and fetch our urls from it
			latestConfig = docpad.getConfig()
			oldUrls = latestConfig.templateData.site.oldUrls or []
			newUrl = latestConfig.templateData.site.url

			# Redirect any requests accessing one of our sites oldUrls to the new site url
			server.use (req,res,next) ->
				if req.headers.host in oldUrls
					res.redirect(newUrl+req.url, 301)
				else
					next()


# Export our DocPad Configuration
module.exports = docpadConfig