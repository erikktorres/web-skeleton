# DocPad Configuration File
# http://docpad.org/docs/config

port = process.env.PORT || 6556
# Define the DocPad Configuration
docpadConfig = {
  port: port
  templateData:
    site:
      url: "http://tidepool-org.github.io/web-skeleton/"
      title: "Simple static web page demonstrating web styles"
      description: ""
      keywords: ""
      author: "Tidepool contributors"
      email: "info@tidepool.org"
      copyright: "Tidepool Project"
      services:
        googleAnalytics: ''
        twitterFollowButton: ''
        githubFollowButton: ''

   # Helper Functions
    # ----------------
    # Get absolute URL
    getUrl: (document) ->
      return @site.url + (document.url or document.get?('url'))


    getViewGH: ->
      prefix = 'https://github.com/tidepool-org/web-skeleton'
      action = 'blob/master/src/documents'
      path = @document.relativePath
      "#{prefix}/#{action}/#{path}"
    getProse: ->
      prefix = 'http://prose.io/#tidepool-org/web-skeleton'
      edit = 'edit/master/src/documents'
      path = @document.relativePath
      "#{prefix}/#{edit}/#{path}"
    getGithub: ->
      prefix = 'https://github.com/tidepool-org/web-skeleton'
      edit = 'edit/master/src/documents'
      path = @document.relativePath
      "#{prefix}/#{edit}/#{path}"

    getAuthor: (document) ->
      author = @site.author
      if document and document.author
        author = document.author
      return author

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


  # Collections
  # ===========
  # These are special collections that our website makes available to us

  collections:
    # For instance, this one will fetch in all documents that have pageOrder set within their meta data
    pages: (database) ->
      database.findAllLive({pageOrder: $exists: true}, [pageOrder:1,title:1])

    # This one, will fetch in all documents that will be outputted to the posts
    # directory
    posts: (database) ->
      database.findAllLive({relativeOutDirPath:'posts'},[date:-1])


  # DocPad Events
  # =============

  # Here we can define handlers for events that DocPad fires
  # You can find a full listing of events on the DocPad Wiki
  events:

    # Server Extend
    # Used to add our own custom routes to the server before the docpad routes
    # are added
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
          res.redirect 301, newUrl+req.url
        else
          next()

  environments:
    development:
      templateData:
        site:
          url: "http://localhost:#{port}/index.html"


}

# Export the DocPad Configuration
module.exports = docpadConfig
