pragma solidity >=0.4.22 <0.6.0;

// @title bonding_curve.sol
// @author p-stav
// @dev - put a simple bonding curve together.
//        burning and minting will be done through using a 'vault' contract
//        For simplicity, the bonding curve will be linear
//
// NOTE: I know that there are constraints with fixed point math in solidity. I've abstracted
//       this away at this moment to get in for a feel of solidity. But I would test and incorporate
//       libraries like Zeppelin's safemath or cementdao's fixedity contract.

// @dev - This is designed for people to fork and use with their own frontend that passes in constructor's parameter.


contract bondingCurve {
    uint public numTokens;
    uint public currentTokenPrice; // in ether
    mapping(address => Participant) public addressParticipantMap;
    uint32 public bondingSlope; // in ether
    uint32 public yIntercept; // in ether
    address public owner;

    //create struct for participant
    struct Participant {
        address payable contributor;
        uint numTokens;
        bool previousContributor;
    }

    // create a series of events to update other enttieis in dapp
    event tokensBought(uint numTokens, uint quantityAdded, address purchaser);
    event tokensSold(uint numTokens, uint quantityRemoved, address purchaser);


    /*
    // @dev constructor to define bonding curve, owner, and other parameters
    //  multiply constants by 1000 and rounding them before creating the smart contract.
    */
    constructor(uint32 _bondingSlope, uint32 _yIntercept) public {

        // assign variables - by design can only be set once
        bondingSlope = _bondingSlope;
        yIntercept = _yIntercept; // this effectively sets the floor price
    }



    /*
    // @dev user specifies amount of tokens s/he wishes to buy and we check that such funds have been sent
    */
    function userBuysTokens(address payable _sender, uint _numTokens) payable external {

        // compute integral of linear function and require msg.value equals that
        uint numTokensPriceCheck = computeIntegral(_numTokens, true);
        require(msg.value == numTokensPriceCheck);

        // TODO: implement vault contract logic in another contract
        //       - Do we have these tokens in vault
        //       - or are we minting new tokens?

        // transfer tokens to address
        _sender.transfer(_numTokens);

        // record addition of addressBalanceMap and increment numTokens!!
        if(addressParticipantMap[_sender].previousContributor == true) {addressParticipantMap[_sender].numTokens += _numTokens;}

        else {
            addressParticipantMap[_sender].previousContributor == true;
            addressParticipantMap[_sender].numTokens = _numTokens;
        }
        numTokens += _numTokens;

        // emit an event to update frontend and the likes
        emit tokensBought(numTokens, _numTokens, _sender);
    }

    /*
    // @dev sell tokens
    //      user sells tokens to contract, in exchange for funds
    */
    function userSellsTokens(address _sender, uint _numTokens) external {
       // compute amount of money to provide
       uint numTokensPrice = computeIntegral(_numTokens, false);

       // Pay Token Holder and update numTokens
       msg.sender.send(numTokensPrice);
       numTokens -= _numTokens;

       // update map of balance and tokens
       // it is possible tokens were received from secondary market -- so let's
       if(addressParticipantMap[_sender].previousContributor == true) {
            addressParticipantMap[_sender].numTokens - _numTokens < 0 ? 0 : addressParticipantMap[_sender].numTokens - _numTokens;
       }
       else {
           addressParticipantMap[_sender].previousContributor == true;
           addressParticipantMap[_sender].numTokens = 0;
       }

       //TODO: check that funds were sent to vault
       // or burn tokens
    }

    function computeIntegral(uint _numTokens, bool _lookingForQ2) view internal returns(uint) {
        if(_lookingForQ2) {
            uint quantity2 = numTokens + _numTokens;

            return  (quantity2 * (uint(0.5)*uint(bondingSlope) * quantity2 + yIntercept) -
                    (numTokens * (uint(0.5)*uint(bondingSlope)*numTokens + yIntercept)));
        }

        else {
            uint quantity1 = numTokens - _numTokens;

            return  (_numTokens * (uint(0.5)*uint(bondingSlope) * numTokens + yIntercept) -
                    (quantity1 * (uint(0.5)*uint(bondingSlope)*quantity1 + yIntercept)));
        }

    }
}
