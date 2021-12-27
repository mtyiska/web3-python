// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

// import "hardhat/console.sol";
contract SimpleStorage{
    uint256 public favoriteNumber;

    struct People{
        uint256 favoriteNumber;
        string name;
    }

    People[] public person;

    mapping(uint256 => string) public namepair;
    
   function store(uint256 _favoreiteNumber) public returns (uint256) {
       favoriteNumber = _favoreiteNumber;
       return favoriteNumber;
   }

    function retrieve() public view returns (uint256){
        return favoriteNumber;
    }

    function addPerson(string memory _name, uint256 _favoreiteNumber) public {
        person.push(People(_favoreiteNumber, _name));
        namepair[_favoreiteNumber] = _name;
    }

}
