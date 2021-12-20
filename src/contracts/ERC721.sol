// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC165.sol";
import "./interfaces/IERC721.sol";

/*
  a. nft to point to an address.
  b. Keep track of the tokens ids.
  c. Keep track of token owner addresses to token ids.
  d. keep track of how many tokens and owner address has.
  e. create an event that emits a tranferlog of contract address, mint destination and token id


 */

contract ERC721 is ERC165, IERC721 {
    //mapping from token id to the owner address
    mapping(uint256 => address) private _tokenOwner;

    mapping(address => uint256) private _tokensHeld;

    mapping(uint256 => address) private _tokenApprovals;

    //mapping from tokenId to approved address
    mapping(address => mapping(address => bool)) private _operatorApprovals;

        constructor() {
        _registerInterface(bytes4(keccak256("balanceOf(bytes4)")^keccak256("ownerOf(bytes4)")^keccak256("transferFrom(bytes4)")));
    }

    function balanceOf(address _owner) public view override returns (uint256) {
        require(_owner != address(0), "owner query for non-existent token");
        return _tokensHeld[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), "Oops, query for non-existent token");

        return owner;
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        //setting the address of the nft owner to check the mapping
        // of the address from _tokenOwner passed with the tokenId
        address owner = _tokenOwner[tokenId];
        // return truthy if the address is not 0
        return owner != address(0);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        // requires that address is not 0 and that token does not already _exists
        require(to != address(0), "ERC721: minting to the zero address");
        require(!_exists(tokenId), "ERC721: Token already minted");

        // adding the new addres of the one calling the function and and setting a tokenId to that specif addres
        _tokenOwner[tokenId] = to;

        // keep track of each address that has minted and 1++
        _tokensHeld[to] += 1;

        emit Transfer(address(0), to, tokenId);
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        require(
            _to != address(0),
            "Error, ERC721 Transfer to the zero address"
        );
        require(
            ownerOf(_tokenId) == _from,
            "Trying to transfer a token to an address that doesnt exist"
        );

        _tokensHeld[_from] -= 1;
        _tokensHeld[_to] += 1;

        _tokenOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _transferFrom(_from, _to, _tokenId);
    }

    // 1 . require that the approver is the owner
    // 2. we are approving an address to ta token (tokenId)
    // 3. require that we cant approve sending token to the same address as the one calling
    //4. update the map of the aproval addresses
    function approve(address _to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(_to != owner, "Error, cant approve sending to yourself");
        require(msg.sender == owner, "Error, you dont own this token");
        _tokenApprovals[tokenId] = _to;
        emit Approval(owner, _to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(_exists(tokenId), "tokens does not exist");
        address owner = ownerOf(tokenId);

        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }
}
