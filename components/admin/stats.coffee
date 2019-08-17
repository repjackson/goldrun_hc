if Meteor.isClient
    Template.stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'stat'

    Template.stats.helpers
        stats_doc: ->
            Docs.findOne
                model:'stat'


if Meteor.isServer
    Meteor.methods
        calc_site_stats: ->
            stat_doc = Docs.findOne(model:'stat')
            unless stat_doc
                new_id = Docs.insert
                    model:'stat'
                stat_doc = Docs.findOne(model:'stat')
            console.log stat_doc
            owner_count = Meteor.users.find(owner:true).count()
            owner_count2 = Meteor.users.find(roles:$in:['owner']).count()
            resident_count = Meteor.users.find(roles:$in:['resident']).count()
            # total_count = Docs.find(model:'task').count()
            # complete_count = Docs.find(model:'task', complete:true).count()
            # incomplete_count = Docs.find(model:'task', complete:false).count()
            Docs.update stat_doc._id,
                $set:
                    owner_count:owner_count
                    owner_count2:owner_count2
                    resident_count:resident_count
            # role_owners = Meteor.users.find(roles:$in:['owner'])
            # Meteor.users.update({roles:$in:['owner']}, {$set:owner:true}, {multi:true})
