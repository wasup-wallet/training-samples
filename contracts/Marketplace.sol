// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Marketplace {
    // variables
    mapping(uint => uint) valores;
    IERC721 achievements;
    IERC20 moneda;

    constructor(address contratoAchievement, address contratoMoneda) {
        achievements = IERC721(contratoAchievement);
        moneda = IERC20(contratoMoneda);
    }

    function publicar(uint tokenId, uint valor) public {
        require(valores[tokenId] == 0);
        require(valor > 0);
        // validar que el contrato Marketplace tiene permisos para transferir el token
        require(achievements.getApproved(tokenId) == address(this));

        valores[tokenId] = valor;
    }

    function comprar(uint tokenId) public {
        // validar que el tokenId esta publicado
        require(valores[tokenId] > 0);
        // validar si el usuario habilitó este contrato para que pueda utilizar los fondos
        require(moneda.allowance(msg.sender, address(this)) >= valores[tokenId]);
        // validar que el usuario que publico no revoco los permisos de venta
        require(achievements.getApproved(tokenId) == address(this));
        // realizar transferencia
        moneda.transferFrom(msg.sender, achievements.ownerOf(tokenId), valores[tokenId]);
        // transferir el logro
        achievements.safeTransferFrom(achievements.ownerOf(tokenId), msg.sender, tokenId);
        // valores en 0
        valores[tokenId] = 0;
    }
}
