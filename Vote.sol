pragma solidity ^0.4.0;

// Vote de lois proposés par un président (pour ou contre)

contract Vote {
	address public chairperson; // Propriétaire de la proposition

	mapping (address => bool) public citizens; 	// Citoyens participants

	struct Proposal {
		string description;
		mapping (address => bool) voted; // Votants
		bool[] votes;           
		bool accepted;       //proposition acceptée, true or false
		uint voteCount;      
		uint end;
	}

	Proposal[] proposals; // Tableau de propositions

	
    modifier Onlychairp(){
        if (msg.sender != chairperson) throw; // On rejete toute personne n'étant pas présidente du vote
        _;
    }

   modifier Onlycitizens(){
        if (!citizens[msg.sender]) throw;  // On rejete toute personne n'étant pas citoyenne
        _;
    }
    
    // gestion des votants (si un votant pas voté)
    modifier NoVote(uint index) {
        if(proposals[index].voted[msg.sender]) throw;
        _;
    }

   //Gestion de l'ouverture du vote
    modifier isOpen(uint index) {
        if(now > proposals[index].end) throw;
        _;
    }

    //Gestion de la fermeture du vote
    modifier isClosed(uint index) {
        if(now < proposals[index].end) throw;
        _;
    }
    
    
    // Envoi des résultats du vote
    event Results(address from, bytes32 msg);

	

	// Ajout des citoyens participants au vote 
    function addvotant(address newvotant) Onlychairp() {
        citizens[newvotant] = true;
    }

    // Ajouter une proposition seulement par le propriétaire (celui qui a déployé le contrat)
    function addProposal(string description) Onlychairp() constant returns (uint end){
        uint numproposal = proposals.length++;
       
        Proposal p = proposals[numproposal];
        
        // Description de la proposition
        p.description = description;
        
        // Temps de votes en minutes
        p.end = now + 1 minutes;
        end=p.end;
    }

    // fonction de vote pour la proposition
    function vote(uint index, bool vote) Onlycitizens() isOpen(index) NoVote(index) {
        proposals[index].votes.push(vote);
        proposals[index].voted[msg.sender] = true;
    }

    // Résultat d'une proposition
    function ResultProposal(uint index) constant returns (bytes32 results){
        uint no;
        uint yes;
        bool[] votes = proposals[index].votes;

        // On compte les pour et les contre
        for(uint count = 0; count < votes.length; count++) {
            if(votes[count]) {
                yes++;
            } else {
                no++;
            }
        }
            if(yes > no) {
                proposals[index].accepted = true; 
                Results(msg.sender,"Proposition acceptée");
                results="Pour";
            }
            else{
                Results(msg.sender,"Proposition non acceptée");
                results="Contre";
            }
    }
    
    // Function kill
    function kill() Onlychairp() {
        suicide(msg.sender);
	}
}