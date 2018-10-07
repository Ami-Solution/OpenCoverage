pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Initializable.sol";
import "./DelegateTarget.sol";

contract PatientPolicy is Ownable, Initializable, DelegateTarget {

  /*
    MEMORY START
    _do not_ remove any of these once they are deployed to a network (Ropsten,
    Mainnet, etc.) and only append to the bottom (before the END comment)
  */
  mapping (address => uint256)  patientIndices;
  mapping (address => string)  patientPolicies;
  mapping (uint256 => address)  patientAddresses;
  mapping (uint256 => string)  public patientNames;
  mapping (string => uint256)  admissiblePolicies;

  uint256 public patientCount;
  uint256 public policyCount;
  /*
    MEMORY END
    It is safe to add new data definitions here
  */

  event AddPatientPolicy(address indexed patient, string policy );

  function () public payable {
  }

  function initializeTarget(address, bytes32) public notInitialized {
    setInitialized();
    owner = msg.sender;

    patientIndices[address(0)] = patientCount;
    patientPolicies[address(0)] = '';
    patientAddresses[patientCount] = address(0);
    patientNames[patientCount] = '';
    setAdmissiblePolicies();
  }

  function setAdmissiblePolicies() private {
      admissiblePolicies['A'] = 100000000000000000;
      admissiblePolicies['B'] = 200000000000000000;
      policyCount = 2;
  }

  function addPatientPolicy(
    string _name,
    string _policy
  ) public payable {
    address _patient = msg.sender;
    require(!isPatient(_patient) && isPolicy(_policy), "Address provided is already a patient or Policy is not recognized by the system");
    require (msg.value == admissiblePolicies[_policy], "Patient did not pay for the policy");
    patientCount += 1;
    patientIndices[_patient] = patientCount;
    patientAddresses[patientCount] = _patient;
    patientNames[patientCount] = _name;
    patientPolicies[_patient] = _policy;
    emit AddPatientPolicy(_patient, _policy);
  }

  function patientIndex(address _patient) private view returns (uint256) {
    require(_patient != address(0), "Doctor address provided is blank");
    uint256 index = patientIndices[_patient];
    if (patientAddresses[index] == _patient) {
      return index;
    } else {
      return 0;
    }
  }

  function getPatientPolicy(address _patient) private view returns (string) {
    require(_patient != address(0) && patientIndex(_patient) != 0, "Doctor address provided is blank");
    return patientPolicies[_patient];
  }

  function name(address _patient) public view returns (string) {
    return patientNames[patientIndex(_patient)];
  }

  function isPatient(address _patient) public view returns (bool) {
    if (patientIndex(_patient) != 0) {
        return true;
    }
    return false;
  }

  function isPolicy(string _policy) public view returns (bool) {
    if (admissiblePolicies[_policy] != 0) {
        return true;
    }
    return false;
  }

  function getContractBalance() public view returns (uint256) {
      return address(this).balance;
  }

  function transferContractBalance(address _requester, uint256 _reimbursement) public {
      require(getContractBalance() >= _reimbursement);
      _requester.transfer(_reimbursement);
  }


}
