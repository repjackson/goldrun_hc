Meteor.methods
    generate_pdf: (user)->
        # console.log user
        doc = new PDFDocument({size: 'A4', margin: 50})
        doc.fontSize(12)
        doc.font('Times-Bold').text("Henry Health Client Report", {align: 'center'})
        if user.emails
            for email in user.emails
                doc.font('Times-Roman').text("Email: ", {align: 'left', continued:true})
                doc.font('Times-Bold').text("#{email.address}", {align: 'left'})

        for key,value of user
            unless key in ['emails','_id', 'services']
                # console.log key,value
                doc.font('Times-Roman').text("#{key}: ", {align: 'left', continued:true})
                doc.font('Times-Bold').text(" #{value}", {align: 'left'})
                # doc.moveDown();
        doc.write("#{user.first_name}_#{user.last_name}_profile.pdf")
