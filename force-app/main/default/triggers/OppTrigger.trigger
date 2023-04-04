trigger OppTrigger on Opportunity (before insert, before update, before delete, after insert,
                                   after update, after delete, after undelete) {
                                       
                                                                      
 //   gatilhos com uma caixa de seleção liga/desliga universal. Ao utilizar esta caixa de seleção, 
 //   podemos ativar/desativar todos os gatilhos com um clique. 
 //   É útil porque os gatilhos geralmente precisam ser desativados durante o carregamento de dados.
 if (Org_liga_desliga_trriger__mdt.getInstance('Run_All_Triggers')?.Value__c == true) {
        TriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                // handler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                 handler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                 handler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                 handler.afterInsert(Trigger.new, Trigger.newMap);   
          
            }
            when AFTER_UPDATE {
                 handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                 //handler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                // handler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
 }
                                  
}