const expectThrow = require('./helpers/expectThrow')
const DoctorClaims = artifacts.require("./DoctorClaims.sol")

contract('DoctorClaims', function (accounts) {
  let requester1 = accounts[1]
  let verifier1 = accounts[2]
  let requester2 = accounts[3]
  let verifier2 = accounts[4]
  let reimbursement1 = web3.toWei(10, 'ether')
  let reimbursement2 = web3.toWei(20, 'ether')

  let doctorClaims

  beforeEach(async () => {
    patientPolicy = await DoctorClaims.new()
    await doctorClaims.initializeTarget(0, 0)
  })

  describe('initialize()', () => {
    it('should set the values at 0', async () => {
      assert.equal(await patientPolicy.patientCount.call(), 0)
    })
  })

  describe('addPatientPolicy()', () => {
    it('should work', async () => {
      await patientPolicy.addPatientPolicy('Ms.Debbie', 'A', { from: patient, value: policyAFee })
      assert.equal(await patientPolicy.patientCount.call(), 1)
      assert.equal(await patientPolicy.patientNames.call(1), 'Ms.Debbie')
      assert.equal(await patientPolicy.name.call(patient), 'Ms.Debbie')

      await patientPolicy.addPatientPolicy('Mr.Donald Trump', 'B', {from: patient2, value: policyBFee })
      assert.equal(await patientPolicy.patientCount.call(), 2)
      assert.equal(await patientPolicy.patientNames.call(2), 'Mr.Donald Trump')
      assert.equal(await patientPolicy.name.call(patient2), 'Mr.Donald Trump')
    })

    describe('when doctor added', () => {
      beforeEach(async () => {
        await patientPolicy.addPatientPolicy('Mr.Warren Buffet', 'A', { from: patient3, value: policyAFee })
      })

      it('should not allow double adds', async () => {
        await expectThrow(async () => {
          await patientPolicy.addPatientPolicy('Mr.Warren Buffet', 'A', { from: patient3, value: policyAFee })
        })
      })
    })
  })

})
