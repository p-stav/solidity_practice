pragma solidity >=0.4.22 <0.6.0;

// @title ballot.sol
// @author p-stav
// @dev - put a simple ballot on ethereum, where a user can also receive a validation that their vote went through
// @dev - My  belief is that a voting application on blockchain has
//        highly reduced value if it does not provide attestation of an untampered vote
//
// @dev - This is designed for people to fork and use with their own front end that passes in the defined.
// @dev - This version does not have delegation possible. However, it assumes that a set of addresses can
//        give permission for a set of addresses to vote


contract Ballot {
  // @dev bool to determine if ballot is active
  bool public isActive;

  // @dev declare proposal, which is a vote option
  struct Proposal {
    uint32 voterCount;  // number of people voted
    bytes32 proposal_description;     // bytes32 since it's easier to work with bytes32
  }

  // @dev declare Voter
  struct Voter {
    address voterAddress;
    bool voted;
    // uint vote; // We do not want to store what the vote for a given participant is!
  }

  // @dev define chairperson who can give permission for addresses to vote - this is contract creator
  address chairperson;

  // @dev array of Proposals
  Proposal[] public proposals;

  // @dev map of addresses of voters who voted or have permission to vote
  mapping(address => Voter) public voters;


  // @dev constructor - set chairperson, define @dev chairperson grants permission to vote
  // @dev input - an array of proposal names
  // output -- an array of Proposals
  constructor(bytes32[] memory proposalNames) public {
    chairperson = msg.sender;

    for(uint8 i=0; i<proposalNames.length; i++) {
      proposals.push(Proposal({voterCount:uint32(0), proposal_description:proposalNames[i]}));
    }

    // note - by design, chairperson cannot vote. To change this, uncomment below
    // voters[msg.sender] = Voter({msg.sender, false});
  }

  // @dev chairperson grants an address to vote
  function grantVotingPermissions(address voter) public onlyOwner {
      // check if voter exists
      checkVoted(voter);

      // add to voters map and set voted to false
      voters[voter] = Voter({voterAddress:voter, voted:false});
  }

  // @dev voter submits vote, added to voters map
  function submitVote(address voter, uint8 proposal) public {
    // check if already voted
    checkVoted(voter);

    // add count to proposal in proposal array
    proposals[proposal].voterCount++;

    // TODO: RECORD VOTE ON-CHAIN TO ATTEST TO ITS OCCURRENCE

    // change voter to voted!
    voters[voter].voted = true;
  }

  // @dev chairperson can open voting
  // @dev TODO: change this so that we pass in a predefined end time
  //      This minimizes tampering
  //      The below openVoting and closeVoting is a very primitive implementation
  function openVoting() public onlyOwner {
    isActive = true;
  }

  // @dev chairperson can close voting
  function closeVoting() public onlyOwner {
    isActive = false;
  }

  // @dev internal function to check if address already voted
  function checkVoted(address address_voter) private {
    // check if voter exists
    require(voters[address_voter].voted == false); // punish actors by taking their gas if they have already voted
  }

  // @dev define onlyOwner modifier
  modifier onlyOwner {
        require(msg.sender == chairperson, "Only owner can call this function.");
        _;
    }

}
