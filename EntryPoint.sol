// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./OperationLib.sol"; 

interface IReinvestmentManager{
    function setRate(uint256 rate_) external;
    function reinvestSavings() external;
    function setAssetPrice(uint256 price_) external;
    function addUserBatch(uint256[] memory userIDs_, string[] memory salt_, uint256[] memory balance_) external;
}

contract EntryPoint {
    IReinvestmentManager public reinvestmentManager; 
    address public owner;
    uint256 public signatureThreshold;

    mapping(uint256 => address[]) internal signers;
    mapping(uint256 => OperationLib.Operation) internal operations;
    uint256 public operationCount;

    mapping(address => bool) public isTrustedSigner;


    constructor(address _reinvestmentManager, uint256 _signatureThreshold) {
        owner = msg.sender;
        isTrustedSigner[owner] = true;
        signatureThreshold = _signatureThreshold;
        reinvestmentManager = IReinvestmentManager(_reinvestmentManager);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyTrustedSigner() {
        require(isTrustedSigner[msg.sender], "Not a trusted signer");
        _;
    }

    function changeThreshold(uint256 _signatureThreshold) external onlyTrustedSigner {
        signatureThreshold = _signatureThreshold;
    }

    function addTrustedSigner(address signer) external onlyTrustedSigner {
        require(!isTrustedSigner[signer], "Signer already trusted");
        isTrustedSigner[signer] = true;
    }

    function removeTrustedSigner(address signer) external onlyOwner {
        require(isTrustedSigner[signer], "Signer not trusted");
        isTrustedSigner[signer] = false;
    }

    function getSignatures(uint256 id) external view returns (address[] memory) {
        return signers[id];
    }

    function getOperationInfo(uint256 operationId) external view returns (OperationLib.Operation memory) {
        return operations[operationId];
    }

    function handleOps(OperationLib.Operation[] calldata _operations) external{
        for (uint256 i = 0; i < _operations.length; i++) {
            uint256 opId = operationCount++;
            operations[opId] = _operations[i];
        }
    }

    function signOp(uint256 operationId) external onlyTrustedSigner {
        OperationLib.Operation storage op = operations[operationId];

        require(!op.isExecuted, "Operation already executed");

        signers[operationId].push(msg.sender);
        if (signers[operationId].length >= signatureThreshold) {
            op.isExecuted = true;

            if (keccak256(abi.encodePacked(op.operationType)) == keccak256(abi.encodePacked("setRate"))) {
                reinvestmentManager.setRate(op.newNumber);
            } else if (keccak256(abi.encodePacked(op.operationType)) == keccak256(abi.encodePacked("reinvestSavings"))) {
                reinvestmentManager.reinvestSavings();
            } else if (keccak256(abi.encodePacked(op.operationType)) == keccak256(abi.encodePacked("setAssetPrice"))) {
                reinvestmentManager.setAssetPrice(op.newNumber);
            } else if (keccak256(abi.encodePacked(op.operationType)) == keccak256(abi.encodePacked("addUserBatch"))) {
                reinvestmentManager.addUserBatch(op.ids, op.salts, op.balances);
            } else {
                revert("Unknown operation type");
            }
        }
    }
}