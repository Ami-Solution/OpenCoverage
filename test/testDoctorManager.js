const expectThrow = require('./helpers/expectThrow')
const DoctorManager = artifacts.require("./DoctorManager.sol")

contract('DoctorManager', function (accounts) {
  let doctor = accounts[1]
  let doctor2 = accounts[2]
  let doctor3 = accounts[3]
  let doctor4 = accounts[4]

  let doctorManager

  beforeEach(async () => {
    doctorManager = await DoctorManager.new()
    await doctorManager.initializeTarget(0, 0)
  })

  describe('initialize()', () => {
    it('should set the values at 0', async () => {
      assert.equal(await doctorManager.doctorCount.call(), 1)
    })
  })

  describe('addDoctor()', () => {
    it('should work', async () => {
      await doctorManager.addDoctor(doctor, 'Doogie')
      assert.equal(await doctorManager.doctorCount.call(), 2)
      assert.equal(await doctorManager.doctorNames.call(1), 'Doogie')
      assert.equal(await doctorManager.name.call(doctor), 'Doogie')

      await doctorManager.addDoctor(doctor2, 'General Major')
      assert.equal(await doctorManager.doctorCount.call(), 3)
      assert.equal(await doctorManager.doctorNames.call(2), 'General Major')
      assert.equal(await doctorManager.name.call(doctor2), 'General Major')
    })

    describe('when doctor added', () => {
      beforeEach(async () => {
        await doctorManager.addDoctor(doctor2, 'Dr. Hibbert')
      })

      it('should not allow double adds', async () => {
        await expectThrow(async () => {
          await doctorManager.addDoctor(doctor2, 'Dr. Hibbert')
        })
      })
    })
  })

})
