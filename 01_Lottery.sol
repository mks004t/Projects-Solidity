//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lottery{
    address public manager;
    address payable [] public participants; // array of participents

    constructor(){
        manager=msg.sender;  // msg.sender is globle variable
    }
    
/**
* Modifier 
* @onlymanager have the access
* @recevAmount ensure that the entry fee is 2 ether.
*/ 
    modifier onlymanager(){
        require(msg.sender==manager, "Caller is not manager ");
        _;
    }

    modifier recevAmount(){
        require(msg.value==2 ether, "Lottery fee is 2 Ether");
        _;
    }

    // 
    receive() external payable recevAmount{
        participants.push( payable(msg.sender) );
    }

// get balance function every one have the access
    function getBalance() public view returns (uint balance)
    {
        return address(this).balance;
    }

    function random() public view returns(uint randomNo){
       return uint(keccak256(abi.encodePacked( block.difficulty, block.timestamp,participants.length)));
    }

// ether will be send to Winner 
    function selectWinner() public  onlymanager returns (address Winner){
        uint randomNo= random();
        uint index = randomNo % participants.length;

        address payable winner = participants[index-1];

        winner.transfer(getBalance());
        participants=new address payable[](0);  // used to create a array of size 0 / redefining array;
        return winner;
    }
    
}


// receive function is a special function cannot accept variable and must be external and payable;
//  Syntex : receive () external payable{}

// Randum functionis a buildin function i.e keccak256, uint() is type cast,
// Please Dont use this random function in actual development