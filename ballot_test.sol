pragma solidity >=0.4.0 <0.6.0;
      import "remix_tests.sol"; // this import is automatically injected by Remix.
      import "./ballot_paul.sol";

      // file name has to end with '_test.sol'
      contract test_1 {

        Ballot ballot_to_test;
        Ballot ballot_to_test_1;
        Ballot ballot_to_test_2;

        function beforeAll() public {
          // here should instantiate tested contract
          ballot_to_test = new Ballot(3);
          ballot_to_test_1 = new Ballot(2);

          ballot_to_test_2 = new Ballot(1);
          ballot_to_test_2.submitVote(msg.sender,0);
          ballot_to_test_2.closeVoting();
        }

        function check1() public {
          // test vote
          ballot_to_test.submitVote(msg.sender, 1);
          ballot_to_test.closeVoting();
          Assert.equal(ballot_to_test.winningProposal(), uint(1), "1 should be the winning proposal");
        }

        function check2() public {
          ballot_to_test_1.submitVote(msg.sender, 0);
          ballot_to_test_1.closeVoting();
          Assert.equal(ballot_to_test_1.winningProposal(), uint(0), "1 should be the winning proposal");
        }

        function check3() public view returns(bool) {
           return ballot_to_test_2.winningProposal() == uint8(0);
        }
      }
