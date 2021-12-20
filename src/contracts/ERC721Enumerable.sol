// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./interfaces/IERC721Enumerable.sol";

contract ERC721Enumerable is IERC721Enumerable, ERC721 {
    uint256[] private _allTokens;

    //map tokenId to position in _allTOkens
    mapping(uint256 => uint256) private _allTokensIndex;
    //map of tokenIds owned by address
    mapping(address => uint256[]) private _ownedTokens;
    // map from tokenId index of _ownedTokens
    mapping(uint256 => uint256) private _ownedTokensIndex;

    //function tokenByIndex(uint256 _index) external view returns (uint256);

    //function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
    constructor() {
        _registerInterface(
            bytes4(
                keccak256("tokenByIndex(bytes4)") ^
                    keccak256("totalSupply(bytes4)") ^
                    keccak256("tokenOfOwnerByIndex(bytes4)")
            )
        );
    }

    function _mint(address to, uint256 tokenId) internal override(ERC721) {
        super._mint(to, tokenId);

        _addTokensToAllTokenEnumeration(tokenId);
        _addTokensToOwnerEnumeration(to, tokenId);
    }

    //adding tokens and setting position of indexes to _allTokens array
    function _addTokensToAllTokenEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _addTokensToOwnerEnumeration(address to, uint256 tokenId) private {
        // add adress and token id to the  _ownedTokens
        // ownedTokensIndex tokenId set to address of ownedTokens position

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function tokenByIndex(uint256 index)
        public
        view
        override
        returns (uint256)
    {
        require(index < totalSupply(), "Gloobal index is out of bounds!");
        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        override
        returns (uint256)
    {
        require(index < balanceOf(owner), "owner index is out of bounds!");
        return _ownedTokens[owner][index];
    }

    // return the total supply of the _allTokens array
    function totalSupply() public view override returns (uint256) {
        return _allTokens.length;
    }
}
