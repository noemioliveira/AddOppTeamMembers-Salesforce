// Trigger com  padronizado exemplo  retirado do SalesforceBen
// abaixo estamos  implementando a assinaturas do métodos da  a interface TriggerHandler
public without sharing class OpportunityTriggerHandler implements TriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;

    
    public OpportunityTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
    }
    public void beforeInsert(List<Opportunity> newOpportunities) {
        
       // todos metodos  com logica de negócio que são antes do Insert devem ser chamado  aqui neste bloco de codigo/método beforeInsert
    }
    public void beforeUpdate(List<Opportunity> oldOpportunity, List<Opportunity> newOpportunity, Map<ID, SObject> oldOpportunityMap, Map<ID, SObject> newOpportunityMap) {
       //add new  metodo para  atualizar as  opp;
    }
    public void beforeDelete(List<Opportunity> oldOpportunity, Map<ID, SObject> oldOpportunityMap) {
      // todos metodos  com logica de negócio que são antes do delete devem ser chamado  aqui neste bloco de codigo/método beforeDelete
    }
    public void afterInsert(List<Opportunity> newOpportunity, Map<ID, SObject> newOpportunityMap) {
         // passamos a lista newOpportunity apos a operação DML de Insert
         // todos metodos  com logica de negócio que são apos o insert devem ser chamado  aqui neste bloco de codigo/método afterInsert
         AddOppTeamMembersOwners.assignOpportunities(newOpportunity);
       
    }
    public void afterUpdate(List<Opportunity> oldOpportunity, List<Opportunity> newOpportunity, Map<ID, SObject> oldOpportunityMap, Map<ID, SObject> newOpportunityMap) {
      
       AddOppTeamMembersOwners.assignOpportunities(newOpportunity);
    }
    public void afterDelete(List<Opportunity> oldOpportunity, Map<ID, SObject> oldOpportunityMap) {
        //Não é possivel deletar um OpportunityTeamMeber associado a uma divisão precisa ser revisto a Divisão
        // todos metodos  com logica de negócio que são apos o Delete devem sem chamado  aqui neste bloco de codigo/método afterDelete
    }
    public void afterUndelete(List<Opportunity> newOpportunity, Map<ID, SObject> newOpportunitytMap) {
        // todos metodos  com logica de negócio que são apos o Undelete devem sem chamado  aqui neste bloco de codigo/método afterUndelete
    }
}