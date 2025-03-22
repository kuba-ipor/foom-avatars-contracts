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
        uint256 deployerPrivateKey;
        
        // Try to get private key from env, otherwise use Anvil's default key
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            deployerPrivateKey = key;
        } catch {
            deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        }

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