//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
//things for front end
// real time price of eth using chainlink
// ui represnting rolling period ' big roll button'
// chat for the players
// let 

//maybe make the contract a lobby, each contract deployed is a lobby

//Things i want to do
//1. Game needs 5-10 players (maybe less for dev purposes)
//2. Each game has a certain buy in (can i make this dynamic or do i need seperate contracts?)
//3. Once Game starts each user then receives an equally weighted chance to
//   to roll a number between 1 and the buy in ammount
//4. The Lowest number is subtracted from the Highest number.
//   the lowest number player then pays out the highest number player
//   the difference of the 2 numbers.
//5. Contract maker gets a cut xD


contract HiLoLobby {
    enum LobbyState { Open, Closed, Collections,Ended}
    LobbyState public currentState;
    address admin;
    address payable[] players;
    address winner;
    address loser;
    uint8 rollResultCount;
    uint rollSize;
    uint fee = 0.005 ether;
    uint winnerPayout;
    uint8 minPlayers = 2; 

    mapping(address => bool) isRegistered;
    mapping(address => uint256) playerRoll;
    mapping(address => bool) blacklist;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    
    constructor(uint _rollSize){
        admin = msg.sender;
        rollSize=_rollSize;
        rollResultCount = 0;
        currentState = LobbyState.Open;
    }
   
    //1 buy in per player
    function buyIn() public payable {
        require(currentState == LobbyState.Open, "The lobby is no longer open, please start a new one");
        require(msg.value == fee, "Please provide the correct buy in fee: 0.005 ether");
        require(!isRegistered[msg.sender], "Address is already registered. Only 1 entry per address allowed");
        require(address(msg.sender).balance >= fee, "Not enough funds" );
        isRegistered[msg.sender] = true;
        players.push(payable(msg.sender));
    }
    function startGame() external{
        require(msg.sender == admin, "Only the host may start the game");
        currentState = LobbyState.Closed;
        //generate rolls 
    }
    function roll() external{
        require(isRegistered[msg.sender], "This address is not a part of this lobby");
        require(currentState == LobbyState.Closed, "The Lobby is not open for rolling");
        require(!blacklist[msg.sender],"Already Rolled");
        playerRoll[address(msg.sender)] = uint(random() % rollSize +1);
        blacklist[msg.sender] = true ;
        rollResultCount++;
        if(rollResultCount == players.length){
            _endGame();
        }  
    }

    function _endGame() internal {
        getWinner();
        getLoser();
        winnerPayout = uint(playerRoll[winner]- playerRoll[loser]);
        assignPayouts();
        currentState = LobbyState.Collections;
    }

    function endGame() external {
        require(msg.sender == admin, "Only admim may end the game after all players roll");
        require(currentState == LobbyState.Closed,"The lobby Must be closed to end the game");
        require(rollResultCount == players.length, "Wait for all players for finish rolling");
        _endGame();
    }
    function collect() external {
        require(isRegistered[msg.sender], "This address is not a part of this lobby");
        require(currentState == LobbyState.Collections, "The Lobby is not open for collections yet");
        require(msg.sender != loser, "This address lost and will receive no payout");

    }
    function getWinner() internal{
        bool winnerTie;
        bool loserTie;
        for(uint8 i = 0; i < players.length; i++){
            if(i == 0){
                winner = players[i];
                loser = players[i];
                continue;
            }
            if(playerRoll[players[i]] >= playerRoll[winner]){
                if((playerRoll[players[i]] == playerRoll[winner])){
                    winnerTie == true;
                }else{
                    winnerTie == false;
                }
            }
            if(playerRoll[players[i]] <= playerRoll[loser]){
                if((playerRoll[players[i]] == playerRoll[loser])){
                    loserTie == true;
                }
                loserTie == false;    
            }
        }
    }
    function getLoser() internal{ 
    }
    function assignPayouts() internal{
        //maybe first assign winner payout,
        for(uint8 i = 0; i < players.length; i++){
            require(isRegistered[players[i]], "Could not assign payout, due to unregistered address");
            if(players[i]!=winner && players[i]!=loser){
                transfer(players[i], address(this).balance/(players.length - 2));
            }
        }
    }
    function transfer(address payable _to, uint _amount) internal{
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
    function random() internal view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,players.length)));   
    }
    function playerCount()view external returns(uint8){
        return uint8(players.length);
    }
    receive() external payable{
        buyIn();    
    }
}
