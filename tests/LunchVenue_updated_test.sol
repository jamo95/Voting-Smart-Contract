// SPDX - License - Identifier : UNLICENSED

pragma solidity >=0.8.00 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/LunchVenue_updated.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
/// Inherit 'LunchVenue_updated' contract
contract LunchVenue_updated_tested is LunchVenue_updated {

    // Variables used to emulate different accounts
    address acc0;
    address acc1;
    address acc2;
    address acc3;
    address acc4;
    address acc5;

    /// 'beforeAll' runs before all other tests
    /// More special functions are : 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0); // Initiate account variables
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        acc3 = TestsAccounts.getAccount(3);
        acc4 = TestsAccounts.getAccount(4);
        acc5 = TestsAccounts.getAccount(5);
    }

    /// Account at zero index ( account -0) is default account , so manager will be set to acc0
    function managerTest() public {
        Assert.equal( manager , acc0 , 'Manager should be acc0');
    }

    /// Add lunch venue as manager
    /// When msg. sender isn ’t specified , default account (i.e., account -0) is considered the sender
    function setLunchVenueUpdated() public {
        Assert.equal( addVenue('Courtyard Cafe'), 1, 'Should be equal to 1') ;
        Assert.equal( addVenue('Uni Cafe'), 2, 'Should be equal to 2');
    }

    /// Try to add lunch venue as a user other than manager . This should fail
    /// #sender: account-1
    function setLunchVenueUpdatedFailure() public {
        try this.addVenue('Atomic Cafe') returns ( uint v) {
            Assert.ok(false , 'Method execution should fail');
        } catch Error ( string memory reason ) {
            // Compare failure reason , check if it is as expected
            Assert.equal(reason , 'Can only be executed by the manager', 'Failed with unexpected reason');
        } catch ( bytes memory /* lowLevelData */) {
            Assert.ok(false , 'Failed unexpected') ;
        }
    }

    /// Set friends as account -0
    /// # sender doesn't need to be specified explicitly for account -0
    function setFriend() public {
        Assert.equal( addFriend(acc0 , 'Alice') , 1, 'Should be equal to 1');
        Assert.equal( addFriend(acc1 , 'Bob') , 2, 'Should be equal to 2') ;
        Assert.equal( addFriend(acc2 , 'Charlie') , 3 , 'Should be equal to 3') ;
        Assert.equal( addFriend(acc3 , 'Eve') , 4, 'Should be equal to 4') ;
    }

    /// Try adding friend as a user other than manager . This should fail
    /// #sender: account-2
    function setFriendFailure() public {
        try this.addFriend(acc4 , 'Daniels') returns ( uint f) {
            Assert.ok(false , 'Method execution should fail');
        } catch Error ( string memory reason ) {
            // Compare failure reason , check if it is as expected
            Assert.equal(reason , 'Can only be executed by the manager', 'Failed with unexpected reason');
        } catch ( bytes memory /* lowLevelData */) {
            Assert.ok(false , 'Failed unexpected') ;
        }
    }

    /// Vote as Bob ( acc1 )
    /// #sender: account-1
    function vote() public {
        Assert.ok( doVote(2) , 'Voting result should be true');
    }

    // ISSUE 2
    /// Can't add new venues once vote started
    function setLunchVenueAfterVoteFailure() public {
        Assert.equal( addVenue('Quad'), 2, 'Should be equal to 2') ;
    }

    // ISSUE 2
    /// Can't add new friends once vote starteds
    function setFriendAfterVoteFailure() public {
        Assert.equal( addFriend(acc4 , 'Ivan') , 4, 'Should be equal to 4') ;
    }

    /// Vote as Charlie
    /// #sender: account-2
    function vote2() public {
        Assert.ok( doVote(1) , 'Voting result should be true');
    }

    // ISSUE 1
    /// Vote as Charlie again
    /// #sender: account-2
    function vote2again() public {
        Assert.equal( doVote(1), false, 'Voting result should be false');
    }

    /// Try voting as a user not in the friends list . This should fail
    /// #sender: account-4
    function voteFailure() public {
        Assert.equal( doVote(1), false, 'Voting result should be false');
    }

    /// Vote as Eve
    /// #sender: account-3
    function vote3() public {
        Assert.ok( doVote(2) , 'Voting result should be true');
    }

    /// Verify lunch venue is set correctly
    function lunchVenueUpdatedTest() public {
        Assert.equal( votedVenue , 'Uni Cafe', 'Selected venue should be Uni Cafe');
    }

    /// Verify voting is now closed
    function voteOpenTest() public {
        Assert.equal( voteOpen , false , 'Voting should be closed') ;
    }

    /// Verify voting after vote closed . This should fail
    /// # sender: account-2
    function voteAfterClosedFailure() public {
        try this.doVote(1) returns ( bool validVote ) {
            Assert.ok(false , 'Method Execution Should Fail');
        } catch Error ( string memory reason ) {
            // Compare failure reason , check if it is as expected
            Assert.equal(reason , 'Can vote only while voting is open.', 'Failed with unexpected reason');
        } catch ( bytes memory /* lowLevelData */) {
            Assert.ok(false , 'Failed unexpectedly');
        }
    }

    // ISSUE 3
    /// check votingstate after timeout test
    function blockNumberTimeOutTest() public {
        if ( block.number >= startingBlockNum + 120 ){
            Assert.equal( uint(setTimeout()), uint(VotingState.CLOSE), 'Current state should be closed');
        } else {
            Assert.equal( uint(setTimeout()), uint(VotingState.OPEN), 'Current state should be open');
        }
    }

    // ISSUE 4
    /// Check current state and voting is closed after disabling as the manager Alice ( acc0 )
    /// #sender: account-0
    function currentStateDisableContractTest() public {
        disableContract();
        Assert.equal( voteOpen, false, 'Voting should be closed');
        Assert.equal( uint(currentState), uint(VotingState.CLOSE), 'Current state should be closed');
    }

    // ISSUE 4
    // Should be fine as long as function doesn't fail
    /// Disable by self-destructing as the manager Alice ( acc0 )
    /// #sender: account-0
    function killTest() public {
        kill();
    }

    // ISSUE 5
    // test by comparing gas consumption of updated and non-updated solutions
}
