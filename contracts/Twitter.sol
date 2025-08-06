// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ✅ Contract to act as our backend for Web3 Twitter
contract Twitter {

    struct Tweet{
        address author;
        string content;
        uint timestamp;
        uint likes;
    }

    // Declare an array to store all tweets (e.g., Tweet[] public tweets;)
    mapping (address => Tweet[]) public tweets;

    // Define an event called `NewTweet` that logs:
    event NewTweet (address indexed author, string content, uint timestamp);


    // Create a function named `postTweet`
    function postTweet(string calldata _content) public {
        require(bytes(_content).length > 0 , "Content cannot be empty");
        require(bytes(_content).length <= 280, "Content length must be <= 280");

        Tweet memory newTweet = Tweet({
            author: msg.sender,
            content: _content,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(newTweet);

        emit NewTweet(msg.sender, _content, block.timestamp);
    }

    //Create a function `getAllTweets` that:
    function getAllTweets() public view returns (Tweet[] memory) {
        return tweets[msg.sender];
    }

    // Write a public view function `getTweetCount` that returns tweet count
    function getTweetCount() public view returns (uint) {
        return tweets[msg.sender].length;
    }

}
