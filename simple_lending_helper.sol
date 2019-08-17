pragma solidity >=0.4.0 <0.6.0;

/*
// @author p-stav
// @title simple_lending_helper.sol
//
// @dev Goal: Mimic simple lending smart contract functionality. That anyone can fork and call.
        This file has helpers used in simple_lending.sol
*/

contract SimpleLendingHelper {
    //define global variables
    uint days_to_exp;
    uint interest_rate;
    uint total_funds;

    struct Participant {
        string name;
        address public_key;
        bool exists;
        uint8 borrower_count;
        uint8 lender_count;
        uint balance;  // negative is net borrow, positive is net lender
    }

    // struct loan
    struct Loan {
        // money is pooled together in the wallet
        // no orignator
        uint id;
        address borrower;
        uint amount;
        uint payback_date;
        bool collateral_paid;
    }

    // create mappings and arrays
    // unique id to Loan
    // mapping (uint => Loan) idToLoan;
    Loan[] loans;
    mapping (address => uint) collateral;
    mapping (address => Participant) participants;

    // we need to store collateral in a different array
    // we could make this a different contract, but the additional
    // liquidity would be helpful

    // uinque id to loan
    // a way to check if loans are overdue

    // create participant
    function _create_participant(address _public_key, uint _amount) internal {
        Participant memory participant;

        participant.public_key = _public_key;
        participant.exists = true;
        participant.balance = _amount;

        // add to participants
        participants[participant.public_key] = participant;
    }

    // create_loan


}
