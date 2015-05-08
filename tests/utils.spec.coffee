chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))

os = require('os')
utils = require('../lib/utils')

describe 'Utils:', ->

	describe '.isWin32()', ->

		describe 'given the platform is win32', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('win32')

			afterEach ->
				@osPlatformStub.restore()

			it 'should return true', ->
				expect(utils.isWin32()).to.be.true

		describe 'given the platform is not win32', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('darwin')

			afterEach ->
				@osPlatformStub.restore()

			it 'should return false', ->
				expect(utils.isWin32()).to.be.false

	describe '.isMacOSX()', ->

		describe 'given the platform is darwin', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('darwin')

			afterEach ->
				@osPlatformStub.restore()

			it 'should return true', ->
				expect(utils.isMacOSX()).to.be.true

		describe 'given the platform is not darwin', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('linux')

			afterEach ->
				@osPlatformStub.restore()

			it 'should return false', ->
				expect(utils.isMacOSX()).to.be.false

	describe '.isLinux()', ->

		describe 'given the platform is linux', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('linux')

			afterEach ->
				@osPlatformStub.restore()

			it 'should return true', ->
				expect(utils.isLinux()).to.be.true

		describe 'given the platform is not linux', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('darwin')

			afterEach ->
				@osPlatformStub.restore()

			it 'should return false', ->
				expect(utils.isLinux()).to.be.false

	describe '.elevate()', ->

		describe 'given a custom sudo path', ->

			beforeEach ->
				@sudo = '/usr/bin/sudo'

			it 'should make use of the custom sudo path', ->
				command = utils.elevate('hello world', sudo: @sudo)
				expect(command).to.equal('/usr/bin/sudo hello world')

		describe 'given no custom sudo path', ->

			it 'should use a default one', ->
				command = utils.elevate('hello world')
				expect(command).to.equal('sudo hello world')

	describe '.buildCommand()', ->

		describe 'given a custom sudo', ->

			it 'should use the sudo option', ->
				command = utils.buildCommand 'umount', [ '/dev/disk2' ],
					sudo: '/foo/bar'

				expect(command).to.equal('/foo/bar umount /dev/disk2')

		describe 'given noSudo', ->

			it 'should ignore the sudo option', ->
				command = utils.buildCommand 'umount', [ '/dev/disk2' ],
					sudo: '/foo/bar'
					noSudo: true

				expect(command).to.equal('umount /dev/disk2')

		describe 'given multiple arguments', ->

			it 'should pass them to the command', ->
				command = utils.buildCommand 'umount', [
					'foo'
					'bar'
					'baz'
				],
					sudo: '/foo/bar'

				expect(command).to.equal('/foo/bar umount foo bar baz')
