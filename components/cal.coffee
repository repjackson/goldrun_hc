# import Calendar from 'tui-calendar'; /* ES6 */
# import "tui-calendar/dist/tui-calendar.css";


Calendar = require('tui-calendar');
require("tui-calendar/dist/tui-calendar.css");
# Calendar = tui.Calendar;


if Meteor.isClient
    Template.cal.onCreated ->
        @autorun -> Meteor.subscribe 'my_alpha'
    Template.cal.onRendered ->
        calendar = new Calendar('#calendar', {
          defaultView: 'month',
          taskView: true,
          template: {
            monthGridHeader: (model)->
              date = new Date(model.date);
              template = '<span class="tui-full-calendar-weekday-grid-date">' + date.getDate() + '</span>';
              return template;
          }
        });


    Template.cal.helpers
        selected_tags: -> selected_tags.list()

        current_alpha: ->
            Docs.findOne
                model:'alpha'
                # _author_id:Meteor.userId()

        global_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        single_doc: ->
            alpha = Docs.findOne model:'alpha'
            count = alpha.result_ids.length
            if count is 1 then true else false




    Template.cal.events
        'click .create_alpha': (e,t)->
            new_alpha_id = Docs.insert
                model:'alpha'
            Meteor.call 'fa', new_alpha_id, (err,res)->


        'click .print_alpha': (e,t)->
            alpha = Docs.findOne model:'alpha'
            console.log alpha

        'click .reset': ->
            alpha = Docs.findOne model:'alpha'
            Meteor.call 'fa', alpha._id, (err,res)->

        'click .delete_alpha': (e,t)->
            alpha = Docs.findOne model:'alpha'
