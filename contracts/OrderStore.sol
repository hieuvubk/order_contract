// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * Legacy version for reference and backward compatibility, similar to OwnableDocumentStore
 */
contract OrderStore is Ownable {

  bytes32 public constant NVKD_ROLE = keccak256("NVKD_ROLE"); // Nhan vien kinh doanh
  bytes32 public constant NVDP_ROLE = keccak256("NVDP_ROLE"); // Nhan vien dieu phoi
  bytes32 public constant NVGH_ROLE = keccak256("NVGH_ROLE"); // Nhan vien giao hang
  bytes32 public constant QL_ROLE = keccak256("QL_ROLE"); // Quan ly
  bytes32 public constant SHOP_ROLE = keccak256("SHOP_ROLE"); // Shop
  bytes32 public constant NCC_ROLE = keccak256("NCC_ROLE"); // Nha cung cap

  string name;
  // accepted = Xác nhận
  // call_ship = Giao ship lấy hàng
  // taked = Ship đã lấy hàng
  // warehouse = Giao kho
  // delivering = Đang giao hàng
  // delivery_success = Giao hàng thành công
  // rejected = Trả lại hàng
  // return_warehouse = Nhập lại kho
  // return_shop = Trả shop thành công
  // cancel = Hủy vận đơn
  // checking = Đang đối soát
  // checked = Đã đối soát
  // wait_deposit = Chờ cọc
  // deposited = Đã đặt cọc
  enum OrderStatus {
    accepted, 
    call_ship,
    taked,
    warehouse,
    delivering,
    delivery_success,
    rejected,
    return_warehouse,
    return_shop,
    cancel,
    checking,
    checked,
    wait_deposit, 
    deposited 
  }

  struct StatusHistory {
    OrderStatus status;
    uint256 atBlock;
  }

  struct Consensus {
    bool verified;
    uint256 timestamp;
  }

  /// A mapping of the order id to the hash that was issued
  mapping(string => bytes32) public orders;

  /// A mapping of the order id to order status throught time
  mapping(string => StatusHistory[]) public statusHistory;

  /// A mapping of the address to role
  mapping(address => bytes32) public roles;

  /// A mapping of role to status can accept
  mapping(bytes32 => OrderStatus[]) public rules;

  /// A mapping of consensus hash to signed
  mapping(bytes32 => mapping(address => bool)) public signatures;

  /// A mapping of consensus hash to signed
  mapping(bytes32 => Consensus) public consensusTx;

  address[] public signers;

  event OrderUpload(string orderId, bytes32 orderHash, address sender );
  event UpdateStatus(string orderId, OrderStatus status, address sender);
  event Sign(bytes32 data, address signers);
  event Verify(bytes32 data);

  constructor() public {
    roles[msg.sender] = NVKD_ROLE;
    initRules();
  }

  function initRules() internal {
    rules[NVKD_ROLE].push(OrderStatus.accepted);
    rules[NVKD_ROLE].push(OrderStatus.cancel);
    rules[NVKD_ROLE].push(OrderStatus.return_shop);
    rules[NVKD_ROLE].push(OrderStatus.checked);
    rules[NVKD_ROLE].push(OrderStatus.checking);
    rules[NVDP_ROLE].push(OrderStatus.call_ship);
    rules[NVGH_ROLE].push(OrderStatus.taked);
    rules[NVGH_ROLE].push(OrderStatus.warehouse);
    rules[NVGH_ROLE].push(OrderStatus.delivering);
    rules[NVGH_ROLE].push(OrderStatus.rejected);
    rules[NVGH_ROLE].push(OrderStatus.return_warehouse);
    rules[NVGH_ROLE].push(OrderStatus.deposited);
  }

  function issue(string memory orderId, bytes32 orderHash) public onlyOwner {
    require(statusHistory[orderId].length == 0, "Order exist");

    statusHistory[orderId].push(StatusHistory({
      status: OrderStatus.accepted,
      atBlock: block.number
    }));
    orders[orderId] = orderHash;
    emit OrderUpload(orderId, orderHash, msg.sender);
  }

  function updateOrderStatus(string memory orderId, OrderStatus status) public onlyOwner {
    require(statusHistory[orderId].length != 0, "Order not exist");
    bytes32 role = roles[msg.sender];
    OrderStatus[] memory remainStatus = rules[role];
    bool isExist = false;
    for(uint256 i=0; i < remainStatus.length; i++) {
      if(status == remainStatus[i]) {
        isExist = true;
        break;
      }
    }
    require(isExist, "No permission");
    statusHistory[orderId].push(StatusHistory({
          status: status,
          atBlock: block.number
    }));
    emit UpdateStatus(orderId, status, msg.sender);
  }

  function getOrder(string memory orderId) public view returns (bytes32, StatusHistory[] memory) {
    return (orders[orderId], statusHistory[orderId]);
  }

  function submitTransaction(bytes32 data)
        public
        returns (uint transactionId)
  {
    require(roles[msg.sender] == NVKD_ROLE || roles[msg.sender] == SHOP_ROLE || roles[msg.sender] == NCC_ROLE, "Not permission");
    addTransaction(data);
    signatures[data][msg.sender] = true;
    emit Sign(data, msg.sender);
    confirmTransaction(data);
  }

  function addTransaction(bytes32 data)
        public
    {
        if(consensusTx[data].timestamp != 0) {
          return;
        } else {
          consensusTx[data] = Consensus({
            verified: false,
            timestamp: block.timestamp
          });
        }
    }

  function confirmTransaction(bytes32 data)
        public
    {
        uint256 count = 0;
        for(uint256 i = 0 ; i < signers.length; i++) {
          if(signatures[data][signers[i]] == true) {
            count++;
          }
        }
        if(count == signers.length) {
          consensusTx[data].verified = true;
          emit Verify(data);
        }
    }
  
  function setSigner(address signer) onlyOwner public {
    signers.push(signer);
  }

}
