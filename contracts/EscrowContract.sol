// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EscrowContract {
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }

    struct Transaction {
        address payable buyer;
        address payable seller;
        uint256 amount;
        State state;
    }

    mapping(uint256 => Transaction) public transactions;
    uint256 public transactionCount;

    event TransactionCreated(uint256 indexed transactionId, address buyer, address seller, uint256 amount);
    event PaymentReceived(uint256 indexed transactionId);
    event ItemDelivered(uint256 indexed transactionId);
    event TransactionCompleted(uint256 indexed transactionId);

    function createTransaction(address payable _seller) public payable returns (uint256) {
        require(msg.value > 0, "Payment amount must be greater than 0");
        uint256 transactionId = transactionCount++;
        transactions[transactionId] = Transaction({
            buyer: payable(msg.sender),
            seller: _seller,
            amount: msg.value,
            state: State.AWAITING_PAYMENT
        });
        emit TransactionCreated(transactionId, msg.sender, _seller, msg.value);
        return transactionId;
    }

    function confirmPayment(uint256 _transactionId) public {
        Transaction storage transaction = transactions[_transactionId];
        require(msg.sender == transaction.buyer, "Only buyer can confirm payment");
        require(transaction.state == State.AWAITING_PAYMENT, "Invalid state");
        transaction.state = State.AWAITING_DELIVERY;
        emit PaymentReceived(_transactionId);
    }

    function confirmDelivery(uint256 _transactionId) public {
        Transaction storage transaction = transactions[_transactionId];
        require(msg.sender == transaction.buyer, "Only buyer can confirm delivery");
        require(transaction.state == State.AWAITING_DELIVERY, "Invalid state");
        transaction.state = State.COMPLETE;
        transaction.seller.transfer(transaction.amount);
        emit TransactionCompleted(_transactionId);
    }

    function refund(uint256 _transactionId) public {
        Transaction storage transaction = transactions[_transactionId];
        require(msg.sender == transaction.seller, "Only seller can refund");
        require(transaction.state != State.COMPLETE, "Cannot refund completed transaction");
        transaction.state = State.COMPLETE;
        transaction.buyer.transfer(transaction.amount);
        emit TransactionCompleted(_transactionId);
    }
}