trigger CheckOpportunityDuplicates on Opportunity (before insert) {

	 

	    // This will check for duplicate Opportunity Names

	    // and update both

	    // This is pseudo-code, please verify while implementing!

	     

	    if(trigger.isBefore && trigger.isInsert) {

	         

	        // Create Empty List of Existing Opportunities to DML at the end

	        List<Opportunity> lstOppsToUpdate = new List<Opportunity>();

	         

	        // Get set of Opportunity Names

	        Set<String> setOpportunityNames = new Set<String>();

	        for(Opportunity o : trigger.new) {

	            setOpportunityNames.add(o.Name);

	        }

	         

	        // Query Opportunity Object for name matches

	        List<Opportunity> lstExistingOpportunities = [SELECT Id, Name, TargetField__c FROM Opportunity WHERE Name IN :setOpportunityNames];

	         

	        // Loop through triggered records

	        for(Opportunity oNew : trigger.new) {

	            for(Opportunity oExisting : lstExistingOpportunities) {

	                if(oNew.Name == oExisting.Name) {

	                    oNew.Duplicate_Status__c = 'Existing Opp';

	                    oExisting.Duplicate_Status__c = 'New Opp';

	                     

	                    // Add Existing Opp to list to update

	                    lstOppsToUpdate.add(oExisting);

	                }

	            }

	        }

	         

	        // Update existing Opportunities

	        if(lstOppsToUpdate.size() > 0) { update lstOppsToUpdate; }

	         

	    }

	 

	}