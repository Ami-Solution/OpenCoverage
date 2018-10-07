pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "./Initializable.sol";
import "./DelegateTarget.sol";
import "./Registry.sol";
import "./RegistryLookup.sol";

contract DoctorClaims is Ownable, Initializable, DelegateTarget {

  using RegistryLookup for Registry;
  using SafeMath for uint256;
  /*
    MEMORY START
    _do not_ remove any of these once they are deployed to a network (Ropsten,
    Mainnet, etc.) and only append to the bottom (before the END comment)
  */

  mapping (address => uint256) public verifierClaims;
  mapping (address => address) public verifierRequester;
  mapping (address => uint256) public requesterStake;
  Registry registry;
  /*
    MEMORY END
    It is safe to add new data definitions here
  */

  event claimCreated(address indexed doctor, uint256 reimbursement );

  function () public payable {
  }

  function initializeTarget(address _registry, bytes32) public notInitialized {
    require(_registry != address(0), 'registry is not blank');
    registry = Registry(_registry);
    owner = msg.sender;
    setInitialized();
    verifierClaims[address(0)] = 0;
    verifierRequester[address(0)] = address(0);
    requesterStake[address(0)] = 0;
  }

  // reimbursement 1000
  // stake 20 - 2% is stake
  // total 1020
  function createClaim(address _verifier, address _patient, uint256 _reimbursement) public payable {
      require(registry.doctorManager().isDoctor(_verifier) && registry.doctorManager().isDoctor(msg.sender) && registry.patientPolicy().isPatient(_patient), "Requester or Verifier or Patient is not registered in system");
      uint256 stake = _reimbursement.mul(2).div(100);
      require(msg.value >= stake);
      verifierClaims[_verifier] = _reimbursement;
      verifierRequester[_verifier] = msg.sender;
      requesterStake[msg.sender] = stake;
      emit claimCreated(msg.sender, _reimbursement);
  }

  function approveClaim() public {
      address verifier = msg.sender;
      address requester = verifierRequester[verifier];
      require(verifierClaims[verifier] != 0 && requester != address(0), "Verifier does not have any claims");
      transferContractBalance(requester, requesterStake[requester]);
      uint256 verifierReimbursement = verifierClaims[verifier].div(100);
      uint256 requesterReimbursement = verifierClaims[verifier].mul(99).div(100);
      registry.patientPolicy().transferContractBalance(verifier, verifierReimbursement);
      registry.patientPolicy().transferContractBalance(requester, requesterReimbursement);
  }

  function denyClaim() public {
      address verifier = msg.sender;
      address requester = verifierRequester[verifier];
      require(verifierClaims[verifier] != 0 && requester != address(0), "Verifier does not have any claims");
      transferContractBalance(verifier, requesterStake[requester]);
   }

  function getContractBalance() public view returns (uint256) {
      return address(this).balance;
  }

  function transferContractBalance(address _requester, uint256 _stake) public {
      require(getContractBalance() >= _stake);
      _requester.transfer(_stake);

  }


}
