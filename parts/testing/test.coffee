if Meteor.isClient
    Router.route '/tests', (->
        @layout 'layout'
        @render 'tests'
        ), name:'tests'
    Router.route '/test/:doc_id/edit', (->
        @layout 'layout'
        @render 'test_edit'
        ), name:'test_edit'
    Router.route '/test/:doc_id/view', (->
        @layout 'layout'
        @render 'test_view'
        ), name:'test_view'
    Router.route '/test_session/:doc_id/take', (->
        @layout 'layout'
        @render 'take_act_test'
        ), name:'take_act_test'
    Router.route '/test_session/:doc_id/description', (->
        @layout 'layout'
        @render 'act_test_description'
        ), name:'act_test_description'




    Template.tests.onRendered ->
        @autorun -> Meteor.subscribe('test_facet_docs',
            selected_test_tags.array()
            Session.get('view_answered')
            Session.get('view_unanswered')
            Session.get('view_correct')
            Session.get('view_incorrect')
        )
    Template.test_segment.onRendered ->
        # $(e.currentTarget).closest('.button').transition('pulse',200)
        #
        # $( ".select_test" ).dblclick( ->
        #     alert( "Handler for .dblclick() called." );
        # );

        # @autorun => Meteor.subscribe 'model_docs', 'test'
        # @autorun => Meteor.subscribe 'model_docs', 'test_session'
    Template.tests.helpers
        tests: ->
            Docs.find
                model:'test'
        test_sessions: ->
            Docs.find {
                model:'test_session'
                _author_id: Meteor.userId()
            }, sort: _timestamp: -1
        selected_test_doc: ->
            Docs.findOne Session.get('selected_test_id')


    Template.test_segment.helpers
        select_test_class: ->
            if Session.equals('selected_test_id', @_id) then 'inverted blue' else ''

    Template.test_segment.events
        'click .select_test': ->
            if Session.equals('selected_test_id',@_id)
                Session.set 'selected_test_id', null
            else
                Session.set 'selected_test_id', @_id

    Template.selected_test.events
        'click .delete_test': ->
            if confirm 'delete test?'
                Docs.remove @_id
                Session.set('selected_test_id', null)
        'click .save_test': ->
            Session.set('editing_test', false)
        'click .edit_test': ->
            Session.set('editing_test', true)
    Template.selected_test.helpers
        editing_test: -> Session.get('editing_test')




    Template.tests.events
        'click .take_forest_test': ->
            Session.set 'current_question_id', null
            new_ts_id = Docs.insert
                model:'test_session'
                question_count:10
                generated:false
            Router.go "/test_session/#{new_ts_id}/edit"
        'click .view_test': ->
            Router.go "/test_session/#{@_id}/view"
        'click .refresh_user_stats': ->
            Meteor.call 'refresh_user_stats', Meteor.userId()
        'click .add_test': ->
            new_test_id = Docs.insert
                model:'test'
            Router.go "/test/#{new_test_id}/edit"
        'click .unselect_test': ->
            Session.set('selected_test_id', null)


    Template.test_cloud.onCreated ->
        @autorun -> Meteor.subscribe('test_tags',
            selected_test_tags.array()
            Session.get('view_answered')
            Session.get('view_unanswered')
            Session.get('view_correct')
            Session.get('view_incorrect')
        )
        # @autorun -> Meteor.subscribe('model_docs', 'target')
    Template.test_cloud.helpers
        selected_target_id: -> Session.get('selected_target_id')
        selected_target: ->
            Docs.findOne Session.get('selected_target_id')
        all_test_tags: ->
            test_count = Docs.find(model:'test').count()
            if 0 < test_count < 3 then Test_tags.find { count: $lt: test_count } else Test_tags.find({},{limit:42})
        selected_test_tags: -> selected_test_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key
    Template.test_cloud.events
        'click .unselect_target': -> Session.set('selected_target_id',null)
        'click .select_target': -> Session.set('selected_target_id',@_id)
        'click .select_test_tag': -> selected_test_tags.push @name
        'click .unselect_test_tag': -> selected_test_tags.remove @valueOf()
        'click #clear_test_tags': -> selected_test_tags.clear()




    Template.select_english_answer.helpers
        editing: ->
            Session.equals('editing_id', @_id)
    Template.select_english_answer.events
        'click .set_editing': ->
            parent = Template.parentData()
            console.log parent
            Session.set('editing_id', parent._id)

        'click .save_answer': ->
            console.log @
            Session.set('editing_id', null)

    #     $('.ui.dropdown').dropdown(
    #         clearable:true
    #         action: 'activate'
    #         onChange: (text,value,$selectedItem)->
    #         )



    Template.answer_row.helpers
        bubble_class: ->
            console.log @

