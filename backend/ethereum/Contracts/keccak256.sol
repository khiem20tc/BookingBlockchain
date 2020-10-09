pragma solidity ^0.4.22;
//pragma experimental ABIEncoderV2;

contract Test {   
   function hashSignature(address identityHolder, uint256 topic, bytes data) public pure returns(bytes32 signature){
      return keccak256(abi.encodePacked(identityHolder, topic, data));
   }  
   
   function hashData(string data) public pure returns (bytes32 data_){
        bytes32 dataHash = keccak256(abi.encodePacked(data));
        bytes32 prefixedHash = keccak256("\x19Ethereum Signed Message:\n32", dataHash);
       return prefixedHash;
   }
   
   function hashKeyHolder(address holder) public pure returns (bytes32 key){
       return keccak256(abi.encodePacked(holder));
   }
   
   function hashSign(address _identity, uint256 claimType, bytes data) public pure returns (bytes32 sign) {
       bytes32 dataHash = keccak256(_identity, claimType, data);
       return keccak256("\x19Ethereum Signed Message:\n32", dataHash);
   }
   
   function getDataCallFunction() public pure returns (bytes data){
       //4 first bytes (Func Selector: keccak256(NameFunc(type1,type2))) + bytes32*N 
       //(N: func arguments keccak256(argument1) ghep noi lien keccak256(argument2)
       return abi.encodeWithSignature("setValue(uint256)", 1234);
   }
   
   uint256 Value=0;
   function setValue(uint256 _value) public {
       Value = _value;
   }
   
   function getValue() public view returns (uint256){
       return Value;
   }
}