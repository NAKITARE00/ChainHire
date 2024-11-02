// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Client {
    struct Client {
        address clientAddress;
        uint256 id;
        string name;
        string email;
        string phone;
        uint256 rating;
        uint256[] postedJobs;
    }

    struct Job {
        uint256 id;
        address owner;
        string title;
        string description;
        string category;
        uint256 freelancerId;
        uint256 budget;
        bool isCompleted;
    }

    // Event declarations
    event ClientCreated(address indexed clientAddress, uint256 id, string name);
    event JobCreated(uint256 indexed jobId, address indexed owner, string title);
    event JobAssigned(uint256 indexed jobId, uint256 indexed freelancerId);

    mapping(address => Client) public clients;
    mapping(uint256 => Client) public clientsById;
    uint256 public clientCount;

    mapping(uint256 => Job) public jobs;
    uint256 public jobCount;

    address public freelancerContractAddress;

    modifier onlyFreelancerContract() {
        require(msg.sender == freelancerContractAddress, "Only Freelancer contract can call this");
        _;
    }

    function setFreelancerContract(address _freelancerContract) public {
        require(freelancerContractAddress == address(0), "Freelancer contract already set");
        freelancerContractAddress = _freelancerContract;
    }

    function createClient(
        string memory _name,
        string memory _email,
        string memory _phone
    ) public {
        require(clients[msg.sender].clientAddress == address(0), "Client already exists");
        
        clientCount++;
        uint256 id = clientCount;
        
        uint256[] memory emptyJobs = new uint256[](0);
        
        Client memory newClient = Client({
            clientAddress: msg.sender,
            id: id,
            name: _name,
            email: _email,
            phone: _phone,
            rating: 0,
            postedJobs: emptyJobs
        });
        
        clients[msg.sender] = newClient;
        clientsById[id] = newClient;
        
        emit ClientCreated(msg.sender, id, _name);
    }

    function createJob(
        string memory _title,
        string memory _description,
        string memory _category,
        uint256 _budget
    ) public {
        require(clients[msg.sender].clientAddress != address(0), "Must be a registered client");
        
        jobCount++;
        uint256 id = jobCount;
        
        Job memory newJob = Job({
            id: id,
            owner: msg.sender,
            title: _title,
            description: _description,
            category: _category,
            freelancerId: 0,
            budget: _budget,
            isCompleted: false
        });
        
        jobs[id] = newJob;
        clients[msg.sender].postedJobs.push(id);
        
        emit JobCreated(id, msg.sender, _title);
    }

    function assignJobToFreelancer(uint256 _jobId, uint256 _freelancerId) external onlyFreelancerContract {
        require(jobs[_jobId].id != 0, "Job does not exist");
        require(jobs[_jobId].freelancerId == 0, "Job already assigned");
        
        jobs[_jobId].freelancerId = _freelancerId;
        
        emit JobAssigned(_jobId, _freelancerId);
    }

    function getJob(uint256 _jobId) public view returns (
        uint256 id,
        address owner,
        string memory title,
        string memory description,
        string memory category,
        uint256 freelancerId,
        uint256 budget
    ) {
        Job memory job = jobs[_jobId];
        return (
            job.id,
            job.owner,
            job.title,
            job.description,
            job.category,
            job.freelancerId,
            job.budget
        );
    }

    function getJobs() public view returns (Job[] memory) {
        Job[] memory allJobs = new Job[](jobCount);
        for (uint256 i = 0; i < jobCount; i++) {
            allJobs[i] = jobs[i + 1];
        }
        return allJobs;
    }

    function getClientJobs(address _clientAddress) public view returns (uint256[] memory) {
        return clients[_clientAddress].postedJobs;
    }
}