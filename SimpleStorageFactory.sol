// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./SimpleStorage.sol";

contract StrorageFactory {
    SimpleStorage[] public simpleStorageArray;

    function createSimpleStorageContract() public {
        simpleStorageArray.push(new SimpleStorage());
    }

    // choose which storage you want to work with based on index
    function sfStore (uint256 _simpleStorageIndex, uint256 _simplestorageNumber) public {
        // Address of contract
        // ABI
        SimpleStorage s = SimpleStorage(address(simpleStorageArray[_simpleStorageIndex]));
        s.store(_simplestorageNumber);
    }

    function sfGet (uint256 _sfIndex) public view returns (uint256){
        return SimpleStorage(address(simpleStorageArray[_sfIndex])).retrieve();
    }

}
