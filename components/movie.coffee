# Router.route '/movie/:doc_id/view', -> @render 'movie_view'
# Router.route '/movie/:doc_id/edit', -> @render 'movie_edit'


if Meteor.isClient
    # Template.movie_view.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.movie_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.movie_view.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.movie_card_template.onCreated ->
        @autorun => Meteor.subscribe 'children', 'movie_update', @data._id
    Template.movie_card_template.helpers
        updates: ->
            Docs.find
                model:'movie_update'
                parent_id: @_id


    Template.movie_view.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'movie_update', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'ballot_movies', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'movie_options', Router.current().params.doc_id
    Template.movie_view.helpers
        options: ->
            Docs.find
                model:'movie_option'
        movies: ->
            Docs.find
                model:'movie'
                ballot_id: Router.current().params.doc_id

    # Template.movie_edit.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    #     @autorun => Meteor.subscribe 'movie_options', Router.current().params.doc_id
    # Template.movie_edit.events
    #     'click .add_option': ->
    #         Docs.insert
    #             model:'movie_option'
    #             ballot_id: Router.current().params.doc_id
    # Template.movie_edit.helpers
    #     options: ->
    #         Docs.find
    #             model:'movie_option'


    # Template.latest_movie_updates.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'movie_update'
    #
    # Template.latest_movie_updates.helpers
    #     latest_updates: ->
    #         Docs.find {
    #             model:'movie_update'
    #         },
    #             limit:5
    #             sort:_timestamp:-1
    #
    #




if Meteor.isServer
    Meteor.publish 'ballot_movies', (ballot_id)->
        Docs.find
            model:'movie'
            ballot_id:ballot_id
    Meteor.publish 'movie_options', (ballot_id)->
        Docs.find
            model:'movie_option'
            ballot_id:ballot_id
    # Meteor.methods
        # recalc_movies: ->
        #     movie_stat_doc = Docs.findOne(model:'movie_stats')
        #     unless movie_stat_doc
        #         new_id = Docs.insert
        #             model:'movie_stats'
        #         movie_stat_doc = Docs.findOne(model:'movie_stats')
        #     console.log movie_stat_doc
        #     total_count = Docs.find(model:'movie').count()
        #     complete_count = Docs.find(model:'movie', complete:true).count()
        #     incomplete_count = Docs.find(model:'movie', complete:$ne:true).count()
        #     total_updates_count = Docs.find(model:'movie_update').count()
        #     Docs.update movie_stat_doc._id,
        #         $set:
        #             total_count:total_count
        #             complete_count:complete_count
        #             incomplete_count:incomplete_count
        #             total_updates_count:total_updates_count
