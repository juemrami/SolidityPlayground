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
    enum LobbyState { Open, Closed, Ended}
    LobbyState public currentState;
    address admin;
    address payable[] players;
    address winner;
    address loser;
    uint rollResultCount;
    uint rollSize;
    uint fee = 0.005 ether;
    uint payout;

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
    }
    function startGame() internal{
        require(msg.sender == admin, "Only the host may start the game");
        currentState = LobbyState.Closed;
        //generate rolls 
    }
    function roll() external{
        require(currentState == LobbyState.Closed, "The Lobby is not Rolling Yet");
        require(isRegistered[msg.sender], "This address is not a part of this lobby");
        require(!blacklist[msg.sender],"Already Rolled");
        playerRoll[address(msg.sender)] = uint(random() % rollSize +1);
        blacklist[msg.sender] = true ;
        rollResultCount++;
        endGame();
    }

    function endGame() internal{
        require(rollResultCount == players.length);
        winner = getWinner();
        loser = getLoser();
        payout = uint(playerRoll[winner]- playerRoll[loser]);
    }
    function collect() external {
        
    }
    function transfer(address payable _to, uint _amount) internal{
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
    function random() internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,players.length)));   
    }
    function playerCount()view external returns(uint8){
        return uint8(players.length);
    }
     receive() external payable{
        buyIn();    
    }
}
