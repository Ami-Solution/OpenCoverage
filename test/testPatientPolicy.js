const expectThrow = require('./helpers/expectThrow')
const PatientPolicy = artifacts.require("./PatientPolicy.sol")

contract('PatientPolicy', function (accounts) {
  let patient = accounts[1]
  let patient2 = accounts[2]
  let patient3 = accounts[3]
  let patient4 = accounts[4]
  let policyAFee = web3.toWei(0.1, 'ether')
  let policyBFee = web3.toWei(0.2, 'ether')

  let patientPolicy

  beforeEach(async () => {
    patientPolicy = await PatientPolicy.new()
    await patientPolicy.initializeTarget(0, 0)
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
