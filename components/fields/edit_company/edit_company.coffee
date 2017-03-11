if Meteor.isClient
    Template.edit_company.events
        'change #company': ->
            doc_id = FlowRouter.getParam('doc_id')
            company = $('#company').val()
    
            Docs.update doc_id,
                $set: company: company


