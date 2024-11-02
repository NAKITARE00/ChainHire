// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Client} from "./Client.sol";

contract Freelancer {
    using Client for Client.Client;

    struct Freelancer {
        address freelancerAddress;
        uint256 id;
        string name;
        string email;
        string phone;
        uint256 rating;
        uint256[] assignedJobs; // Array to track jobs assigned to this freelancer
        string expertise; // Added field for freelancer's expertise category
    }

    // Event declarations
    event FreelancerCreated(address indexed freelancerAddress, uint256 id, string name);
    event JobAccepted(uint256 indexed jobId, address indexed freelancerAddress);

    mapping(address => Freelancer) public freelancers;
    mapping(uint256 => Freelancer) public freelancersById;
    uint256 public freelancerCount;
    
    Client public clientContract; // Reference to the Client contract

    constructor(address _clientContractAddress) {
        clientContract = Client(_clientContractAddress);
    }
    
    function createFreelancer(
        string memory _name, 
        string memory _email, 
        string memory _phone,
        string memory _expertise
    ) public {
        require(freelancers[msg.sender].freelancerAddress == address(0), "Freelancer already exists");
        
        freelancerCount++;
        uint256 id = freelancerCount;
        
        uint256[] memory emptyJobs = new uint256[](0);
        
        Freelancer memory newFreelancer = Freelancer({
            freelancerAddress: msg.sender,
            id: id,
            name: _name,
            email: _email,
            phone: _phone,
            rating: 0,
            assignedJobs: emptyJobs,
            expertise: _expertise
        });
        
        freelancers[msg.sender] = newFreelancer;
        freelancersById[id] = newFreelancer;
        
        emit FreelancerCreated(msg.sender, id, _name);
    }

    function acceptJob(uint256 _jobId) public {
        require(freelancers[msg.sender].freelancerAddress != address(0), "Must be a registered freelancer");
        
        // Get job details from the Client contract
        (uint256 id, address owner, string memory title, string memory description, 
         string memory category, uint256 freelancerId, uint256 budget) = clientContract.getJob(_jobId);
        
        require(freelancerId == 0, "Job already assigned");
        require(keccak256(bytes(category)) == keccak256(bytes(freelancers[msg.sender].expertise)), 
                "Job category doesn't match freelancer expertise");
        
        // Update the job in the Client contract
        clientContract.assignJobToFreelancer(_jobId, freelancers[msg.sender].id);
        
        // Update freelancer's assigned jobs
        freelancers[msg.sender].assignedJobs.push(_jobId);
        
        emit JobAccepted(_jobId, msg.sender);
    }

    function getFreelancer(address _address) public view returns (Freelancer memory) {
        return freelancers[_address];
    }

    function getFreelancerJobs(address _freelancerAddress) public view returns (uint256[] memory) {
        return freelancers[_freelancerAddress].assignedJobs;
    }

    function getFreelancers() public view returns (Freelancer[] memory) {
        Freelancer[] memory allFreelancers = new Freelancer[](freelancerCount);
        for (uint256 i = 0; i < freelancerCount; i++) {
            allFreelancers[i] = freelancersById[i + 1];
        }
        return allFreelancers;
    }
}