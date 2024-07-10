// SPDX-License-Identifier: MIT

// @audit --> Is this the correct solidity compiler version?
// compiler version issues?
pragma solidity 0.8.18; 


/*
 * @author not-so-secure-dev
 * @title PasswordStore 
 * @notice This contract allows you to store a private password that others won't be able to see. 
 * You can update your password at any time.
 */
contract PasswordStore {
    error PasswordStore__NotOwner();

    address private s_owner; // slot 0
    // @audit --> This is not actually private. This is not safe to store the password in.
    string private s_password; // slot 1  

    event SetNetPassword();

    constructor() {
        s_owner = msg.sender;
    }

    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */

    // @audit --> can any body set the password?
    // Access control issues?
    function setPassword(string memory newPassword) external {
        s_password = newPassword;
        emit SetNetPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.

     // @audit --> The documentation is not implememented in this function
     * @param newPassword The new password to set.
     */
    
    // @audit --> can any body get/retrieve the password?
    // access modifier issues?
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
}