//SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.0;

contract Lottery{
    address payable[] public players;
    address payable public admin;

    mapping(address => bool) isAddressEntered;
    //msg.sender is the public key or address of the person
    //that deployed or called the contract
    constructor(){
        //literal is only assigned when the contract is first deployed
        //admin is the depoloyer
        admin = payable(msg.sender);
    }

    //this is a receive ether function
    //when this function is revealed it allows
    //the smart contract to recieve payments
    receive() external payable{
        require(!isAddressEntered[msg.sender], "Only 1 Entry per Person");
        require (msg.value == 1 ether, "The Fee is exactly 1 (one) ether, no more no less");
        isAddressEntered[msg.sender] = true;
    }

    function getBalance() public view returns (uint256){
        // the (this) is used to refer to the instance of the contract
        //the contract has a global variable of balance 
        return address(this).balance;
    }

    function random() internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,players.length)));   
    }

    function pickWinner() public {
        require(admin == msg.sender, "Only admin may call PickWinner()");
        require(players.length <= 3, "Not Enough players in the lottery");
        address payable winner;
        //developer cut xD
        admin.transfer(1000 gwei);

        winner = players[random() % players.length];
        
        winner.transfer(getBalance());

        //reset the players address array for a new game 
        players = new address payable[](0);

        


    }
}