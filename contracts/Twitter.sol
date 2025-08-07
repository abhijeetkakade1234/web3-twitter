// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ✅ Contract to act as our backend for Web3 Twitter
contract Twitter {
    struct Tweet {
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
        bool isRetweet;
        bool isQuote;
        address originalAuthor;
        uint256 originalTweetIndex;
    }

    // ✅ Tweets organized per user
    mapping(address => Tweet[]) public tweets;

    // ✅ Global feed of all tweets
    // TODO: Add a global list of tweets
    Tweet[] public allTweets;

    // ✅ Tweet ID system
    // TODO: Add tweetCounter and mapping by ID
    // uint public tweetCounter;
    // mapping(uint => Tweet) public tweetById;
    uint256 public tweetCounter;
    mapping(uint256 => Tweet) public tweetById;

    // ✅ User profile system
    struct Profile {
        string username;
        string bio;
        string avatar; // store IPFS or image URL
    }

    mapping(address => Profile) public profiles;

    // ✅ Follow system
    // TODO: Add followers/following logic
    mapping(address => address[]) public followers;
    mapping(address => address[]) public following;
    mapping(address => mapping(address => bool)) public isFollowing;

    // ✅ Events
    event NewTweet(address indexed author, string content, uint256 timestamp);
    // TODO: Add more events: Followed, Unfollowed, Retweet, QuoteTweet
    event Followed(address indexed follower, address indexed followed);
    event Unfollowed(address indexed follower, address indexed unfollowed);
    event ReTweet(address indexed author, string content, uint256 timestamp);
    event QuoteTweet(address indexed author, string content, uint256 timestamp);

    // ✅ Post a tweet
    function postTweet(string calldata _content) public {
        require(bytes(_content).length > 0, "Content cannot be empty");
        require(bytes(_content).length <= 280, "Content length must be <= 280");

        Tweet memory newTweet = Tweet({
            author: msg.sender,
            content: _content,
            timestamp: block.timestamp,
            likes: 0,
            isRetweet: false,
            isQuote: false,
            originalAuthor: address(0),
            originalTweetIndex: 0
        });

        tweets[msg.sender].push(newTweet);

        // TODO: Push to allTweets and store in tweetById;
        allTweets.push(newTweet);
        tweetById[tweetCounter] = newTweet;
        tweetCounter++;

        emit NewTweet(msg.sender, _content, block.timestamp);
    }

    function getMyTweets() public view returns (Tweet[] memory) {
        return tweets[msg.sender];
    }

    function getTweetCount() public view returns (uint256) {
        return tweets[msg.sender].length;
    }

    function getTweetById(uint id) public view returns (Tweet memory) {
    return tweetById[id];
    }


    function setProfile(
        string calldata _username,
        string calldata _bio,
        string calldata _avatar
    ) public {
        require(bytes(_username).length > 0, "Username cannot be empty");

        profiles[msg.sender] = Profile({
            username: _username,
            bio: _bio,
            avatar: _avatar
        });
    }

    function getProfile(address user)
        public
        view
        returns (
            string memory,
            string memory,
            string memory
        )
    {
        return (
            profiles[user].username,
            profiles[user].bio,
            profiles[user].avatar
        );
    }

    // ✅ Like functionality
    event TweetLiked(address liker, address tweetOwner, uint256 tweetIndex);
    mapping(address => mapping(address => mapping(uint256 => uint8))) likedTweets;

    function likeTweet(address tweetOwner, uint256 tweetIndex) public {
        require(
            hasLiked(tweetOwner, tweetIndex, msg.sender) == false,
            "Already liked"
        );
        tweets[tweetOwner][tweetIndex].likes++;
        likedTweets[msg.sender][tweetOwner][tweetIndex] = 1;
        emit TweetLiked(msg.sender, tweetOwner, tweetIndex);
    }

    function unlikeTweet(address tweetOwner, uint256 tweetIndex) public {
        require(
            hasLiked(tweetOwner, tweetIndex, msg.sender) == true,
            "Not liked yet"
        );
        tweets[tweetOwner][tweetIndex].likes--;
        likedTweets[msg.sender][tweetOwner][tweetIndex] = 0;
    }

    function hasLiked(
        address tweetOwner,
        uint256 tweetIndex,
        address user
    ) public view returns (bool) {
        return likedTweets[user][tweetOwner][tweetIndex] == 1;
    }

    function getTweet(address tweetOwner, uint256 tweetIndex)
        public
        view
        returns (
            address,
            string memory,
            uint256,
            uint256
        )
    {
        Tweet memory t = tweets[tweetOwner][tweetIndex];
        return (t.author, t.content, t.timestamp, t.likes);
    }

    // ✅ TODO: Retweet a tweet
    // function retweet(address originalAuthor, uint tweetIndex) public {
    //   - Get original tweet
    //   - Create a new tweet marked as isRetweet = true
    //   - Add to sender's tweets, and global feed
    //   - Emit NewTweet event with retweet content
    // }
    function retweet(address originalAuthor, uint256 tweetIndex) public {
        Tweet memory originalTweet = tweets[originalAuthor][tweetIndex];

        Tweet memory reTweet = Tweet({
            author: msg.sender,
            content: originalTweet.content,
            timestamp: block.timestamp,
            likes: 0,
            isRetweet: true,
            isQuote: false,
            originalAuthor: originalAuthor,
            originalTweetIndex: tweetIndex
        });
        tweets[msg.sender].push(reTweet);
        allTweets.push(reTweet);
        tweetById[tweetCounter] = reTweet;
        tweetCounter++;
        emit ReTweet(msg.sender, reTweet.content, block.timestamp);
    }

    // ✅ TODO: Quote tweet
    // function quoteTweet(address originalAuthor, uint tweetIndex, string calldata quoteText) public {
    //   - Similar to retweet, but include custom content
    //   - Store originalAuthor and tweetIndex
    // }
    function quoteTweet(
        address originalAuthor,
        uint256 tweetIndex,
        string calldata quoteText
    ) public {
        Tweet memory newQuoteTweet = Tweet({
            author: msg.sender,
            content: quoteText,
            timestamp: block.timestamp,
            likes: 0,
            isRetweet: false,
            isQuote: true,
            originalAuthor: originalAuthor,
            originalTweetIndex: tweetIndex
        });
        tweets[msg.sender].push(newQuoteTweet);
        allTweets.push(newQuoteTweet);
        tweetById[tweetCounter] = newQuoteTweet;
        tweetCounter++;
        emit QuoteTweet(msg.sender, newQuoteTweet.content, block.timestamp);
    }

    // ✅ TODO: Follow a user
    // function follow(address userToFollow) public {
    //   - Prevent self-follow
    //   - Check not already following
    //   - Add to following[msg.sender] and followers[userToFollow]
    //   - Mark isFollowing[msg.sender][userToFollow] = true
    //   - Emit Followed event
    // }
    function follow(address userToFollow) public {
        require(msg.sender != userToFollow, "Cannot follow yourself");
        require(!isFollowing[msg.sender][userToFollow], "Already following");
        following[msg.sender].push(userToFollow);
        followers[userToFollow].push(msg.sender);
        isFollowing[msg.sender][userToFollow] = true;
        emit Followed(msg.sender, userToFollow);
    }

    // ✅ TODO: Unfollow a user
    // function unfollow(address userToUnfollow) public {
    //   - Ensure currently following
    //   - Remove from arrays and set isFollowing false
    //   - Emit Unfollowed event
    // }
    function unfollow(address userToUnfollow) public {
        require(isFollowing[msg.sender][userToUnfollow], "Not following");
        isFollowing[msg.sender][userToUnfollow] = false;
        for (uint256 i = 0; i < following[msg.sender].length; i++) {
            if (following[msg.sender][i] == userToUnfollow) {
                following[msg.sender][i] = following[msg.sender][
                    following[msg.sender].length - 1
                ];
                following[msg.sender].pop();
                break;
            }
        }
        for (uint256 i = 0; i < followers[userToUnfollow].length; i++) {
            if (followers[userToUnfollow][i] == msg.sender) {
                followers[userToUnfollow][i] = followers[userToUnfollow][
                    followers[userToUnfollow].length - 1
                ];
                followers[userToUnfollow].pop();
                break;
            }
        }

        emit Unfollowed(msg.sender, userToUnfollow);
    }

    // ✅ TODO: Get tweets from people you follow
    // function getFeed() public view returns (Tweet[] memory) {
    //   - Loop through following[msg.sender]
    //   - Collect latest tweets
    //   - Return combined tweet list
    // }
    function getFeed() public view returns (Tweet[] memory) {
        uint256 total = 0;

        // First, calculate how many tweets we need to allocate
        for (uint256 i = 0; i < following[msg.sender].length; i++) {
            total += tweets[following[msg.sender][i]].length;
        }

        Tweet[] memory feed = new Tweet[](total);
        uint256 index = 0;

        for (uint256 i = 0; i < following[msg.sender].length; i++) {
            address user = following[msg.sender][i];
            for (uint256 j = 0; j < tweets[user].length; j++) {
                feed[index] = tweets[user][j];
                index++;
            }
        }

        return feed;
    }

    // ✅ TODO: Get global feed
    // function getGlobalTweets() public view returns (Tweet[] memory) {
    //   - Return allTweets array
    // }
    function getGlobalTweets() public view returns (Tweet[] memory) {
        return allTweets;
    }

    // ✅ TODO: Search profiles by username (optional feature)
}
