// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import './Session.sol';
contract Main{
    
     address public admin;
     // from address of Participants can return information of Participants
     mapping(address => Participant) public participants;
    //The smart contract should contain the hash of all the pricing sessions.
    Session[] public sessions;
    // from address of Session can return information of Session
     mapping(address => bool) public isSession;
    // Structure to hold details of Bidder
    struct IParticipant {
        address account;
        string fullName;
        string email;
        uint256 numberOfJoinedSession;
        uint256 deviation;
    }
     constructor (){
        admin = msg.sender
     }
    /// @notice Modifier to allow only the admin to perform certain actions.
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action.");
        _;
    }
    //------------------------ Session -------------------------
    /// @notice Creates a new auction session for a product.
    /// @dev This function can only be called by the admin.
    /// @param _productName The name of the product for the auction session.
    /// @param _productDescription The description of the product for the auction session.
    /// @param _productImages An array of image URLs for the product.
    /// @param _sessionDuration The duration of the auction session in seconds.
    /// @return Returns the newly created Session contract.
    function createNewSession(
        string memory _productName,
        string memory _productDescription,
        string[] memory _productImages,
        uint256 _sessionDuration
    ) external onlyAdmin returns(Session) {
        // Create a new Session contract
        Session newSession = new Session(
            address(this),
            admin,
            _productName,
            _productDescription,
            _productImages,
            0,
            0,
            _sessionDuration
        );

        // Add the new Session to the sessions array
        sessions.push(newSession);

        // Mark the new Session as valid
        isSession[address(newSession)] = true;

        return newSession;
    }
    /// @notice Gets the information of a specific auction session.
    /// @param _sessionIndex The index of the session in the sessions array.
    /// @return Returns the information of the session.
    function getSessionInfo(uint256 _sessionIndex) public view returns (
        string memory productName,
        string memory productDescription,
        string[] memory productImages,
        uint256 startingPrice,
        uint256 currentPrice,
        uint256 sessionDuration
    ) {
        require(_sessionIndex < sessions.length, "Invalid session index.");

        Session session = sessions[_sessionIndex];
        return session.getInfo();
    }
     //---------------------- Participants --------------------

    /// @notice Registers a new participant into the system.
    /// @dev This function requires that the sender's address has not been previously registered.
    /// @param _fullName The full name of the participant.
    /// @param _email The email address of the participant.
    /// @return Returns 'true' if the registration is successful.
    function registerParticipant(string memory _fullName, string memory _email) external  returns(bool) {
        // Ensure the address has not been registered before
        require(participant[msg.sender].account == address(0), "Address already registered.");

        // Create a new Participant struct and store it in the mapping
        IParticipant memory newParticipant = IParticipant({
            account: msg.sender,
            fullName: _fullName,
            email: _email,
            numberOfJoinedSession: 0,
            deviation: 0
        });
        // Store the participant information in the mapping
        participant[msg.sender] = newParticipant;

        // Add the participant's address to the array of keys
        listKeyParticipants.push(msg.sender);
        
        //successfull register
        return true;
    }

    /// @notice Get the information of a participant.
    /// @param _account The address of the participant.
    /// @return The Participant struct associated with the address.
    function getParticipant(address _account) external  view returns (IParticipant memory) {
        return participant[_account];
    }
    
       function checkRegistered()
        external
        view
        validParticipant
        returns (address)
    {
        return msg.sender;
    }
    //--------------------------------------------
}