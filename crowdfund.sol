pragma solidity >=0.4.22 <0.6.0;


/*
// @title crowdfund.sol
// @author p-stav
// @dev - A simple contract to accept funds from a crowd of people
//
//        Use Case: As an entity that wants to raise funds from a crowd, I can
//        deploy this contract out-of-the-box and set the given paramaters at the
//        top of the contract
*/


contract Crowdfund {
  // @dev define global variables to contract
  // @dev define crowdfund

  struct CrowdFund {
    bool isActive;
    bool goalMet;
    uint fundGoal;
    uint startDate;
    uint endDate;
    mapping (address => uint) contributor_funds;
    address chairperson;
    uint totalFunds;
  }

  string[] contributors;

  // @dev public scope
  Crowdfund crowdfund;

  // @dev constructor
  constructor(uint num_days_finish, uint fundraise_goal) public {

    // @dev set variables, and make active
    crowdfund.chairperson = msg.sender;
    crowdfund.fundGoal = fundraise_goal;
    crowdfund.startDate = now;
    crowdfund.endDate = crowdfund.startDate + numDaysFinish;
    crowdfund.isActive = true;
    crowdfund.totalFunds = 0;
  }

  // @dev accept funds
  // @ will also implement the fallback function for folks who will directly send money
  function send_funds() public payable is_active is_valid_amount crowdfund_end  {
    accept_funds(msg.sender, msg.value);
  }

  function () public payable is_active is_valid_amount crowdfund_end {
    accept_funds(msg.sender, msg.value);
  }

  function accept_funds(uint contributor_address, uint contribution) private {
    // check if before endDate
    require(now <= crowdfund.endDate);

    // chick if crowdfund has ended

    // record contribution
    contributors.push(contributor_address);
    crowdfund.contributor_funds[contributor_address] += contribution; // addresses can continue to contribute
    crowdfund.totalFunds += contribution;

    // check if we have reached goal
    if(crowdfund.totalFunds >= fundGoal) {
      bool goalMet = true;
    }
  }



  // @dev end crowdfund
  modifier crowdfund_end() private pure {
    if(crowdfund == true && now > crowdfund.endDate) {
      crowdfund.isActive = false;

      // perform check to see if we must refund folks
      if(crowdfund.totalFunds < crowdfund.fundGoal) {
        refund_funds();
      }
    }
    _;
  }

  // @dev refund if raise not successful
  function refunds() private {
    for(uint i = 0; i<crowdfund.contributors.length) {
      uint contribution = contributor_funds[contributors[i]];
      require(contribution <= totalFunds);

      contributors[i].transfer(contribution);
      totalFunds -= contribution;
    }
  }

  // @dev modifier isActive
  modifier is_active() {
    require(crowdfund.isActive);
    _;
  }

  modifier is_valid_amount() {
    require(msg.value >0);
    _;
  }
}
