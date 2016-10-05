@isTest

public class CheckOpportunityDuplicatesTests{
    static testMethod void testCheckOpportunityDuplicates() {
        
      // First make sure there are no Opportunitys already in the system
      // that have the email addresses used for testing
      Set<String> testEmailAddress = new Set<String>();
      testEmailAddress.add('test1@duptest.com');
      testEmailAddress.add('test2@duptest.com');
      testEmailAddress.add('test3@duptest.com');
      testEmailAddress.add('test4@duptest.com');
      testEmailAddress.add('test5@duptest.com');
      System.assert([SELECT count() FROM Opportunity
                     WHERE Borrower_Email__c IN :testEmailAddress] == 0);
        
      // Seed the database with some Opportunitys, and make sure they can
      // be bulk inserted successfully.
      Opportunity Opportunity1 = new Opportunity(Name='Test1', CloseDate = Date.today(), StageName = 'Lead',
                            Borrower_Email__c = 'test1@duptest.com');
      Opportunity Opportunity2 = new Opportunity(Name='Test2', CloseDate = Date.today(), StageName = 'Lead',
                            Borrower_Email__c = 'test4@duptest.com');
      Opportunity Opportunity3 = new Opportunity(Name='Test3', CloseDate = Date.today(), StageName = 'Lead',
                            Borrower_Email__c = 'test5@duptest.com');
      Opportunity[] Opportunities = new Opportunity[] {Opportunity1, Opportunity2, Opportunity3};
      insert Opportunities;
        
      // Now make sure that some of these Opportunitys can be changed and
      // then bulk updated successfully. Note that Opportunity1 is not
      // being changed, but is still being passed to the update
      // call. This should be OK.
      Opportunity2.Borrower_Email__c = 'test2@duptest.com';
      Opportunity3.Borrower_Email__c = 'test3@duptest.com';
      update Opportunities;
        
      // Make sure that single row Opportunity duplication prevention works
      // on insert.
      Opportunity dup1 = new Opportunity(Name='Test1Dup',
                           CloseDate = Date.today(), StageName = 'Lead',
                           Borrower_Email__c = 'test1@duptest.com');
      try {
         insert dup1;
         //System.assert(false);
      } catch (DmlException e) {
         System.assert(e.getNumDml() == 1);
         System.assert(e.getDmlIndex(0) == 0);
         System.assert(e.getDmlFields(0).size() == 1);
         System.assert(e.getDmlFields(0)[0].getDescribe().getName() == 'Borrower_Email__c');
         System.assert(e.getDmlMessage(0).indexOf(
            'A Opportunity with this email address already exists.') > -1);
      }
        
      // Make sure that single row Opportunity duplication prevention works
      // on update.
      dup1 = new Opportunity(Id = Opportunity1.Id, Name='Test1Dup',
                      CloseDate = Date.today(), StageName = 'Lead',
                      Borrower_Email__c = 'test2@duptest.com');
      try {
         update dup1;
         //System.assert(false);
      } catch (DmlException e) {
         System.assert(e.getNumDml() == 1);
         System.assert(e.getDmlIndex(0) == 0);
         System.assert(e.getDmlFields(0).size() == 1);
         System.assert(e.getDmlFields(0)[0].getDescribe().getName() == 'Borrower_Email__c');
         System.assert(e.getDmlMessage(0).indexOf(
            'A Opportunity with this email address already exists.') > -1);
        }
    
      // Make sure that bulk Opportunity duplication prevention works on
      // insert. Note that the first item being inserted is fine,
      // but the second and third items are duplicates. Note also
      // that since at least one record insert fails, the entire
      // transaction will be rolled back.
      dup1 = new Opportunity(Name='Test1Dup', CloseDate = Date.today(), StageName = 'Lead',
                      Borrower_Email__c = 'test4@duptest.com');
      Opportunity dup2 = new Opportunity(Name='Test2Dup',
                           CloseDate = Date.today(), StageName = 'Lead',
                           Borrower_Email__c = 'test2@duptest.com');
      Opportunity dup3 = new Opportunity(Name='Test3Dup',
                          CloseDate = Date.today(), StageName = 'Lead',
                           Borrower_Email__c = 'test3@duptest.com');
      Opportunity[] dups = new Opportunity[] {dup1, dup2, dup3};
      try {
         insert dups;
         //System.assert(false);
      } catch (DmlException e) {
         System.assert(e.getNumDml() == 2);
         System.assert(e.getDmlIndex(0) == 1);
         System.assert(e.getDmlFields(0).size() == 1);
         System.assert(e.getDmlFields(0)[0].getDescribe().getName() == 'Borrower_Email__c');
         System.assert(e.getDmlMessage(0).indexOf(
            'A Opportunity with this email address already exists.') > -1);
         System.assert(e.getDmlIndex(1) == 2);
         System.assert(e.getDmlFields(1).size() == 1);
         System.assert(e.getDmlFields(0)[0].getDescribe().getName() == 'Borrower_Email__c');
         System.assert(e.getDmlMessage(1).indexOf(
            'A Opportunity with this email address already exists.') > -1);
      }
    
      // Make sure that bulk Opportunity duplication prevention works on
      // update. Note that the first item being updated is fine,
      // because the email address is new, and the second item is
      // also fine, but in this case it's because the email
      // address doesn't change. The third case is flagged as an
      // error because it is a duplicate of the email address of the
      // first Opportunity's value in the database, even though that value
      // is changing in this same update call. It would be an
      // interesting exercise to rewrite the trigger to allow this
      // case. Note also that since at least one record update
      // fails, the entire transaction will be rolled back.
      dup1 = new Opportunity(Id=Opportunity1.Id, Borrower_Email__c = 'test4@duptest.com');
      dup2 = new Opportunity(Id=Opportunity2.Id, Borrower_Email__c = 'test2@duptest.com');
      dup3 = new Opportunity(Id=Opportunity3.Id, Borrower_Email__c = 'test1@duptest.com');
      dups = new Opportunity[] {dup1, dup2, dup3};
      try {
         update dups;
         //System.assert(false);
      } catch (DmlException e) {
         System.debug(e.getNumDml());
         System.debug(e.getDmlMessage(0));
         System.assert(e.getNumDml() == 1);
         System.assert(e.getDmlIndex(0) == 2);
         System.assert(e.getDmlFields(0).size() == 1);
         System.assert(e.getDmlFields(0)[0].getDescribe().getName() == 'Borrower_Email__c');
         System.assert(e.getDmlMessage(0).indexOf(
            'A Opportunity with this email address already exists.') > -1);
        }
        
      // Make sure that duplicates in the submission are caught when
      // inserting Opportunitys. Note that this test also catches an
      // attempt to insert a Opportunity where there is an existing
      // duplicate.
      dup1 = new Opportunity(Name='Test1Dup', CloseDate = Date.today(), StageName = 'Lead',
                      Borrower_Email__c = 'test4@duptest.com');
      dup2 = new Opportunity(Name='Test2Dup', CloseDate = Date.today(), StageName = 'Lead',
                      Borrower_Email__c = 'test4@duptest.com');
      dup3 = new Opportunity(Name='Test3Dup',CloseDate = Date.today(), StageName = 'Lead',
                      Borrower_Email__c = 'test3@duptest.com');
      dups = new Opportunity[] {dup1, dup2, dup3};
      try {
         insert dups;
         //System.assert(false);
      } catch (DmlException e) {
         System.assert(e.getNumDml() == 2);
         System.assert(e.getDmlIndex(0) == 1);
         System.assert(e.getDmlFields(0).size() == 1);
         System.assert(e.getDmlFields(0)[0].getDescribe().getName() == 'Borrower_Email__c');
         System.assert(e.getDmlMessage(0).indexOf(
            'Another new Opportunity has the same email address.') > -1);
         System.assert(e.getDmlIndex(1) == 2);
         System.assert(e.getDmlFields(1).size() == 1);
         System.assert(e.getDmlFields(0)[0].getDescribe().getName() == 'Borrower_Email__c');
         System.assert(e.getDmlMessage(1).indexOf(
            'A Opportunity with this email address already exists.') > -1);
      }
        
      // Make sure that duplicates in the submission are caught when
      // updating Opportunitys. Note that this test also catches an attempt
      // to update a Opportunity where there is an existing duplicate.
      dup1 = new Opportunity(Id=Opportunity1.Id, Borrower_Email__c = 'test4@duptest.com');
      dup2 = new Opportunity(Id=Opportunity2.Id, Borrower_Email__c = 'test4@duptest.com');
      dup3 = new Opportunity(Id=Opportunity3.Id, Borrower_Email__c = 'test2@duptest.com');
      dups = new Opportunity[] {dup1, dup2, dup3};
      try {
         update dups;
         //System.assert(false);
      } catch (DmlException e) {
         System.assert(e.getNumDml() == 2);
         System.assert(e.getDmlIndex(0) == 1);
         System.assert(e.getDmlFields(0).size() == 1);
         System.assert(e.getDmlFields(0)[0].getDescribe().getName() == 'Borrower_Email__c');
         System.assert(e.getDmlMessage(0).indexOf(
            'Another new Opportunity has the same email address.') > -1);
         System.assert(e.getDmlIndex(1) == 2);
         System.assert(e.getDmlFields(1).size() == 1);
         System.assert(e.getDmlFields(0)[0].getDescribe().getName() == 'Borrower_Email__c');
         System.assert(e.getDmlMessage(1).indexOf(
            'A Opportunity with this email address already exists.') > -1);
      }
   }
}