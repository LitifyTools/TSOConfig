global without sharing class SendEmail {
    
    public class SendEmailException extends Exception {}
    public static final String NO_TEMPLATE_FOUND_STRING = 'No email template was found with the provided Id // Name';
    public static final String MISSING_REQUIRED_RELATED_ID_STRING = 'When an email template is specified, a RelatedToId and ContactOrLeadId must also be specified.';
    
    // defines the input parameters of this flow element in the canvas designer
    global class InvokeSendEmail {
        // Variables documented in depth here: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_email_outbound_single.htm
        
        //Required
        @InvocableVariable(label='Related To ID' description='' required=false)
        global Id RelatedToId;
        @InvocableVariable(label='Contact/Lead/User ID' description='Required if you use an email template' required=false)
        global Id ContactOrLeadID;
        @InvocableVariable(label='Email Template Id' description='Contact/Lead/User ID required if you use this' required=false)
        global Id EmailTemplateId;  
        @InvocableVariable(label='Email Template Unique Name' description='API Name  -- Contact/Lead/User ID required if you use this' required=false)
        global String EmailTemplateName;  
        
        //Optional
        @InvocableVariable(label='ToAddresses' description='' required=false)
        global String ToAddresses;
        @InvocableVariable(label='Use Signature' description='' required=false)
        global Boolean UseSignature;
        @InvocableVariable(label='bccAddresses' description='' required=false)
        global String bccAddresses;
        @InvocableVariable(label='ccAddresses' description='' required=false)
        global String ccAddresses;
        @InvocableVariable(label='emailOptOutPolicy' description='Acceptable values: SEND, FILTER, or REJECT' required=false)
        global String emailOptOutPolicy;
        @InvocableVariable(label='subject' description='' required=false)
        global String subject;
        @InvocableVariable(label='plainTextBody' description='' required=false)
        global String plainTextBody;
        @InvocableVariable(label='HtmlBody' description='' required=false)
        global String HtmlBody;
        @InvocableVariable(label='OrgWideEmailAddress' description='' required=false)
        global String OrgWideEmailAddress;
        
        @InvocableVariable(label='TreatTargetObjectAsRecipient' description='' required=false)
        global Boolean TreatTargetObjectAsRecipient;
        @InvocableVariable(label='TreatBodiesAsTemplate' description='' required=false)
        global Boolean TreatBodiesAsTemplate;
        @InvocableVariable(label='Attachment - ContentDocument' description='ContentDocumentId' required=false)
        global String ContentDocumentId;
        @InvocableVariable(label='Attachment - ContentVersion' description='ContentVersionId' required=false)
        global String ContentVersionId;
        @InvocableVariable(label='Save As Activity' description='' required=false)
        global Boolean SaveAsActivity;    
    }
    
    @InvocableMethod(label='CustomSendEmail' )
    global static void sendEmail(List<InvokeSendEmail> requests){
        
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage> {};
        
        for ( InvokeSendEmail request : requests ) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
            // Find email template
            If( request.EmailTemplateId != null || request.EmailTemplateName !=null) {
                List<EmailTemplate> emailTemplateList = [SELECT Id, Name, DeveloperName, UiType, TemplateType, TemplateStyle 
                                                         FROM EmailTemplate 
                                                         WHERE (Id = :request.EmailTemplateId 
                                                                OR DeveloperName = :request.EmailTemplateName 
                                                                OR Name = :request.EmailTemplateName)
                                                         LIMIT 1];
                
                if (emailTemplateList.isEmpty()) {
                    throw new SendEmailException(
                        String.format(
                            '{0}: {1} // {2}',
                            new List<Object> {
                                NO_TEMPLATE_FOUND_STRING,
                                request.EmailTemplateId,
                                request.EmailTemplateName
                            }
                    ));
                } else {
                    request.EmailTemplateId = emailTemplateList[0].Id;
                    request.EmailTemplateName = emailTemplateList[0].DeveloperName;
                    
                    if (request.ContactOrLeadId == null || request.RelatedToId == null) {
                        throw new SendEmailException(MISSING_REQUIRED_RELATED_ID_STRING);
                    }
                    
                    mail = Messaging.renderStoredEmailTemplate(request.EmailTemplateId, request.ContactOrLeadId, request.RelatedToId);
                }
            } 
            
            //If no value - ie. no email - then remove it back to null
            if(request.ccAddresses != null && !request.ccAddresses.contains('@')) {
                request.ccAddresses=null;
            }
            
            if(request.bccAddresses != null && !request.bccAddresses.contains('@')) {
                request.bccAddresses=null;
            }
            
            if(request.ToAddresses != null && !request.ToAddresses.contains('@')) {
                request.ToAddresses=null;
            }
            
            //Create arrays
            String[] bccAddressesSplit = request.bccAddresses == null ? null : request.bccAddresses.split(',');
            String[] ccAddressesSplit = request.ccAddresses == null ? null : request.ccAddresses.split(',');
            String[] ToAddressesSplit = request.ToAddresses == null ? null : request.ToAddresses.split(',');			
            
            //Core parameters
            if(request.RelatedToId != null) {
                mail.setWhatId(request.RelatedToId);
            }
            
            //Someone to send to 
            if(request.ContactorLeadID != null) {
                mail.setTargetObjectId(request.ContactorLeadID);
            }
            
            if(ToAddressessplit != null && ToAddressessplit.size() > 0 ) {
                mail.setToAddresses( ToAddressessplit);
            }
            
            //An email template
            if(request.EmailTemplateId != null) {
                mail.setTemplateId(request.EmailTemplateId);
            }
            
            //Optional Parameters
            if(request.UseSignature != null) {
                mail.setUseSignature(request.UseSignature);
            }
            
            if(request.bccAddresses != null	 && bccAddressessplit.size() > 0) {
                mail.setBccAddresses(bccAddressessplit);
            }
            
            if(request.ccAddresses != null && ccAddressessplit.size() > 0) {
                mail.setCcAddresses(ccAddressessplit);
            }
            
            //if(request.parentMessageIds != null)		mail.setInReplyTo(request.parentMessageIds);
            if(request.emailOptOutPolicy != null) {
                mail.setOptOutPolicy(request.emailOptOutPolicy);
            }
            
            if(request.TreatTargetObjectAsRecipient != null) {
                mail.setTreatTargetObjectAsRecipient(request.TreatTargetObjectAsRecipient);
            }
            
            //these fields don't work if they have an emailtemplateid
            if(request.subject != null && request.EmailTemplateId == null) {
                mail.setSubject(request.subject);
            }
            
            if(request.plainTextBody != null && request.EmailTemplateId == null) {
                mail.setplainTextBody(request.plainTextBody);
            }
            
            if(request.HtmlBody != null && request.EmailTemplateId == null) {
                mail.setHtmlBody(request.HtmlBody);
            }
            
            //if(request.references  != null) 			mail.setReferences(request.references );			
            if(request.TreatBodiesAsTemplate  != null) {
                mail.setTreatTargetObjectasRecipient(request.TreatBodiesAsTemplate);
            }
            
            if(request.OrgWideEmailAddress != null) {
                OrgWideEmailAddress[] OrgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :request.OrgWideEmailAddress];
                if(OrgWideEmail.size()>0) {
                    mail.setOrgWideEmailAddressId(OrgWideEmail[0].Id);
                }
            }
            
            mail.setSaveAsActivity(!(request.SaveAsActivity == false || request.ContactorLeadID == null));
            
            //Save as activity  must be false if sending to users
            if(request.ContactOrLeadID != null && String.valueOf(request.ContactOrLeadID).startsWithIgnoreCase('005')) {
                mail.SaveAsActivity = false;
            }			
            
            //Check for files
            if(request.ContentVersionId == null && request.ContentDocumentId != null){
                // Find version
                request.ContentVersionId = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :request.ContentDocumentId].ID;
            }
            
            if(request.ContentVersionId != null  && request.ContentVersionId != ''){
                ContentVersion cv = [SELECT Id, VersionData, PathOnClient FROM ContentVersion WHERE ID = :request.ContentVersionId];
                // Create the email attachment
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.pathOnClient); 
                efa.setBody(cv.versionData);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            }
            
            mails.add(mail);
        }
        
        
        //Send the Email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
        for(Messaging.SendEmailResult result: results) {
            if (result.isSuccess()) {
                System.debug('The email was sent successfully.');
            } else {
                String errorString = 'An email failed to send ';
                for (Messaging.SendEmailError error: result.getErrors()) {
                	errorString += ' :: ' + error.getMessage();
                }
                throw new SendEmailException(errorString);
            }
        }
        
    }     
}