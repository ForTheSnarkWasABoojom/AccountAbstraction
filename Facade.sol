// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./OperationLib.sol"; 

interface IBundler {
    function submitUserOp(OperationLib.Operation calldata op) external;
}

interface IReinvestmentManager {
    function isUser(uint256 userID_) external view returns (bool);
    function getUserLength() external view returns (uint256);
    function getUserBalance(uint256 userID_) external view returns (uint256);
    function getReinvestmentPeriod() external view returns (uint256 ID, uint256 start, uint256 end, uint256 rate, uint256 assetPrice, address currentAsset);
    function transferUserBatch(uint256[] memory userIDs_, address to_) external;
}

contract Facade {
    IReinvestmentManager public reinvestmentManager; 
    address public owner;
    IBundler public bundler;

    event NumberChanged(uint256 newNumber);
    event OperationSubmitted(uint256 newNumber);

    constructor(address _bundler, address _reinvestmentManager) {
        owner = msg.sender;
        bundler = IBundler(_bundler);

        reinvestmentManager = IReinvestmentManager(_reinvestmentManager);
    }

    modifier onlyOwner() { 
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function getUserLength() external view returns (uint256) {
        return reinvestmentManager.getUserLength();
    }

    function isUser(uint256 userID_) external view returns (bool) {
        return reinvestmentManager.isUser(userID_);
    }

    function transferUserBatch(uint256[] memory userIDs_, address to_) external {
        return reinvestmentManager.transferUserBatch(userIDs_, to_);
    }

    function submitSetRateOperation(uint256 _newRate) external onlyOwner {
        OperationLib.Operation memory op;
        op.clientAddress = address(this);
        op.newNumber = _newRate;
        op.isExecuted = false;
        op.operationType = "setRate";

        bundler.submitUserOp(op);
    }

    function submitAddUserBatchOperation(uint256[] memory userIds_, string[] memory salts_,
        uint256[] memory balances_) external onlyOwner {
        OperationLib.Operation memory op;
        op.clientAddress = address(this);
        op.isExecuted = false;
        op.operationType = "addUserBatch";
        op.ids = userIds_;
        op.salts = salts_;
        op.balances = balances_;

        bundler.submitUserOp(op);
    }

    function submitReinvestSavingsOperation() external onlyOwner {
        OperationLib.Operation memory op;
        op.clientAddress = address(this);
        op.isExecuted = false;
        op.operationType = "reinvestSavings";

        bundler.submitUserOp(op);
    }

    function submitSetAssetPriceOperation(uint256 _newAssetPrice) external onlyOwner {
        OperationLib.Operation memory op;
        op.clientAddress = address(this);
        op.newNumber = _newAssetPrice;
        op.isExecuted = false;
        op.operationType = "setAssetPrice";

        bundler.submitUserOp(op);
    }

}