// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PubliCNovel is ERC1155, Ownable {
    //to see who has written once on the novel(we could club them both together)
    mapping (address => bool) hasWritten;
    mapping(uint256=>string) contentWrittenId;

    bytes32 private _controlCheck;
    uint256 private  costOfPublish;
    string[] public listOfChapters;

    using Counters for Counters.Counter;
    Counters.Counter private _Counter;

    constructor(string memory controlCheckValue) ERC1155("") {
        //this hash will be used so that others cant use our contract, can be used only from our website. :)
        //here the input string is converted to a bytes value using abi,encodedPacked
        _controlCheck=keccak256(abi.encodePacked(controlCheckValue));
        costOfPublish=30000000000000;
    }

    //saving information to the contract
    function saveTextBlock(string memory uri, string memory _controlCheckInput) public payable{

        require(hasWritten[msg.sender]==false,"you have already written to this contract");

        //should be about the price of 0.0003 ether
        require(msg.value>=costOfPublish,"insufficient funds");

        require(_controlCheck==keccak256(abi.encodePacked(_controlCheckInput)),"this function can be used only within the given website");

        //this address has written to this contract
        hasWritten[msg.sender]=true;
        //this counter as written the given metadata, 
        contentWrittenId[_Counter.current()]=uri;
        listOfChapters.push(uri);
        _Counter.increment();

    }

    function withdraw() public onlyOwner {
        require(address(this).balance>0,"no funds in contract");
        (bool success,) =payable (msg.sender).call{
            value:address(this).balance
            }("");
        require(success,"something went wrong");
    }

    function getInfo() public view returns(string[] memory){
        return listOfChapters;
    }

}