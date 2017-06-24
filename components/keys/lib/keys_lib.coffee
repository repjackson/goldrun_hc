@Keys = new Meteor.Collection 'keys'


# Keys.before.insert (userId, doc)->
#     doc.author_id = Meteor.userId()
#     return

# Keys.helpers
#     author: -> Meteor.users.findOne @author_id
#     when: -> moment(@timestamp).fromNow()

