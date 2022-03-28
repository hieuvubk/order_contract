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

  /// A mapping of the order id to the hash that was issued
  mapping(string => bytes32) public orders;

  /// A mapping of the order id to order status throught time
  mapping(string => StatusHistory[]) public statusHistory;

  /// A mapping of the address to role
  mapping(address => bytes32) public roles;

  /// A mapping of role to status can accept
  mapping(bytes32 => OrderStatus[]) public rules;

  event OrderUpload(string orderId, bytes32 orderHash, address sender );
  event DocumentRevoked(bytes32 indexed document, address indexed sender);

  constructor(string memory _name) public {
    name = _name;
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
  }

  function getOrder(string memory orderId) public view returns (bytes32, StatusHistory[] memory) {
    return (orders[orderId], statusHistory[orderId]);
  }

}
