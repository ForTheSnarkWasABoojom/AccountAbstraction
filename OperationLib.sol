// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library OperationLib {
    struct Operation {
        address clientAddress;
        bool isExecuted;
        string operationType;
        uint256 newNumber;
        address to;
        uint256[] ids;
        string [] salts;
        uint256[] balances;   
    }
}