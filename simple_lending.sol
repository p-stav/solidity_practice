pragma solidity >=0.4.0 <0.6.0;
import "./simple_lending_helper.sol";
/*
// @author p-stav
// @title simple_lending.sol
//
// @dev Goal: Mimic simple lending smart contract functionality. That anyone can fork and call.
        Put in money
        Put in 1.5x collateral
        On given fixed date x days later with y% interest, check if paid back
        If not, slash collateral and give back
*/

contract SimpleLending is SimpleLendingHelper {

    // @dev all definitions are in SimpleLendingHelper


    // @dev constructor
    constructor(uint _days_to_exp, uint _interest_rate) public{
        days_to_exp = _days_to_exp;
        interest_rate = _interest_rate;

        // todo: define owner and put in management functions
    }

    // @dev investor inputs funds to contract
    function _invester_deposit() public payable {
        require(msg.value > 0);
        total_funds += msg.value;

        // check if participant exists. If not, create
        if(participants[msg.sender].exists != true) {
            _create_participant(msg.sender, msg.value);
        }
        else {
            participants[msg.sender].balance += msg.value;
        }
    }


    // @dev take_loan along with collateral
    // but only take loan if collateral is paid
    // assume amount is 1.5x what will be loaned
    // and that min is 1
    function _take_loan() public payable {
        require(uint(1*msg.value) > 1);
        require(msg.value/1.5 < total_funds);

        collateral[msg.sender] += msg.value;

        // record person in participants
        if(participants[msg.sender].exists != true) {
            _create_participant(msg.sender, uint(-1) * msg.value/1.5);
        }
        else {
            participants[msg.sender].balance += uint(-1) * msg.value/1.5;
        }

        // create loan
        Loan memory loan;
        loan.borrower = msg.sender;
        loan.amount = msg.value/1.5;
        loan.payback_date = now + days_to_exp;

        // create loan id
        loan.id = uint(keccak256(abi.encodePacked(loan.borrower, loan.amount, loan.payback_date)));

        // push to loans
        loans.push(loan);

        // transfer funds to that person
        msg.sender.transfer(msg.value/1.5);
    }

    // @dev pay_back_loan

    // @dev slash_collateral
}
