
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


Meteor.publish 'type', (type)->
    Docs.find
        type: type

Meteor.publish 'child_docs', (id)->
    Docs.find
        parent_id:id

Meteor.publish 'user_from_username', (username)->
    Meteor.users.find
        username: username


Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array


Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    # console.log user_id
    Meteor.users.find user_id



Meteor.publish 'page', (slug)->
    Docs.find
        type:'page'
        slug:slug



Meteor.publish 'page_children', (slug)->
    page = Docs.findOne
        type:'page'
        slug:slug
    # console.log page
    Docs.find
        parent_id:page._id



Meteor.publish 'page_blocks', (slug)->
    # console.log slug
    page = Docs.findOne
        type:'page'
        slug:slug
    # console.log page
    if page
        Docs.find
            parent_id:page._id
