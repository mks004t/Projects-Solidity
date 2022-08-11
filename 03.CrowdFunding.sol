//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Crowdfunding{

    mapping (address => uint) public contributers;
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noofContributers;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noofVoters;
        mapping(address=> bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public requestNo;

    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline;  // blocktime + given time 
        minContribution = 10000 wei;
        manager=msg.sender;
    }

    modifier minContri(){
        require(msg.value >= minContribution, "Please send more than 10000 Wei");
        _;
    }
    modifier targetTime(){
        require(block.timestamp <= deadline, "The Time to Collect funds is over Now");
        _;
    } 

    function sendEther() public payable minContri targetTime{
          if(contributers[msg.sender]==0){
              noofContributers++;
          }
          contributers[msg.sender]+=msg.value;
          raisedAmount+=msg.value;
    }

    function getBalance() public view returns (uint){
        return address(this).balance;
    }

    function refund() public payable {
        require(block.timestamp> deadline && raisedAmount< target, "Amount not collected");
        require(contributers[msg.sender]>0);
        address payable user = payable(msg.sender);
        user.transfer(contributers[msg.sender]);
        contributers[msg.sender]=0;
        //delete(contributers[msg.sender]);
    }

    modifier onlyManager(){
        require(msg.sender== manager, "You are not a manager ");
        _;
    }

    function createRequest(string memory _description,address payable _recipient,uint _value ) public onlyManager{
        Request storage newRequest =requests[requestNo];
        requestNo++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noofVoters=0;
    }
    function voteRequest(uint _requestNo) public{
        require(contributers[msg.sender]>0, "you can not Vote, Not a Contibutetr ");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted" );
        thisRequest.voters[msg.sender]==true;
        thisRequest.noofVoters++;

    }
    function makePayment(uint _requestNo) public onlyManager {
        require(raisedAmount>=target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(2*thisRequest.noofVoters> noofContributers, "Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }
}