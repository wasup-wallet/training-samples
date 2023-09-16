// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./Achievement.sol";
import "./Moneda.sol";

contract TicTacToe {

    // Variables
    struct Partida {
        address jugador1;
        address jugador2;
        address ganador;
        uint[4][4] jugadas;
        address ultimoTurno;
    }
    Partida[] partidas;
    mapping (address => uint) partidasGanadas;
    Achievement achievement;
    Moneda moneda;

    // Constructor
    constructor(address contratoAchievement, address contratoMoneda) {
        achievement = Achievement(contratoAchievement);
        moneda = Moneda(contratoMoneda);
    }

    // Public Functions
    function crearPartida(address jug1, address jug2) public returns (uint) {
        require(jug1 != jug2);
        uint idPartida = partidas.length;
        Partida memory partida;
        partida.jugador1 = jug1;
        partida.jugador2 = jug2;
        partidas.push(partida);
        return idPartida;
    }

    function jugar(uint idPartida, uint horizontal, uint vertical) public {
        // validaciones
        Partida memory partida = partidas[idPartida];
        require(msg.sender == partida.jugador1 || msg.sender == partida.jugador2);
        require(horizontal > 0 && horizontal < 4);
        require(vertical > 0  && horizontal < 4);
        require(msg.sender != partida.ultimoTurno);
        require(partida.jugadas[horizontal][vertical] == 0);
        require(! partidaTerminada(partida));

        // guardar la jugada
        guardarMovimiento(idPartida, horizontal, vertical);
        // actualizar partida
        partida = partidas[idPartida];

        // chequear si hay un ganador (ganador != 0) o si la grilla esta llena
        uint ganador = obtenerGanador(partida);
        if (ganador != 0) {
            guardarGanador(ganador, idPartida);
        }

        partidas[idPartida].ultimoTurno = msg.sender;
    }

    function verPartida(uint idPartida) public view returns (uint[4][4] memory) {
        return partidas[idPartida].jugadas;
    }

    // Private functions
    function guardarGanador(uint ganador, uint idPartida) private {
        if (ganador == 1) partidas[idPartida].ganador = partidas[idPartida].jugador1;
        else partidas[idPartida].ganador = partidas[idPartida].jugador2;

        // Give achievement ERC721
        partidasGanadas[partidas[idPartida].ganador]++;
        if (partidasGanadas[partidas[idPartida].ganador] == 5) {
            achievement.emitir(partidas[idPartida].ganador);
        }
        // Give extra achievement ERC721
        if (chequearGrillaCompleta(partidas[idPartida].jugadas)) {
            achievement.emitir(partidas[idPartida].ganador);
        }

        // Give extra ERC20 token because has achievement
        if (achievement.balanceOf(partidas[idPartida].ganador) > 0) {
            moneda.emitir(partidas[idPartida].ganador, 2);
        } else {
            moneda.emitir(partidas[idPartida].ganador, 1);
        }
    }

    /**
     * Check if exist a winning move
     * return 1 (jug1) or 2 (jug2)
     */
    function chequearLinea(uint[4][4] memory jugadas, uint x1, uint y1, uint x2, uint y2, uint x3, uint y3) private pure returns (uint) {
        if ((jugadas[x1][y1] == jugadas[x2][y2]) && (jugadas[x2][y2] == jugadas[x3][y3]))
            return jugadas[x1][y1];
        return 0;
    }

    /**
     * Check completed grid
     * return true o false
     */
    function chequearGrillaCompleta(uint[4][4] memory jugadas) private pure returns (bool) {
        for (uint x = 1; x < 4; x++) {
            for (uint y = 1 ; y < 4; y++) {
                if (jugadas[x][y] == 0) return false;
            }
        }
        return true;
    }

    /**
     * Get winner
     * return 0: no winner, 1: jug1, 2: jug2
     */
    function obtenerGanador(Partida memory partida) private pure returns (uint) {
        // check diagonal
        uint ganador = chequearLinea(partida.jugadas, 1, 1, 2, 2, 3, 3);
        // check otra diagonal
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 3, 1, 2, 2, 1, 3);
        // check cols
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 1, 1, 1, 2, 1, 3);
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 2, 1, 2, 2, 2, 3);
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 3, 1, 3, 2, 3, 3);
        // check rows
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 1, 1, 2, 1, 3, 1);
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 1, 2, 2, 2, 3, 2);
        if (ganador == 0) ganador = chequearLinea(partida.jugadas, 1, 3, 2, 3, 3, 3);
        return ganador;
    }

    function guardarMovimiento(uint idPartida, uint h, uint v) private {
        if (msg.sender == partidas[idPartida].jugador1) partidas[idPartida].jugadas[h][v] = 1;
        else partidas[idPartida].jugadas[h][v] = 2;
    }

    function partidaTerminada(Partida memory partida) private pure returns(bool) {
        if (partida.ganador != address(0)) return true;
        for (uint x = 1; x < 4; x++) {
            for (uint y = 1; y < 4; y++) {
                if (partida.jugadas[x][y] == 0) return false;
            }
        }
        return true;
    }
}