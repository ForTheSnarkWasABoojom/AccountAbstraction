// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./OperationLib.sol"; 

interface IEntryPoint {
    function handleOps(OperationLib.Operation[] calldata users) external;
}

contract Bundler {
    address public entryPoint;
    address public owner;

    OperationLib.Operation[] public pendingOperations;
    uint256 public batchSize;

    event UserOpReceived(address clientAddress, uint256 newNumber);
    event UserOpsBundled(uint256[] operationIds);

    constructor(address _entryPoint,  uint256 _batchSize) {
        entryPoint = _entryPoint;
        owner = msg.sender;
        batchSize = _batchSize;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function bundleAndSubmit() external {
        require(pendingOperations.length > 0, "No operations to bundle");

        uint256 opsToProcess = pendingOperations.length > batchSize ? batchSize : pendingOperations.length;

        OperationLib.Operation[] memory operations = new OperationLib.Operation[](opsToProcess);

        for (uint256 i = 0; i < opsToProcess; i++) {
            uint256 index = pendingOperations.length - 1;
            operations[i] = pendingOperations[index];
            pendingOperations.pop();
        }

        IEntryPoint(entryPoint).handleOps(operations);
    }

    function getPendingOpsNumber() external view returns (uint256) {
        return  pendingOperations.length;
    }

    function submitUserOp(OperationLib.Operation calldata op) external {
        pendingOperations.push(op);

        if (pendingOperations.length >= batchSize) {
            this.bundleAndSubmit();
        }
    }

    function forceBundle() external onlyOwner {
        this.bundleAndSubmit();
    }

    function setBatchSize(uint256 newBatchSize) external onlyOwner {
        batchSize = newBatchSize;
    }
}