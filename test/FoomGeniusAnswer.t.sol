// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/FoomGeniusAnswer.sol";
import "../src/GeniusToken.sol";

contract FoomGeniusAnswerTest is Test {
    FoomGeniusAnswer public foomGeniusAnswer;
    GeniusToken public geniusToken;
    
    address public owner;
    address public user;
    
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;
    uint256 public constant PUBLISH_COST = 100 ether;
    
    function setUp() public {
        owner = address(this);
        user = address(0x1);
        
        // Deploy contracts
        geniusToken = new GeniusToken(INITIAL_SUPPLY);
        foomGeniusAnswer = new FoomGeniusAnswer(address(geniusToken), PUBLISH_COST);
        
        // Transfer tokens to user
        geniusToken.transfer(user, 1000 ether);
        
        // Label addresses for better trace output
        vm.label(address(this), "Owner");
        vm.label(user, "User");
        vm.label(address(geniusToken), "GeniusToken");
        vm.label(address(foomGeniusAnswer), "FoomGeniusAnswer");
    }
    
    function test_PublishAnswer() public {
        string memory answer = "This is a genius answer!";
        
        // Switch to user context
        vm.startPrank(user);
        
        // Approve tokens
        geniusToken.approve(address(foomGeniusAnswer), PUBLISH_COST);
        
        // Get initial balances
        uint256 initialSupply = geniusToken.totalSupply();
        uint256 initialUserBalance = geniusToken.balanceOf(user);
        
        // Publish answer
        foomGeniusAnswer.publishAnswer(answer);
        
        // Verify token burning
        assertEq(geniusToken.totalSupply(), initialSupply - PUBLISH_COST, "Tokens not burned");
        assertEq(geniusToken.balanceOf(user), initialUserBalance - PUBLISH_COST, "User balance not decreased");
        
        // Verify answer storage
        (
            address publisher,
            string memory storedAnswer,
            uint256 timestamp,
            uint256 tokensBurned
        ) = foomGeniusAnswer.getAnswer(0);
        
        assertEq(publisher, user, "Wrong publisher");
        assertEq(storedAnswer, answer, "Wrong answer");
        assertEq(tokensBurned, PUBLISH_COST, "Wrong tokens burned amount");
        assertGt(timestamp, 0, "Invalid timestamp");
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_AnswerEmpty() public {
        vm.startPrank(user);
        vm.expectRevert("Answer cannot be empty");
        foomGeniusAnswer.publishAnswer("");
        vm.stopPrank();
    }
    
    function test_RevertWhen_AnswerTooLong() public {
        vm.startPrank(user);
        string memory longAnswer = new string(2001);
        vm.expectRevert("Answer too long");
        foomGeniusAnswer.publishAnswer(longAnswer);
        vm.stopPrank();
    }
    
    function test_UpdatePublishCost() public {
        uint256 newCost = 200 ether;
        foomGeniusAnswer.updatePublishCost(newCost);
        assertEq(foomGeniusAnswer.publishCost(), newCost, "Publish cost not updated");
    }
    
    function test_RevertWhen_NonOwnerUpdatesPublishCost() public {
        vm.startPrank(user);
        vm.expectRevert();  // Just check that it reverts
        foomGeniusAnswer.updatePublishCost(200 ether);
        vm.stopPrank();
    }
} 