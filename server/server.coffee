Modules.allow
    insert: (userId, doc) -> doc.author_id is userId
    update: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')
    remove: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')


Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # # console.log 'user ' + userId + 'wants to modify doc' + doc._id
        # if userId and doc._id == userId
        #     # console.log 'user allowed to modify own account'
        #     true

Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.cloudinary_key
    api_secret: Meteor.settings.cloudinary_secret


# Meteor.startup ->
#     # BrowserPolicy.content.allowFrameOrigin 'youtube.com'
#     # BrowserPolicy.content.allowFrameOrigin 'res.cloudinary.com'
#     BrowserPolicy.content.allowOriginForAll( 'https://facet-repjackson.c9users.io/' )
#     BrowserPolicy.content.allowInlineScripts()
#     # BrowserPolicy.content.allowFrameOrigin( 'youtube.com' );
#     BrowserPolicy.content.allowSameOriginForAll();
#     BrowserPolicy.content.allowDataUrlForAll();
#     BrowserPolicy.content.allowEval();

#     BrowserPolicy.content.allowOriginForAll( 'youtube.com' );
#     BrowserPolicy.content.allowOriginForAll( 'fonts.googleapis.com' );
#     BrowserPolicy.content.allowOriginForAll( 'fonts.gstatic.com' );
#     BrowserPolicy.content.allowOriginForAll( 'res.cloudinary.com' );
#     # BrowserPolicy.content.allowOriginForAll( 'localhost' );
#     # BrowserPolicy.content.allowOriginForAll( '*' );
#     # BrowserPolicy.content.allowOriginForAll( 'unsafe-eval' );
#     BrowserPolicy.framing.allowAll();





AccountsMeld.configure
    askBeforeMeld: false
    # meldDBCallback: meldDBCallback
    # serviceAddedCallback: serviceAddedCallback

