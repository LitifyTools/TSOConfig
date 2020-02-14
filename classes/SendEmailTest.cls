@istest
Global class SendEmailTest {
    
    private static final String uniqueString = '' + DateTime.now().getTime();
    
    private static String createEmailTemplate() {
        EmailTemplate testEmailTemplate = new EmailTemplate();
        testEmailTemplate.isActive = true;
        testEmailTemplate.Name = 'Template ' + uniqueString;
        testEmailTemplate.DeveloperName = 'Template_' + uniqueString;
        testEmailTemplate.TemplateType = 'text';
        testEmailTemplate.FolderId = UserInfo.getUserId();
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            insert testEmailTemplate; // avoid Mixed DML issues
        }
        return testEmailTemplate.Id;
    }
    
    private static Account createAccount() {
        Account testAccount = new Account(Name='Test Account 54321');
        String businessAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        if (businessAccountRecordType != '') {
            testAccount.RecordTypeId = businessAccountRecordType;
        }
        insert testAccount;
        return testAccount;
    }
    
    private static Contact createContact(String testAccountId) {
        Contact testContact = new Contact(
            LastName = 'TestLastName ' + uniqueString, // guaranteed unique
            AccountId = testAccountId,
            Email = String.format('test_{0}@example.com', new List<Object> {uniqueString})
        );
        insert testContact;
        return testContact;
    }
    
    private static ContentVersion createContentVersion() {
        ContentVersion testContentVersion = new ContentVersion();
        testContentVersion.Title = 'TestTitle';
        testContentVersion.PathOnClient = 'test';
        testContentVersion.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body', 'UTF-8'));
        insert testContentVersion;
        return testContentVersion;
    }
    
    @isTest
    static void sendEmail_success_withTemplate() {
        
        String testEmailTemplateId = createEmailTemplate();
        Account testAccount = createAccount();        
        Contact testContact = createContact(testAccount.Id);
        
        //CREATE SINGLE EMAIL
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.RelatedToId = testAccount.Id;
        request.ContactOrLeadId = testContact.Id;
        request.EmailTemplateId = testEmailTemplateId;
		request.EmailTemplateName = 'Template_' + uniqueString;
        request.ToAddresses = testContact.Email;
        request.UseSignature = true;
        request.bccAddresses = 'not email';
        request.ccAddresses = 'not email';
        request.emailOptOutPolicy = 'SEND';
        request.subject = 'Test Subject';
        request.plainTextBody = 'Test Content';
        request.HtmlBody = '<p>Test Content</p>';
        request.TreatTargetObjectAsRecipient = true;
        request.TreatBodiesAsTemplate = false;
		
        List<OrgWideEmailAddress> orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE IsAllowAllProfiles = TRUE LIMIT 1];
        if (!orgWideAddress.isEmpty()) {
            request.OrgWideEmailAddress = orgWideAddress[0].Address;
        }
        
        Test.startTest();
        SendEmail.sendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();  
        
        System.assertEquals(1, emailInvocations, 'An email should have been sent');
    }
    
    @isTest
    static void sendEmail_success_noTemplate() {
        
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.ToAddresses = 'not email';
        request.ContactOrLeadID = UserInfo.getUserId();
        request.UseSignature = true;
        request.bccAddresses = 'test1@example.com, test2@example.com';
        request.ccAddresses = 'test3@example.com, test4@example.com';
        request.subject = 'Test Subject';
        request.plainTextBody = 'Test Content';
        request.HtmlBody = '<p>Test Content</p>';
        
        Test.startTest();
        SendEmail.sendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();  
        
        System.assertEquals(1, emailInvocations, 'An email should have been sent');
    }
    
    @isTest
    static void sendEmail_success_hasAttachment() {
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.ToAddresses = 'test@example.com';
        request.subject = 'Test Subject';
        request.plainTextBody = 'Test Content';
        request.HtmlBody = '<p>Test Content</p>';
        request.ContentVersionId = createContentVersion().Id;
        
        Test.startTest();
        SendEmail.sendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();  
        
        System.assertEquals(1, emailInvocations, 'An email should have been sent');
    }
    
    @isTest
    static void sendEmail_failure_badTemplateId() {
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateId = UserInfo.getUserId();
        
        Test.startTest();
        SendEmail.SendEmailException thrownException;
        try {
            SendEmail.sendEmail(new List<SendEmail.InvokeSendEmail>{ request });
        } catch (SendEmail.SendEmailException e) {
            thrownException = e;
        }
        Test.stopTest();
        
        System.assert(thrownException != null, 'An exception should have been thrown because of a bad email template id');
		System.assert(thrownException.getMessage().startsWith(SendEmail.NO_TEMPLATE_FOUND_STRING), 'Exception should have been due to a bad email template Id');
    }
    
    @isTest
    static void sendEmail_failure_noRelatedToIdWithIncludedTemplate() {
        String testEmailTemplateId = createEmailTemplate();
    	SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateId = testEmailTemplateId;
        
        Test.startTest();
        SendEmail.SendEmailException thrownException;
        try {
            SendEmail.sendEmail(new List<SendEmail.InvokeSendEmail>{ request });
        } catch (SendEmail.SendEmailException e) {
            thrownException = e;
        }
        Test.stopTest();
        
        System.assert(thrownException != null, 'An exception should have been thrown because of a missing RelatedToId');
		System.assertEquals(SendEmail.MISSING_REQUIRED_RELATED_ID_STRING, thrownException.getMessage(), 'Exception should have been due to a missing RelatedToId');
    }
    
    @isTest
    static void sendEmail_failure_noRecipient() {
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        
        Test.startTest();
        SendEmail.SendEmailException thrownException;
        try {
            SendEmail.sendEmail(new List<SendEmail.InvokeSendEmail>{ request });
        } catch (SendEmail.SendEmailException e) {
            thrownException = e;
        }
        Test.stopTest();
        
        System.assert(thrownException != null, 'An exception should have been thrown because there was no recipient.');
    }
    
}