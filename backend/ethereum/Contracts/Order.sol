pragma solidity ^0.5.4;

import {KeyHolder} from "./KeyHolderOrder.sol";
import {MintableToken} from "./MintableToken.sol";
import "./EternalStorage.sol";
pragma experimental ABIEncoderV2;

contract Order {
    EternalStorage public Storage;
    KeyHolder public KeyHolder_;
    MintableToken public Token;
    
    event createOrder_(address customer, address shipper, uint256 value);
    event ShipperIsGoing_(bytes32 ID);
    event ShipperIsComing_(bytes32 ID);
    event ShipperDelivered_(bytes32 ID, uint256 value);
    event setReportCustomer_(bytes32 ID, string reportCustomer);
    event setReportShipper_(bytes32 ID, string reportShipper);
    event customerCancel_(bytes32 ID, uint256 value);
    event shipperCancel_(bytes32 ID, uint256 value);
    
    constructor(
        address storage_, 
        address keyHolder_,
        address token_,
        string memory version,
        string memory corporation
        ) 
        public { 
            Storage = EternalStorage(storage_);
            KeyHolder_ = KeyHolder(keyHolder_);
            Token = MintableToken(token_);
            Storage.set(keccak256(abi.encodePacked("version")), version);
            Storage.set(keccak256(abi.encodePacked("corporation")), corporation);
        }
        
    function getVersion() public view returns(string memory) {
        return Storage.getStringValue(keccak256(abi.encodePacked("version")));
    }
        
    function createOrder(address customer, address shipper, uint256 value) public{
        require(KeyHolder_.keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 3), "Sender does not have manager key");
        bytes32 ID = keccak256(abi.encodePacked(customer, shipper, value));
        Storage.set(keccak256(abi.encodePacked(ID, "customer")), customer);
        Storage.set(keccak256(abi.encodePacked(ID, "shipper")), shipper);
        Storage.set(keccak256(abi.encodePacked(ID, "value")), value);
        string memory str = "Đơn hàng đã khởi tạo";
        Storage.set(keccak256(abi.encodePacked(ID, "state")), str);
        Token.mint(address(this), value);
        Storage.set(keccak256(abi.encodePacked(ID, "balance")), value);
        
        emit createOrder_(customer,shipper,value);
    }
    
    function returnID(address customer, address shipper, uint256 value) public view returns(bytes32){
        bytes32 ID = keccak256(abi.encodePacked(customer, shipper, value));
        return ID;
    }
    
    function getOrderInfo(bytes32 ID) public view returns(
        string memory corporation,
        address customer,
        address shipper,
        uint256 value,
        string memory state,
        uint256 balance
        ) {
        return (
        Storage.getStringValue(keccak256(abi.encodePacked("corporation"))),
        Storage.getAddressValue(keccak256(abi.encodePacked(ID, "customer"))),
        Storage.getAddressValue(keccak256(abi.encodePacked(ID, "shipper"))),
        Storage.getUintValue(keccak256(abi.encodePacked(ID, "value"))),
        Storage.getStringValue(keccak256(abi.encodePacked(ID, "state"))),
        Storage.getUintValue(keccak256(abi.encodePacked(ID, "balance")))
        );
    }
    
    function ShipperIsGoing(bytes32 ID) public {
        require(msg.sender == Storage.getAddressValue(keccak256(abi.encodePacked(ID, "shipper")))); 
        string memory str="Shipper đang trên đường lấy hàng";
        Storage.set(keccak256(abi.encodePacked(ID, "state")), str);
        
        emit ShipperIsGoing_(ID);
    } 
    
    function ShipperIsComing(bytes32 ID) public {
        require(msg.sender == Storage.getAddressValue(keccak256(abi.encodePacked(ID, "shipper"))));
        string memory str="Shipper đang trên đường giao hàng";
        Storage.set(keccak256(abi.encodePacked(ID, "state")), str);
        
        emit ShipperIsComing_(ID);
    } 
    
    function ShipperDelivered(bytes32 ID) public {
        require(msg.sender == Storage.getAddressValue(keccak256(abi.encodePacked(ID, "shipper"))));
        string memory str="Shipper đã giao hàng thành công";
        Storage.set(keccak256(abi.encodePacked(ID, "state")), str);
        uint256 value = Storage.getUintValue(keccak256(abi.encodePacked(ID, "value")));
        Token.transferFromTo(address(this),msg.sender,value);
        Storage.set(keccak256(abi.encodePacked(ID, "balance")), uint256(0));
        
        emit ShipperDelivered_(ID,value);
    } 
    
    function ReportShipper(bytes32 ID) public returns(bool) {
        require(msg.sender == Storage.getAddressValue(keccak256(abi.encodePacked(ID, "customer"))));
        return true;
    }
    
    function ReportCustomer(bytes32 ID) public returns(bool) {
        require(msg.sender == Storage.getAddressValue(keccak256(abi.encodePacked(ID, "shipper"))));
        return true;
    }
    
    function setReportCustomer(bytes32 ID, string memory reportCustomer) public {
        address customer = Storage.getAddressValue(keccak256(abi.encodePacked(ID, "customer")));
        Storage.pushArray(keccak256(abi.encodePacked("reportList", customer)), reportCustomer);
        
        emit setReportCustomer_(ID,reportCustomer);
    }
    
    function setReportShipper(bytes32 ID, string memory reportShipper) public {
        address shipper = Storage.getAddressValue(keccak256(abi.encodePacked(ID, "shipper")));
        Storage.pushArray(keccak256(abi.encodePacked("reportList", shipper)), reportShipper);
    
         emit setReportShipper_(ID,reportShipper);
    }
    
    function getReportList(address entity) public view returns(string[] memory) {
        return Storage.getArrayString(keccak256(abi.encodePacked("reportList", entity)));
    }
    
    function customerCancel(bytes32 ID) public {
        require(msg.sender == Storage.getAddressValue(keccak256(abi.encodePacked(ID, "customer")))); 
        string memory str="Đơn hàng đã bị hủy bởi customer";
        Storage.set(keccak256(abi.encodePacked(ID, "state")), str);
        uint256 value = Storage.getUintValue(keccak256(abi.encodePacked(ID, "value")));
        Token.burn(address(this), value);
        Storage.set(keccak256(abi.encodePacked(ID, "balance")), uint256(0));
        
        emit customerCancel_(ID,value);
    }
    
    function shipperCancel(bytes32 ID) public {
        require(msg.sender == Storage.getAddressValue(keccak256(abi.encodePacked(ID, "shipper")))); 
        string memory str="Đơn hàng đã bị hủy bởi shipper";
        Storage.set(keccak256(abi.encodePacked(ID, "state")), str);
        uint256 value = Storage.getUintValue(keccak256(abi.encodePacked(ID, "value")));
        Token.burn(address(this), value);
        Storage.set(keccak256(abi.encodePacked(ID, "balance")), uint256(0));
        
        emit shipperCancel_(ID,value);
    }
    
    function balanceOf(address entity) view public returns(uint256) {
        return Token.balanceOf(entity);
    }
}