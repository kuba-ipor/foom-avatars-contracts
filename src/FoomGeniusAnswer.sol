// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title FoomGeniusAnswer
 * @dev Contract for publishing genius answers with token burning mechanism
 */
contract FoomGeniusAnswer is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // The genius token used for payments
    ERC20Burnable public geniusToken;
    
    // Cost in genius tokens to publish an answer
    uint256 public publishCost;
    
    // Structure to store answer details
    struct Answer {
        address publisher;
        string answer;
        uint256 timestamp;
        uint256 tokensBurned;
    }
    
    // Mapping to store answers by their IDs
    mapping(uint256 => Answer) public answers;
    uint256 public totalAnswers;
    
    // Events
    event AnswerPublished(
        uint256 indexed answerId,
        address indexed publisher,
        string answer,
        uint256 tokensBurned,
        uint256 timestamp
    );
    event PublishCostUpdated(uint256 newCost);
    
    /**
     * @dev Constructor to initialize the contract
     * @param _geniusToken Address of the genius token contract
     * @param _initialPublishCost Initial cost to publish an answer
     */
    constructor(
        address _geniusToken,
        uint256 _initialPublishCost
    ) Ownable(msg.sender) {
        require(_geniusToken != address(0), "Invalid token address");
        require(_initialPublishCost > 0, "Invalid publish cost");
        
        geniusToken = ERC20Burnable(_geniusToken);
        publishCost = _initialPublishCost;
    }
    
    /**
     * @dev Publish a new genius answer
     * @param _answer The answer text to publish
     */
    function publishAnswer(string memory _answer) external nonReentrant {
        require(bytes(_answer).length > 0, "Answer cannot be empty");
        require(bytes(_answer).length <= 2000, "Answer too long");
        
        // Transfer tokens from user to this contract
        geniusToken.transferFrom(msg.sender, address(this), publishCost);
        
        // Burn the tokens
        geniusToken.burn(publishCost);
        
        // Create new answer
        uint256 answerId = totalAnswers;
        answers[answerId] = Answer({
            publisher: msg.sender,
            answer: _answer,
            timestamp: block.timestamp,
            tokensBurned: publishCost
        });
        
        totalAnswers++;
        
        emit AnswerPublished(
            answerId,
            msg.sender,
            _answer,
            publishCost,
            block.timestamp
        );
    }
    
    /**
     * @dev Update the cost of publishing an answer
     * @param _newCost New cost in genius tokens
     */
    function updatePublishCost(uint256 _newCost) external onlyOwner {
        require(_newCost > 0, "Invalid publish cost");
        publishCost = _newCost;
        emit PublishCostUpdated(_newCost);
    }
    
    /**
     * @dev Get answer details by ID
     * @param _answerId The ID of the answer to retrieve
     */
    function getAnswer(uint256 _answerId) external view returns (
        address publisher,
        string memory answer,
        uint256 timestamp,
        uint256 tokensBurned
    ) {
        require(_answerId < totalAnswers, "Answer does not exist");
        Answer memory a = answers[_answerId];
        return (a.publisher, a.answer, a.timestamp, a.tokensBurned);
    }
} 