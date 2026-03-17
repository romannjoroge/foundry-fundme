import {FundMe} from "../src/FundMe.sol";
import {Test} from "forge-std/Test.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumUSDAmount() public {
        assertEq(fundMe.MINIMUM_CONTRIBUTION(), 5e18);
    }
}
