public class CLDY_AgreementAutoActivate {
    public static string AGMT_STATUS_FULLY_SIGNED = 'Fully Signed';
    public static string AGMT_SIGNED_DOC_KEY = 'signed';
    public static string sObjectName = 'Apttus__APTS_Agreement__c';
    public pagereference onload(){
        try{
            String agreementId = system.currentPageReference().getParameters().get('id');
            string attachmentRecId = '';
            
            List<Apttus__APTS_Agreement__c> fullysignedAgreements = [Select Id, 
                                                                                Apttus__Status__c 
                                                                                from 
                                                                                Apttus__APTS_Agreement__c 
                                                                                where Id =: agreementId]; 
            List<Attachment> attachmentList = [Select Id, Name from Attachment Where ParentId =: agreementId];
            for(Attachment attachmentRec : attachmentList){
                String attName = null;
                attName = attachmentRec.Name.toLowerCase();
                if((attName).contains(AGMT_SIGNED_DOC_KEY)){
                    attachmentRecId = attachmentRec.Id;
                }
            }
            
            /**String comments='';
            List<Review_Fields_Settings__c> reviewList= [select id,Name,Field_API_Name__c from Review_Fields_Settings__c];
            List<Apttus__APTS_Agreement__c> fullysignedAgreements= new List<Apttus__APTS_Agreement__c>();
            DescribeSObjectResult objectfields = Apttus__APTS_Agreement__c.getSObjectType().getDescribe();     
	        List<String> fieldNames = new List<String>( objectfields.fields.getMap().keySet() );
	        String query = ' SELECT ' +String.join( fieldNames, ',' ) +' FROM Apttus__APTS_Agreement__c where Id =: agreementId';
            
            fullysignedAgreements = Database.query(query);
           /* List<Apttus__APTS_Agreement__c> fullysignedAgreements = [Select Id, 
                                                                                Apttus__Status__c 
                                                                                from 
                                                                                Apttus__APTS_Agreement__c 
                                                                                where Id =: agreementId]; */
            /**for(Apttus__APTS_Agreement__c agrrec: fullysignedAgreements){
            	system.debug(agrrec.Apttus__Termination_Notice_Days__c+'&&&&&&&&&&&&');
            	for(Review_Fields_Settings__c rewrec : reviewList){
            		//system.debug(rewrec.Field_API_Name__c+'&&&&&&&&&&&&'+(String)agrrec.get(rewrec.Field_API_Name__c));
            		//system.debug(rewrec.Field_API_Name__c+'&&&&&&&&&&&&'+(String)agrrec.get('Apttus__Termination_Notice_Days__c'));
            		if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'STRING' && ((String)agrrec.get(rewrec.Field_API_Name__c) == null || (String)agrrec.get(rewrec.Field_API_Name__c) == '')){
            			if(comments == '' || comments == null){
            				comments = rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			} 
            			system.debug(rewrec.Field_API_Name__c+'&&&&&String&&&&&&&');           			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'DATETIME' && agrrec.get(rewrec.Field_API_Name__c) == null){
            			if(comments == '' || comments == null){
            				comments = rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			} 
            			system.debug(rewrec.Field_API_Name__c+'&&&&&DateTime&&&&&&&');            			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'DATE' && agrrec.get(rewrec.Field_API_Name__c) == null){
            		    if(comments == '' || comments == null){
            				comments = rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments=comments+',\n'+rewrec.Field_API_Name__c;            				
            			}
            			system.debug(rewrec.Field_API_Name__c+'&&&&&Date&&&&&&&');             			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'BOOLEAN' && agrrec.get(rewrec.Field_API_Name__c)==false){
            			if(comments =='' || comments == null){
            				comments = rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			}
            			system.debug(rewrec.Field_API_Name__c+'&&&&&Boolean&&&&&&&');             			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'DOUBLE' && agrrec.get(rewrec.Field_API_Name__c) == null){
            			if(comments == '' || comments == null){
            				comments = rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			}
            			system.debug(rewrec.Field_API_Name__c+'&&&&&Double&&&&&&&');             			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'PERCENT' && agrrec.get(rewrec.Field_API_Name__c) == null){
            			if(comments =='' || comments == null){
            				comments=rewrec.Field_API_Name__c;
            			} else{
            				comments=comments+',\n'+rewrec.Field_API_Name__c;            				
            			}
            			system.debug(rewrec.Field_API_Name__c+'&&&&&Pecentage&&&&&&&');             			
            		}
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c)=='PICKLIST' && (agrrec.get(rewrec.Field_API_Name__c) == null || agrrec.get(rewrec.Field_API_Name__c) == '')){
            			if(comments == '' || comments == null){
            				comments = rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			}  
            			system.debug(rewrec.Field_API_Name__c+'&&&&&Picklist&&&&&&&');           			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'TEXTAREA' && (agrrec.get(rewrec.Field_API_Name__c) == null || agrrec.get(rewrec.Field_API_Name__c) == '')){
            			if(comments == '' || comments == null){
            				comments = rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			}   
            			system.debug(rewrec.Field_API_Name__c+'&&&&&Textarea&&&&&&&');          			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'CURRENCY' && agrrec.get(rewrec.Field_API_Name__c) == null){
            			if(comments == '' || comments == null){
            				comments = rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			}  
            			system.debug(rewrec.Field_API_Name__c+'&&&&&Currency&&&&&&&');           			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'EMAIL' && (agrrec.get(rewrec.Field_API_Name__c) == null || agrrec.get(rewrec.Field_API_Name__c) == '')){
            			if(comments == '' || comments == null){
            				comments = rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			} 
            			system.debug(rewrec.Field_API_Name__c+'&&&&&Email&&&&&&&');            			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'URL' && (agrrec.get(rewrec.Field_API_Name__c) == null || agrrec.get(rewrec.Field_API_Name__c) == '')){
            			if(comments == '' || comments == null){
            				comments=rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			}  
            			system.debug(rewrec.Field_API_Name__c+'&&&&&URL&&&&&&&');           			
            		} 
            		else if(CLDY_AgreementAutoActivate.getFieldType(rewrec.Field_API_Name__c) == 'REFERENCE' && agrrec.get(rewrec.Field_API_Name__c) == null){
            		    if(comments == '' || comments == null){
            				comments=rewrec.Field_API_Name__c;
            			} 
            			else{
            				comments = comments + ',\n' + rewrec.Field_API_Name__c;            				
            			}  
            			system.debug(rewrec.Field_API_Name__c+'&&&&&URL&&&&&&&');           			
            		}
            	}
            }
            List<Task> t_list = new List<Task>(); 
            system.debug('&&&&&&&&&&&&'+comments);
            if(comments != null && comments !=''){
            	comments = 'Please Fill Below Fields in Agreement Record  \n\n'+comments;
                Task tskrec = new Task();
                tskrec.subject='Please review the Record';
                tskrec.Description = comments;
                tskrec.status = 'Open';
                tskrec.Priority = 'Normal';
                tskrec.ActivityDate = system.today();
                tskrec.OwnerId = UserInfo.getUserId();
                tskrec.whatid = agreementId;
                t_list.add(tskrec);
            }**/
            
            if(fullysignedAgreements.size() > 0){
                if(fullysignedAgreements[0].Apttus__Status__c == AGMT_STATUS_FULLY_SIGNED){
            	    //system.debug('&&&&&&&&&&&&'+t_list);
                    //if(t_list.size()>0){ 
        				//insert t_list;
                    //} 
                    //system.debug('&&&&&&after&&&&&&'+t_list);
                    List<Id> selectedDocIds = new List<Id> ();
                    List<Id> removableDocIds = new List<Id> ();
                    if(attachmentRecId != ''){
                        List<Attachment> attachmentLst = [Select Id, ParentId, Body, Name, ContentType from Attachment Where Id =: attachmentRecId];
                        selectedDocIds.add(attachmentRecId);                        
                        if(!Test.isRunningTest()){
                            Boolean res = Apttus.AgreementWebService.activateAgreement(fullysignedAgreements[0].Id, selectedDocIds, removableDocIds);
                            if(res){
                                Boolean publishRes = Apttus.AgreementWebService.publishToDocumentRepository(fullysignedAgreements[0].Id, attachmentRecId);
                                if(!publishRes){
                                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Publishing documents to chatter failed');
                                    ApexPages.addMessage(myMsg);
                                    return null;
                                }
                                else{
                                    if(attachmentLst.size() > 0){
                                        Attachment attachmentRec = new Attachment();
                                        attachmentRec.Name = attachmentLst[0].Name;
                                        attachmentRec.Body = attachmentLst[0].Body;
                                        attachmentRec.ContentType = attachmentLst[0].ContentType;
                                        attachmentRec.ParentId = fullysignedAgreements[0].Id;
                                        insert attachmentRec;
                                    }
                                    
                                }
                                pagereference agreementPage = new pagereference('/' + fullysignedAgreements[0].Id);
                                agreementPage.setRedirect(true);
                                return agreementPage;
                            }
                            else{
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Agreement Activation failed');
                                ApexPages.addMessage(myMsg);
                                return null;
                            }
                        }
                        else{
                            pagereference agreementPage = new pagereference('/' + fullysignedAgreements[0].Id);
                            agreementPage.setRedirect(true);
                            return agreementPage;
                        }
                    }
                    else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find fully signed Document for the Agreement.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
                else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Agreement is not fully SIGNED.');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Agreement is not fully SIGNED.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        catch(Exception exp){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exp + '');
            ApexPages.addMessage(myMsg);
            return null;
        }
        return null;
    }
    
    public pagereference goToAgreement(){
        String agreementId = system.currentPageReference().getParameters().get('id');
        pagereference agreementPage = new pagereference('/' + agreementId);
        agreementPage.setRedirect(true);
        return agreementPage;
    }
    
    /**public static String getFieldType(String fieldName){
		Schema.SObjectType sojt = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c'); 
		Schema.DescribeSObjectResult sojtresult= sojt.getDescribe();
		Schema.DescribeFieldResult fdresult = sojtresult.fields.getMap().get(fieldName).getDescribe();		
		return String.valueof(fdresult.getType());
	}**/
}