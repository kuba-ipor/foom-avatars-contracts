// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/GeniusToken.sol";
import "../src/FoomGeniusAnswer.sol";

contract DeployScript is Script {
    // Configuration
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 ether; // 1 billion tokens
    uint256 public constant INITIAL_PUBLISH_COST = 100 ether;     // 100 tokens per answer

    function run() external {
        // Retrieve deployer private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy GeniusToken
        GeniusToken geniusToken = new GeniusToken(INITIAL_SUPPLY);
        console.log("GeniusToken deployed at:", address(geniusToken));

        // Deploy FoomGeniusAnswer
        FoomGeniusAnswer foomGeniusAnswer = new FoomGeniusAnswer(
            address(geniusToken),
            INITIAL_PUBLISH_COST
        );
        console.log("FoomGeniusAnswer deployed at:", address(foomGeniusAnswer));

        // Optional: Transfer some initial tokens to the deployer's address
        address deployer = vm.addr(deployerPrivateKey);
        if (deployer != address(this)) {
            geniusToken.transfer(deployer, INITIAL_SUPPLY / 2);
            console.log("Transferred initial tokens to deployer:", deployer);
        }

        vm.stopBroadcast();

        // Log deployment information
        console.log("Deployment completed!");
        console.log("Network:", block.chainid);
        console.log("Initial token supply:", INITIAL_SUPPLY / 1 ether, "GENIUS");
        console.log("Initial publish cost:", INITIAL_PUBLISH_COST / 1 ether, "GENIUS");
    }
} 