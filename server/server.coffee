
Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # # console.log 'user ' + userId + 'wants to modify doc' + doc._id
        # if userId and doc._id == userId
        #     # console.log 'user allowed to modify own account'
        #     true

Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.private.cloudinary_key
    api_secret: Meteor.settings.private.cloudinary_secret


# SyncedCron.add
#     name: 'Update incident escalations'
#     schedule: (parser) ->
#         # parser is a later.parse object
#         parser.text 'every 1 hour'
#     job: ->
#         Meteor.call 'update_escalation_statuses', (err,res)->
#             if err then console.log err
#             # else
                # console.log 'res:',res


SyncedCron.add({
        name: 'check out members'
        schedule: (parser) ->
            parser.text 'every 1 hours'
        job: ->
            Meteor.call 'checkout_members', (err, res)->
                if err then console.log err
                else
                    console.log 'check out members',res
    },{
        name: 'check leases'
        schedule: (parser) ->
            # parser is a later.parse object
            parser.text 'every 24 hours'
        job: ->
            Meteor.call 'check_lease_status', (err, res)->
                if err then console.log err
                else
                    console.log 'user sync res:',res
    }
)


if Meteor.isProduction
    SyncedCron.start()

Meteor.publish 'model_docs', (model)->
    Docs.find
        model: model

Meteor.publish 'document_by_slug', (slug)->
    Docs.find
        model: 'document'
        slug:slug

Meteor.publish 'child_docs', (id)->
    Docs.find
        parent_id:id


Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array


Meteor.publish 'inline_doc', (slug)->
    Docs.find
        model:'inline_doc'
        slug:slug


Meteor.publish 'current_session', ->
    Docs.find
        model: 'healthclub_session'
        current:true


Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    # console.log user_id
    Meteor.users.find user_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    # console.log user_id
    doc = Docs.findOne doc_id
    Meteor.users.find user_id

Meteor.publish 'page', (slug)->
    Docs.find
        model:'page'
        slug:slug

Meteor.publish 'page_children', (slug)->
    page = Docs.findOne
        model:'page'
        slug:slug
    # console.log page
    Docs.find
        parent_id:page._id



Meteor.publish 'checkin_guests', (doc_id)->
    session_document = Docs.findOne doc_id
        # model:'healthclub_session'
        # current:true
    console.log session_document.guest_ids
    Docs.find
        _id:$in:session_document.guest_ids


Meteor.publish 'resident', (guest_id)->
    guest = Docs.findOne guest_id
    Meteor.users.find
        _id:guest.resident_id



Meteor.publish 'health_club_members', (username_query)->
    console.log username_query
    Meteor.users.find({
        username: {$regex:"#{username_query}", $options: 'i'}
        # healthclub_checkedin:$ne:true
        roles:$in:['resident','owner']
        },{ limit:10 })




Meteor.publish 'page_blocks', (slug)->
    # console.log slug
    page = Docs.findOne
        model:'page'
        slug:slug
    # console.log page
    if page
        Docs.find
            parent_id:page._id


Meteor.publish 'doc_tags', (selected_tags)->

    user = Meteor.users.findOne @userId
    # current_herd = user.profile.current_herd

    # console.log selected_tags
    self = @
    match = {}

    # selected_tags.push current_herd
    match.tags = $all: selected_tags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: "$tags" }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    # console.log 'cloud, ', cloud
    cloud.forEach (tag, i) ->

        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()
