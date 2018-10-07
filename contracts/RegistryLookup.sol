pragma solidity ^0.4.23;

import './DoctorManager.sol';
import './Registry.sol';
import './PatientPolicy.sol';
import './DoctorClaims.sol';

library RegistryLookup {

  function doctorManager(Registry self) internal view returns (DoctorManager) {
    return DoctorManager(self.lookup(keccak256("DoctorManager")));
  }

  function patientPolicy(Registry self) internal view returns (PatientPolicy) {
    return PatientPolicy(self.lookup(keccak256("PatientPolicy")));
  }

  function doctorClaims(Registry self) internal view returns (DoctorClaims) {
    return DoctorClaims(self.lookup(keccak256("DoctorClaims")));
  }

}
