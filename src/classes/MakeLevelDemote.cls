public class MakeLevelDemote {
    public MakeLevelDemote(ApexPages.StandardController stdController) {
    }
    
  	// Code we will invoke on page load.
    public PageReference demote() {
        String levelMemberId = ApexPages.currentPage().getParameters().get('id');
        FieloPLT__LevelMember__c currentLevelMember = [SELECT 
                                                       	Id, 
                                                       	FieloPLT__Member__c, 
                                                       	FieloPLT__Member__r.FieloPLT__Program__r.FieloPLT__LevelAttainmentPeriod__c,
                                                       	FieloPLT__Member__r.FieloPLT__Program__r.FieloPLT__LevelAttainmentPeriodType__c,
                                                       	FieloPLT__Level__c,
                                                       	FieloPLT__Async__c,
                                                       	FieloPLT__ChallengeMember__c,
                                                       	FieloPLT__RankExpirationDate__c,
                                                       	FieloPLT__Expired__c,
                                                       	FieloPLT__Processed__c,
                                                       	FieloPLT__PromoteSummary__c,
                                                       	FieloPLT__RankExpirationDateKey__c
                                                       FROM FieloPLT__LevelMember__c 
                                                       WHERE Id =: levelMemberId];
        
        Date newCreationDate = Date.today().addDays(-1);
        Integer levelAttainmentPeriod = currentLevelMember.FieloPLT__Member__r.FieloPLT__Program__r.FieloPLT__LevelAttainmentPeriod__c.intValue() * -1;
        switch on currentLevelMember.FieloPLT__Member__r.FieloPLT__Program__r.FieloPLT__LevelAttainmentPeriodType__c{
            when 'Days'{
                newCreationDate = newCreationDate.addDays(levelAttainmentPeriod);
            }
            when 'Months'{
                newCreationDate = newCreationDate.addMonths(levelAttainmentPeriod);
            }
            when 'Years'{
                newCreationDate = newCreationDate.addYears(levelAttainmentPeriod);
            }
        }
        
        FieloPLT__LevelMember__c newLevelMember = currentLevelMember.clone();
        newLevelMember.CreatedDate = newCreationDate;
        insert newLevelMember;
        
        FieloPLT__Member__c member = new FieloPLT__Member__c();
        member.Id = currentLevelMember.FieloPLT__Member__c;
        member.FieloPLT__CurrentLevelMember__c = newLevelMember.Id;
        FieloPLT.SObjectService.enableAdminPermission(true);
        update member;
        FieloPLT.SObjectService.enableAdminPermission(false);
        
        delete currentLevelMember;
       
        List<FieloPLT__MemberMilestoneItem__c> mmis = [SELECT Id FROM FieloPLT__MemberMilestoneItem__c WHERE FieloPLT__MemberMilestone__r.FieloPLT__Member__c = :currentLevelMember.FieloPLT__Member__c];
        for(FieloPLT__MemberMilestoneItem__c mmi : mmis){
            mmi.FieloPLT__Date__c = newCreationDate;
        }
        
        update mmis;

        // Redirect the user to the newly created LevelMember
        PageReference pageRef = new PageReference('/' + newLevelMember.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}
