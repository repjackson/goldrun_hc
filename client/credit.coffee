Template.credit.events
    'click .add_credit': ->
        console.log @
        Meteor.users.update Meteor.userId(),
            $inc:credit:1
    'click .remove_credit': ->
        console.log @
        Meteor.users.update Meteor.userId(),
            $inc:credit:-1
