### [H-1] TITLE: Storing the password on-chain makes it visible to anyone, and no longer private


**Description:** All data stored on-chain is visible to everyone, and can be called directly from the Blockchain. The `PasswordStore::s_password` is intended to be a private variable and only accessed through the `PasswordStore::getPassword` function, which is intended to be only called by the owner of the contract.

We show one more method of on-chain data below.

**Impact:** Anyone can read private password, severly breaking the functionality of the protocol. 

**Proof of Concept:** (Proof of Code)
1. Create a local running chain

```bash
  make anvil
```

2. Deploy contract to the chain

```
make deploy
```

3. Run the storage tool
Use the `1`. That is the storage slot of the `s_password` in the contract

```
cast storage <ADDRESS_HERE> 1 --rpc-url http://127.0.0.1:8545
```
You will get an output that looks like this:
`0x6d7950617373776f726400000000000000000000000000000000000000000014`

Then parse the the hex to the string with

```
ast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```
The output:

```
myPassword
```

**Recommended Mitigation:** Due to this the overall architecture of the contract should be rethought. One could encrypt the password off-chain, and then store the encrypt password on-chain. This would require the user to remember another password off-chain to decrypt the password. However ypu would likely want to remove the view function as you would not want the user to accidentally send a transaction with the password that decrypts your password.



### [I-1] TITLE: `PasswordStore::setPassword` has no access control, meaning a non owner can change the password.

**Description:** The `PasswordStore::setPassword` is not set to `external` function, however, the natspec of the function and overall purpose of the contract is that `This function allows only the owner to set a new password` 

```javascripts
   function setPassword(string memory newPassword) external {
@>   // @audit --> There are no access control
        s_password = newPassword;
        emit SetNetPassword();
    }
```

**Impact:** Anyone can set/change the password of the contract, severly breaking the contract intended functionality. 

**Proof of Concept:** Add the following to the `PasswordStore.t.sol` test file.

<details>

<summary>Code</summary>

```javascripts
    function test_anyone_can_set_the_password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        string memory expectedPassword = "myNewPassword";
        passwordStore.setPassword(expectedPassword);
       
       vm.prank(owner);
       string memory actualPassword = passwordStore.getPassword();
       assertEq(actualPassword, expectedPassword);
    }

```
</details>


**Recommended Mitigation:** Add an access control conditional to the `setPassword` function. 

```javascripts
    if (msg.sender != s_owner) {
          revert PasswordStore__NotOwner();
      }
```


### [S-#] The `Password::getPassword` natspec indicates a parameter that does not exist causing the natspec to be incorrect.

**Description:** 

```javascripts
  @notice This allows only the owner to retrieve the password.
  @param newPassword The new password to set.

  function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }

```

**Impact:** The `PasswordStore::getPassword` function signature is `getPassword` while the natspec says it would be `getPassword(string)`.

**Proof of Concept:** The natspec is incorrect

**Recommended Mitigation:** Remove the incorrect natspec line.

```diff
-  @param newPassword The new password to set.
```