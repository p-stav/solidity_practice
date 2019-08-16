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

  struct Crowdfund {
    bool isActive;
    bool goalMet;
    uint fundGoal;
    uint startDate;
    uint endDate;
    mapping (address => uint) contributor_funds;
    uint totalFunds;
  }

  address payable[]  contributors;

  // @dev public scope
  Crowdfund crowdfund;

  // @dev constructor
  constructor(uint numDaysFinish, uint fundraise_goal) public {

    // @dev set variables, and make active
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

  function () external payable is_active is_valid_amount crowdfund_end {
    accept_funds(msg.sender, msg.value);
  }

  function accept_funds(address payable contributor_address, uint contribution) private {
    // check if before endDate
    require(now <= crowdfund.endDate);

    // chick if crowdfund has ended

    // record contribution
    contributors.push(contributor_address);
    crowdfund.contributor_funds[contributor_address] += contribution; // addresses can continue to contribute
    crowdfund.totalFunds += contribution;

    // check if we have reached goal
    if(crowdfund.totalFunds >= crowdfund.fundGoal) {
      bool goalMet = true;
    }
  }



  // @dev end crowdfund
  modifier crowdfund_end() {
    if(crowdfund.isActive == true && now > crowdfund.endDate) {
      crowdfund.isActive = false;

      // perform check to see if we must refund folks
      if(crowdfund.totalFunds < crowdfund.fundGoal) {
        refunds();
      }
    }
    _;
  }

  // @dev refund if raise not successful
  // @dev this function needs to be public because it is payable
  //      so we need to make a series of requirements again to be certain
  //      that it is not triggered incorrectly. It's duplicative
  function refunds() public payable {
    require(crowdfund.isActive == false);
    require(now > crowdfund.endDate);

    for(uint i = 0; i<contributors.length;i++) {
      uint contribution = crowdfund.contributor_funds[contributors[i]];
      require(contribution <= crowdfund.totalFunds);

      contributors[i].transfer(contribution);
      crowdfund.totalFunds -= contribution;
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
