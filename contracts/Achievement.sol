// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Achievement is ERC721("Token Achievement", "TA"), Ownable {
    uint ultimoIndice;

    function emitir(address destino) public onlyOwner returns(uint) {
        uint indice = ultimoIndice;
        _safeMint(destino, indice);
        ultimoIndice++;
        return indice;
    }
}