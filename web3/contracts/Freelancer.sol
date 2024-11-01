// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Client} from "./Client.sol";

contract Freelancer {

    using Client for Client.Client;

    struct Freelancer{
        address freelancerAddress;
        uint256 id;
        string name;
        string email;
        string phone;
        uint256 rating;
    }

    mapping (address => Freelancer) public freelancers;
    mapping (uint256 => Freelancer) public freelancersById;
    uint256 storage freelancerCount;
    
    function createFreelancer(string memory _name, string memory _email, string memory _phone) public {
       freelancerCount++;
       uint256 id = freelancerCount; 
       Freelancer storage freelancer = freelancersById[id];
       Freelancer storage freelancer = freelancers[msg.sender];
       freelancer = Freelancer(msg.sender, id, _name, _email, _phone, 0);     
    }
}