// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Moneda is ERC20("Token Moneda", "TM"), Ownable {

    function emitir(address destino, uint cantidad) public onlyOwner {
        _mint(destino, cantidad);
    }
}