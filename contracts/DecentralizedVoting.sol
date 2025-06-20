// SPDX‑License‑Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title DecentralizedVoting
 * @author GPT‑4o
 * @notice A lightweight, owner‑managed voting contract with five core functions.
 */
contract DecentralizedVoting {
    /*--------------------------------------------------------------
                               EVENTS
    --------------------------------------------------------------*/
    event CandidateRegistered(uint256 indexed id, string name);
    event ElectionStarted(string electionName);
    event Voted(address indexed voter, uint256 indexed candidateId);
    event ElectionEnded(uint256 winnerId, uint256 voteCount);

    /*--------------------------------------------------------------
                               STRUCTS
    --------------------------------------------------------------*/
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    /*--------------------------------------------------------------
                              STATE
    --------------------------------------------------------------*/
    address public immutable owner;
    string  public electionName;
    bool    public electionStarted;
    bool    public electionEnded;

    uint256 private _candidateIndex;
    mapping(uint256 => Candidate) private _candidates;
    mapping(address => bool)     private _hasVoted;

    /*--------------------------------------------------------------
                             MODIFIERS
    --------------------------------------------------------------*/
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier whenElectionActive() {
        require(electionStarted && !electionEnded, "Election not active");
        _;
    }

    /*--------------------------------------------------------------
                        CONSTRUCTOR (no function #)
    --------------------------------------------------------------*/
    constructor() {
        owner = msg.sender;
    }

    /*--------------------------------------------------------------
                       CORE PUBLIC / EXTERNAL FUNCTIONS
                       (random count: **5** this time)
    --------------------------------------------------------------*/

    /// 1️⃣  Register a candidate (owner‑only, before start)
    function registerCandidate(string calldata _name) external onlyOwner {
        require(!electionStarted, "Election already started");
        _candidates[_candidateIndex] = Candidate({name: _name, voteCount: 0});
        emit CandidateRegistered(_candidateIndex, _name);
        _candidateIndex++;
    }

    /// 2️⃣  Start the election (owner‑only)
    function startElection(string calldata _name) external onlyOwner {
        require(!electionStarted, "Election already started");
        require(_candidateIndex > 1, "Need at least 2 candidates");
        electionName     = _name;
        electionStarted  = true;
        emit ElectionStarted(_name);
    }

    /// 3️⃣  Cast a vote for a candidate (any user, once)
    function vote(uint256 _candidateId) external whenElectionActive {
        require(!_hasVoted[msg.sender], "Already voted");
        require(_candidateId < _candidateIndex, "Invalid candidate");
        _hasVoted[msg.sender] = true;
        _candidates[_candidateId].voteCount++;
        emit Voted(msg.sender, _candidateId);
    }

    /// 4️⃣  End the election and announce winner (owner‑only)
    function endElection() external onlyOwner whenElectionActive {
        electionEnded = true;
        (uint256 winnerId, uint256 votes) = _tallyWinner();
        emit ElectionEnded(winnerId, votes);
    }

    /// 5️⃣  View function to fetch winner at any time
    function getResults()
        external
        view
        returns (uint256 winnerId, string memory winnerName, uint256 votes)
    {
        (winnerId, votes) = _tallyWinner();
        winnerName = _candidates[winnerId].name;
    }

    /*--------------------------------------------------------------
                             INTERNAL LOGIC
    --------------------------------------------------------------*/
    function _tallyWinner() internal view returns (uint256 id, uint256 votes) {
        uint256 highest = 0;
        uint256 winner  = 0;
        for (uint256 i = 0; i < _candidateIndex; i++) {
            if (_candidates[i].voteCount > highest) {
                highest = _candidates[i].voteCount;
                winner  = i;
            }
        }
        return (winner, highest);
    }
}
