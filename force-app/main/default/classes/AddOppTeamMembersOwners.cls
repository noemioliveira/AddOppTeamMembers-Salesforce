public class AddOppTeamMembersOwners {
    
    public static void  assignOpportunities(List<Opportunity> newOpportunities) {
        //Lista de consiltores tima A
        List<Id> teamAConsultants = new List<Id>();
         //Lista de consiltores tima A
        List<Id> teamBConsultants = new List<Id>();
        
         //SOSL query TeamMemberRole  da org quando esta configurado o time dentro de cada usuário
        List<UserTeamMember> teamMemberRole = [SELECT Id, TeamMemberRole, UserId FROM UserTeamMember];
         //SOSL query  cada opportunidade cria uma regisstro nesse objeto OpportunityTeamMember 
         //se não tem time a  role sera opp Owner essa  opp que ficaram em espera caso o consultor tenha  mais de 2  opps
         // caso a opp seja fechada a ideia é fazer um código para excluir esse regitro liberando o consultor.
        List<OpportunityTeamMember> listOpt= [SELECT UserId FROM OpportunityTeamMember  ] ;
       
        //Se  listOpt  não estiver  null 
        if(!listOpt.isEmpty()){  
        
        //Intera sobre a lista teamMemberRole   
        for (UserTeamMember tm : teamMemberRole) {
             System.debug('tm '+tm); 
          //Intera sobre a lista AggregateResult  a qual faz uma contagem(COUNT(id)) de quantas opp 
          //tem assinado para cada consultor(UserId)  
          //Se a opp não estivet fechada e agrupa por id   
          for(AggregateResult teamMemberCount:[SELECT COUNT(id) countId,UserId FROM OpportunityTeamMember
                      WHERE  Opportunity.IsClosed = false  GROUP BY UserId  ORDER BY Count(ID) DESC  ] ){
                System.debug('teamMemberCount '+teamMemberCount); 
             //Popula a a variavel contadorTM com a quantidade de opp para o consultor                
             Integer contadorTM = (Integer) teamMemberCount.get('countId');  
             //Popula a a variavel userIdTM com  o ID do  consultor               
             Id userIdTM = (Id)teamMemberCount.get('UserId');   
               //Se o id estiver preenchido e  contador de opp menor que 2
              if(userIdTM != null  && contadorTM < 2){
                System.debug('userIdTM != null && tm.id.equals(userIdTM) && contadorTM < 2');  
                 //Se o TeamMemberRole  for igual Time A. Popula a lista de consultor A teamAConsultants
                if (tm.TeamMemberRole == 'Time A') {
                   teamAConsultants.add(tm.UserId);
                  //Se o TeamMemberRole  for igual Time B.. Popula a lista de consultor B  teamBConsultants
                 } else if (tm.TeamMemberRole == 'Time B') {
                   teamBConsultants.add(tm.UserId);
                 }   
              }
          } 
         }
        // Se teamBConsultants   na primeira que for criado opp.
        }Else if(teamBConsultants == null){
           //Intera sobre a lista teamMemberRole    
           for (UserTeamMember tm : teamMemberRole) {
            System.debug('teamMemberRole '); 
            //Se o TeamMemberRole  for igual Time A. Popula a lista de consultor A teamAConsultants    
            if (tm.TeamMemberRole == 'Time A') {
                teamAConsultants.add(tm.UserId);
              //Se o TeamMemberRole  for igual Time B. Popula a lista de consultor B teamBConsultants
            } else if (tm.TeamMemberRole == 'Time B') {
                teamBConsultants.add(tm.UserId);
            }
           } 
        }
        
        // lista criada para p Upsert
        List<OpportunityTeamMember> oppTeamMembersToUpdate = new List<OpportunityTeamMember>();
        
         Set<Id> idselectedConsultant = new   Set<Id>();
         // Itera sobre a lista de opp enviadas ma trigger after insert update
        for (Opportunity opp : newOpportunities) {
            // Se a opp não estiver fechada
            if (!opp.IsClosed) {
                //List<Id> targetConsultants = opp.Amount < 10000 ? teamAConsultants : teamBConsultants;
                Id selectedConsultant;
                // Se teamAConsultants estiver preenchido e a opp menor que 10mil e opp estiver aberta vai para o time A
                if(!teamAConsultants.isEmpty() && opp.Amount < 10000 && opp.IsClosed == false ){
                    System.debug('time A' + teamAConsultants);
                    selectedConsultant= findAvailableConsultant(teamAConsultants);
                    idselectedConsultant.add(selectedConsultant);
                      //chama o metodo de trocar o consultor 
                 // Se teamAConsultants estiver preenchido e a opp igual ou maior que 10mil e opp estiver aberta vai para o time B    
                } else if(!teamBConsultants.isEmpty() && opp.Amount >= 10000 && opp.IsClosed == false){
                    System.debug('time B' + teamBConsultants);
                    //chama o metodo de trocar o consultor 
                    selectedConsultant= findAvailableConsultant(teamBConsultants);
                    idselectedConsultant.add(selectedConsultant);
                }
               
                System.debug('selectedConsultant LINHA 32' + selectedConsultant);
                //Se selectedConsultant  não nullo
                if (selectedConsultant != null) {
                    // popula os campos de OpportunityTeamMember  para o upsert
                    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
                        OpportunityId = opp.Id,
                        UserId = selectedConsultant,
                        TeamMemberRole = opp.Amount < 10000 ? 'Time A' : 'Time B'
                    );
                    oppTeamMembersToUpdate.add(oppTeamMember);
                }
                //fazer o update em OpportunityTeamMember não é possivel, pois o campo não  permitido no update
                // no campo UserId  po essa razão só é  feito a assinatura um novo registro de OpportunityTeamMember da mesma opp
                /*else if(selectedConsultant == null){
                    for(OpportunityTeamMember oppTM:[Select id, userId from OpportunityTeamMember 
                          where UserId in: idselectedConsultant ]){
                          opptM.UserId = selectedConsultant;
                          opptM.TeamMemberRole = opp.Amount < 10000 ? 'Time A' : 'Time B'  ;  
                    } 
               }*/
            }
        }
        //verifica se a lista esta  diferente de null
        if (!oppTeamMembersToUpdate.isEmpty()) {
             //upsert/insert( somente possivel)  lista oppTeamMembersToUpdate
            upsert oppTeamMembersToUpdate;
        }
        //necessário criar o metodo de delete para opp com isClose== true( opp fechada) para liberar o consultor
    }

    // metodo para  encontrar um consultor livre
    private static Id findAvailableConsultant(List<Id> consultantIds) {
        Id availableConsultant = null;
        List<id> idTTeamMember= new List<id>();

      
          IF(!consultantIds.isEmpty()){ 
            integer countId;   
            System.debug('ELSE consultantIds: '+consultantIds); 
              
            //  itera na lista de UserTeamMember  enviada  no id consultantIds
            For(UserTeamMember uTM:[Select UserId from UserTeamMember 
                                            where UserId in:consultantIds  ]){  
                  //pega id de consultor disponivel                              
                 availableConsultant = uTM.UserId;
                                                 
            }  
                                                
           } 
        
        //if(consultantIds.contains(activeOpportunityCount))
        
        return availableConsultant;
    }
}