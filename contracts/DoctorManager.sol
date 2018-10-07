pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Initializable.sol";
import "./DelegateTarget.sol";

contract DoctorManager is Ownable, Initializable, DelegateTarget {

  /*
    MEMORY START
    _do not_ remove any of these once they are deployed to a network (Ropsten,
    Mainnet, etc.) and only append to the bottom (before the END comment)
  */
  mapping (address => uint256)  doctorIndices;
  mapping (uint256 => address)  doctorAddresses;
  mapping (uint256 => string)  public doctorNames;

  uint256 public doctorCount;
  /*
    MEMORY END
    It is safe to add new data definitions here
  */

  event AddDoctor(address indexed doctor);

  function initializeTarget(address, bytes32) public notInitialized {
    setInitialized();
    owner = msg.sender;

    doctorIndices[address(0)] = doctorCount;
    doctorAddresses[doctorCount] = address(0);
    doctorNames[doctorCount] = '';
    doctorCount += 1;
  }

  function addDoctor(
    address _doctor,
    string _name
  ) public onlyOwner {
    require(!isDoctor(_doctor), "Address provided is already a doctor");
    doctorIndices[_doctor] = doctorCount;
    doctorAddresses[doctorCount] = _doctor;
    doctorNames[doctorCount] = _name;
    doctorCount += 1;
    emit AddDoctor(_doctor);
  }

  function doctorIndex(address _doctor) private view returns (uint256) {
    require(_doctor != address(0), "Doctor address provided is blank");
    uint256 index = doctorIndices[_doctor];
    if (doctorAddresses[index] == _doctor) {
      return index;
    } else {
      return 0;
    }
  }

  function name(address _doctor) public view returns (string) {
    return doctorNames[doctorIndex(_doctor)];
  }

  function isDoctor(address _doctor) public view returns (bool) {
    require(_doctor != address(0), "Doctor address provided is blank");
    uint256 index = doctorIndices[_doctor];
    return doctorAddresses[index] == _doctor;
  }

}
