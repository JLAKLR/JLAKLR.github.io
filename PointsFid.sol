pragma solidity ^0.4.0;

//Points de fidélité distribués par une société à ses clients

contract FPoints {
    
    
    address public business; //société qui distribue les points
    
    mapping(address => Client) clients;  //clients autorisés à recevoir des points
    
    mapping (address => uint256) public balances;
    
    struct Client{
        uint FPoints;
    }
    
    uint256 public iPoints; //Initilisation des points de fidélités
    
     
    modifier OnlyBusiness(){
        if (msg.sender != business) throw;  // On rejete toute entité n'étant pas la société
        _;
    }
    
    
 // Pour modifier le nombre de points initiaux que la société possède
    function setiPoints(uint newPoints) OnlyBusiness() {
        iPoints = newPoints;
    }
    
//Pour obtenir le nombre de points initiaux à la société
    function balanceOf(address _business) constant returns (uint256 balance){
        balances[_business]=iPoints;
        balance=balances[_business];
    }
    
//Pour obtenir le nombre de points qu'un client possède
    function balanceOf2(address _business) constant returns (uint256 balance){
        balance = clients[_business].FPoints;
    }
    
//Donne à la société tous les points initiaux
    function IniFidPoints(uint iniPoints) {
        business=msg.sender;
        setiPoints(iniPoints);
        balanceOf(msg.sender);              
    }
    
// Envoi du transfert de points au client
    event Results(address from, bytes32 msg);
    
//Transfert de points
    function transfer(address to, uint256 amount) OnlyBusiness returns (bool success) {
        success=false;
        if (balanceOf2(msg.sender) < amount) throw;
        if (balanceOf2(to) + amount < balanceOf2(to)) throw;
        if(amount > 0){
        balances[msg.sender] -= amount;                     
        balances[to] += amount;
        Results(msg.sender,"Points transférés");
        success=true;
        }
    }
    
    
// Fonction kill
    function kill() OnlyBusiness() {
        suicide(msg.sender);
    }
    
    
}
