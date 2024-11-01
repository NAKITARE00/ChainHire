// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Client{

    struct Client {
        address clientAddress;
        uint256 id;
        string name;
        string email;
        string phone;
        uint256 rating;
        uint256 freelancerId;
        uint256 jobId;
    }

    mapping (address => Client) public clients;
    mapping (uint256 => Client) public clientsById;
    uint256 storage clientCount;

    struct Job {
        uint256 id;
        address owner;
        string title;
        string description;
        uint256 freelancerId;
        uint256 budget;
    }

    mapping (address => Job) public jobs;
    mapping (uint256 => Job) public jobsById;
    uint256 storage jobCount;

    function createClient (string memory _name, string memory _title, string memory _description, uint256 budget) public {
        clientCount++;
        uint256 id = clientCount;
        Client storage client = clientsById[id];
        Client storage client = clients[msg.sender];
        client = Client(msg.sender, id, _name, _title, _description, budget);
    }

    function createJob (string memory _title, string memory _description, uint256 budget) public {
        jobCount++;
        uint256 id = jobCount;
        Job storage job = jobsById[id];
        Job storage job = jobs[msg.sender];
        job = Job(id, msg.sender, _title, _description, 0, budget);
    }

    
}