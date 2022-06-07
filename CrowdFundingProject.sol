// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noofContributors;

    struct Request{
        string description;
        address payable recepient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;
    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp+ _deadline;
        minimumContribution=100 wei;
        manager=msg.sender;
    }

    function sendEth() public payable{
        require(block.timestamp<deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"Minimum contribution is not met");

        if (contributors[msg.sender]==0){
            noofContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target, "You are not eligible for refund");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;

    }
    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can call this function");
        _;
    }
    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManager{
    Request storage newRequest=requests[numRequests];
    numRequests++;
    newRequest.description=_description;
    newRequest.recepient=_recipient;
    newRequest.value=_value;
    newRequest.completed=false;
    newRequest.noOfVoters=0;
    }
    function voteRequest(uint _requestNmbr) public{
        require(contributors[msg.sender]>0,"You must be a contributor");
        Request storage thisrequest=requests[_requestNmbr]; 
        require(thisrequest.voters[msg.sender]==false,"You have voted already");
        thisrequest.voters[msg.sender]=true;
        thisrequest.noOfVoters++;
    }
    function makePayment(uint _requestNmbr)public onlyManager{
        require(raisedAmount>=target);
        Request storage thisrequest=requests[_requestNmbr];
        require(thisrequest.completed==false,"The request has been completed");
        require(thisrequest.noOfVoters>noofContributors/2,"Majority does not support");
        thisrequest.recepient.transfer(thisrequest.value);
        thisrequest.completed=true;
    }
    
}