Meteor.methods
    select_act_choice: (key, question_id, session_id)->
        # console.log 'session id', session_id
        # console.log 'question id', question_id
        question = Docs.findOne question_id
        # console.log question
        correct_choice = key is question.answer
        # choice = Docs.findOne choice_id
        existing_choice_selected = Docs.findOne({
            _id:session_id
            "answers.question_id":question_id
            })
        if existing_choice_selected
            Docs.update {
                _id:session_id
                "answers.question_id":question_id
            }, {
                $set:
                    "answers.$.selected_answer": key
                    "answers.$.correct_choice": correct_choice
            }
        else
            Docs.update {
                _id:session_id
            }, {
                $addToSet:
                    answers:
                        question_id:question_id
                        selected_answer:key
                        correct_choice:correct_choice
            }


if Meteor.isServer
    Meteor.publish 'tests', (product_id)->
        Docs.find
            model:'test'
            product_id:product_id

    Meteor.publish 'test_from_test_id', (test_id)->
        test_session = Docs.findOne test_id
        Docs.find
            _id: test_session.test_id

    Meteor.methods
        refresh_user_stats: (user_id)->
            user = Meteor.users.findOne user_id
            user_session_cursor = Docs.find
                _author_id: Meteor.userId()
                model:'test_session'
            user_session_count = user_session_cursor.count()
            total_correct_percent = 0
            for session in user_session_cursor.fetch()
                console.log session.correct_percent
                if session.correct_percent
                    total_correct_percent += parseInt(session.correct_percent)


            # console.log total_correct_percent
            user_average_correct_percent = total_correct_percent/user_session_count
            Meteor.users.update user_id,
                $set:
                    total_session_amount:user_session_count
                    average_correct_percent:user_average_correct_percent.toFixed()








    Meteor.publish 'test_tags', (
        selected_test_tags
        view_answered
        view_unanswered
        view_correct
        view_incorrect
        )->
        self = @
        match = {}

        # console.log selected_test_tags
        # console.log view_answered
        # console.log view_unanswered
        # console.log view_correct
        # console.log view_incorrect
        if view_answered
            match.answered_user_ids = $in:[Meteor.userId()]
        if view_unanswered
            match.answered_user_ids = $nin:[Meteor.userId()]
        if view_correct
            match.correct_user_ids = $in:[Meteor.userId()]
        if view_incorrect
            match.incorrect_user_ids = $in:[Meteor.userId()]


        # if selected_target_id
        #     match.target_id = selected_target_id
        # selected_test_tags.push current_herd

        if selected_test_tags.length > 0 then match.tags = $all: selected_test_tags
        match.model = 'test'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_test_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'test_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'test_facet_docs', (
        selected_test_tags
        view_answered
        view_unanswered
        view_correct
        view_incorrect
        )->

        # console.log selected_test_tags
        # console.log view_answered
        # console.log view_unanswered
        # console.log view_correct
        # console.log view_incorrect
        # console.log filter
        self = @
        match = {}
        # if selected_target_id
        #     match.target_id = selected_target_id
        if view_answered
            match.answered_user_ids = $in:[Meteor.userId()]
        if view_unanswered
            match.answered_user_ids = $nin:[Meteor.userId()]
        if view_correct
            match.correct_user_ids = $in:[Meteor.userId()]
        if view_incorrect
            match.incorrect_user_ids = $in:[Meteor.userId()]

        # if filter is 'shop'
        #     match.active = true
        if selected_test_tags.length > 0 then match.tags = $all: selected_test_tags
        match.model = 'test'
        Docs.find match,
            sort:_timestamp:1
            # limit: 5
