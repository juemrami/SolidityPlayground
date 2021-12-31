pragma solidity ^0.8.0;
contract MyContract {
    uint8 GPA = 3; 

    function get() public view returns (uint8) {
        return GPA;
    }
    function double() public{
        GPA *= 2;
    }
}