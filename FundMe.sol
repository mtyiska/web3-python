// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


// import "hardhat/console.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    mapping(address=>uint256) public addressToAmountFunded;
    address[] public funders; 
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        // $50
        uint256 minimumUSD = 50 * 10 *18;
        
        require(msg.value >= minimumUSD, string(abi.encodePacked("You need more eth", minimumUSD)));
        addressToAmountFunded[msg.sender] += msg.value;
        console.log(addressToAmountFunded[msg.sender]);
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        console.log(priceFeed.version());
        return priceFeed.version();
    }

    function getPrice() public view returns (uint80, int, uint, uint, uint80){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return (roundID, price * 10000000000, startedAt, timeStamp, answeredInRound);
    }

    // 1000000000
    function getConversionRate(int ethAmount) public view returns (int){
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        )  = getPrice();
        console.log(roundID, startedAt, timeStamp, answeredInRound);
        int ethAmountInUsd = (price * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    modifier onlyOwner{
        // _; is the modifier. says run require first then run rest of code
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    function withdraw() payable onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);

        for(uint256 idx=0; idx < funders.length; idx++){
            address funder = funders[idx];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
