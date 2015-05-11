os = require('os')
_ = require('lodash')
child_process = require('child_process')
chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))
umount = require('../lib/umount')
utils = require('../lib/utils')

describe 'Umount:', ->

	describe '.umount()', ->

		beforeEach ->
			@childProcessExecStub = sinon.stub(child_process, 'exec')
			@childProcessExecStub.yields(null, 'stdout', 'stderr')

		afterEach ->
			@childProcessExecStub.restore()

		it 'should throw if no device', ->
			expect ->
				umount.umount(null, {}, _.noop)
			.to.throw('Missing device')

		it 'should throw if device is not a string', ->
			expect ->
				umount.umount(123, {}, _.noop)
			.to.throw('Invalid device: 123')

		it 'should throw if options is not an object', ->
			expect ->
				umount.umount('/dev/disk1', 123, _.noop)
			.to.throw('Invalid options: 123')

		it 'should throw if options.sudo is defined but not a string', ->
			expect ->
				umount.umount('/dev/disk1', sudo: 123, _.noop)
			.to.throw('Invalid sudo option: 123')

		it 'should throw if options.noSudo is defined but not a boolean', ->
			expect ->
				umount.umount('/dev/disk1', noSudo: 123, _.noop)
			.to.throw('Invalid noSudo option: 123')

		it 'should throw if no callback', ->
			expect ->
				umount.umount('/dev/disk1', {}, null)
			.to.throw('Missing callback')

		it 'should throw if callback is not a function', ->
			expect ->
				umount.umount('/dev/disk1', {}, 123)
			.to.throw('Invalid callback: 123')

		it 'should throw if no options nor callback', ->
			expect ->
				umount.umount('/dev/disk1')
			.to.throw('Missing callback')

		describe 'given is win32', ->

			beforeEach ->
				@utilsIsWin32Stub = sinon.stub(utils, 'isWin32')
				@utilsIsWin32Stub.returns(true)

			afterEach ->
				@utilsIsWin32Stub.restore()

			it 'should not attempt to unmount', (done) ->
				umount.umount '/dev/disk2', (error) =>
					expect(@childProcessExecStub).to.not.have.been.called
					done()

			it 'should set all arguments to callback to null', (done) ->
				umount.umount '/dev/disk2', (error, stdout, stderr) ->
					expect(error).to.equal(null)
					expect(stdout).to.equal(null)
					expect(stderr).to.equal(null)
					done()

		describe 'given is not win32', ->

			beforeEach ->
				@utilsIsWin32Stub = sinon.stub(utils, 'isWin32')
				@utilsIsWin32Stub.returns(false)

			afterEach ->
				@utilsIsWin32Stub.restore()

			describe 'given is OS X', ->

				beforeEach ->
					@osPlatformStub = sinon.stub(os, 'platform')
					@osPlatformStub.returns('darwin')

				afterEach ->
					@osPlatformStub.restore()

				it 'use the correct command', (done) ->
					umount.umount '/dev/disk2', (error, stdout, stderr) =>
						expect(error).to.not.exist
						expect(stdout).to.equal('stdout')
						expect(stderr).to.equal('stderr')
						expect(@childProcessExecStub).to.have.been.calledOnce
						expect(@childProcessExecStub).to.have.been.calledWith('sudo diskutil unmountDisk /dev/disk2')
						done()

			describe 'given is linux', ->

				beforeEach ->
					@osPlatformStub = sinon.stub(os, 'platform')
					@osPlatformStub.returns('linux')

				afterEach ->
					@osPlatformStub.restore()

				describe 'given no options parameter', ->

					it 'should umount the disk', (done) ->
						umount.umount '/dev/sdb', (error, stdout, stderr) =>
							expect(error).to.not.exist
							expect(stdout).to.equal('stdout')
							expect(stderr).to.equal('stderr')
							expect(@childProcessExecStub).to.have.been.calledOnce
							expect(@childProcessExecStub).to.have.been.calledWith('sudo umount /dev/sdb?*')
							done()

				describe 'given empty options', ->

					it 'should umount the disk', (done) ->
						umount.umount '/dev/sdb', {}, (error, stdout, stderr) =>
							expect(error).to.not.exist
							expect(stdout).to.equal('stdout')
							expect(stderr).to.equal('stderr')
							expect(@childProcessExecStub).to.have.been.calledOnce
							expect(@childProcessExecStub).to.have.been.calledWith('sudo umount /dev/sdb?*')
							done()

				describe 'given no sudo option', ->

					it 'should omit sudo', (done) ->
						umount.umount '/dev/sdb', noSudo: true, (error, stdout, stderr) =>
							expect(error).to.not.exist
							expect(stdout).to.equal('stdout')
							expect(stderr).to.equal('stderr')
							expect(@childProcessExecStub).to.have.been.calledOnce
							expect(@childProcessExecStub).to.have.been.calledWith('umount /dev/sdb?*')
							done()

				describe 'given a custom sudo option', ->

					it 'should use the custom sudo', (done) ->
						umount.umount '/dev/sdb', sudo: '/usr/bin/sudo', (error, stdout, stderr) =>
							expect(error).to.not.exist
							expect(stdout).to.equal('stdout')
							expect(stderr).to.equal('stderr')
							expect(@childProcessExecStub).to.have.been.calledOnce
							expect(@childProcessExecStub).to.have.been.calledWith('/usr/bin/sudo umount /dev/sdb?*')
							done()

				describe 'given a custom sudo and no sudo options', ->

					it 'should ignore the custom sudo', (done) ->
						umount.umount '/dev/sdb',
							sudo: '/usr/bin/sudo',
							noSudo: true
						, (error, stdout, stderr) =>
							expect(error).to.not.exist
							expect(stdout).to.equal('stdout')
							expect(stderr).to.equal('stderr')
							expect(@childProcessExecStub).to.have.been.calledOnce
							expect(@childProcessExecStub).to.have.been.calledWith('umount /dev/sdb?*')
							done()

	describe '.isMounted()', ->

		it 'should throw if no device', ->
			expect ->
				umount.isMounted(null, _.noop)
			.to.throw('Missing device')

		it 'should throw if device is not a string', ->
			expect ->
				umount.isMounted(123, _.noop)
			.to.throw('Invalid device: 123')

		it 'should throw if no callback', ->
			expect ->
				umount.isMounted('/dev/disk1', null)
			.to.throw('Missing callback')

		it 'should throw if callback is not a function', ->
			expect ->
				umount.isMounted('/dev/disk1', 123)
			.to.throw('Invalid callback: 123')

		describe 'given an error', ->

			beforeEach ->
				@childProcessExecStub = sinon.stub(child_process, 'exec')
				@error = new Error('mount error')
				@childProcessExecStub.yields(@error)

			afterEach ->
				@childProcessExecStub.restore()

			it 'should return the error', (done) ->
				umount.isMounted '/dev/disk1', (error, isMounted) =>
					expect(error).to.be.an.instanceof(Error)
					expect(error).to.equal(@error)
					done()

		describe 'given is win32', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('win32')

			afterEach ->
				@osPlatformStub.restore()

			it 'should always return true', (done) ->
				umount.isMounted '/foo/bar', (error, isMounted) ->
					expect(error).to.not.exist
					expect(isMounted).to.be.true
					done()

		describe 'given is darwin', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('darwin')

			afterEach ->
				@osPlatformStub.restore()

			describe 'given stderr output', ->

				beforeEach ->
					@childProcessExecStub = sinon.stub(child_process, 'exec')
					@childProcessExecStub.yields(null, '', 'stderr')

				afterEach ->
					@childProcessExecStub.restore()

				it 'should return an error with stderr contents', (done) ->
					umount.isMounted '/dev/disk1', (error, isMounted) ->
						expect(error).to.be.an.instanceof(Error)
						expect(error.message).to.equal('stderr')
						done()

			describe 'given OS X mount output', ->

				beforeEach ->
					@childProcessExecStub = sinon.stub(child_process, 'exec')
					@childProcessExecStub.yields null, '''
						/dev/disk1 on / (hfs, local, journaled)
						devfs on /dev (devfs, local, nobrowse)
						map -hosts on /net (autofs, nosuid, automounted, nobrowse)
						map auto_home on /home (autofs, automounted, nobrowse)
						/dev/disk2s1 on /Volumes/Untitled (msdos, local, nodev, nosuid, noowners)
					''', ''

				afterEach ->
					@childProcessExecStub.restore()

				it 'should return true for /dev/disk2', (done) ->
					umount.isMounted '/dev/disk2', (error, isMounted) ->
						expect(error).to.not.exist
						expect(isMounted).to.be.true
						done()

				it 'should return false for /dev/disk3', (done) ->
					umount.isMounted '/dev/disk3', (error, isMounted) ->
						expect(error).to.not.exist
						expect(isMounted).to.be.false
						done()

		describe 'given is linux', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('linux')

			afterEach ->
				@osPlatformStub.restore()

			describe 'given Ubuntu mount output', ->

				beforeEach ->
					@childProcessExecStub = sinon.stub(child_process, 'exec')
					@childProcessExecStub.yields null, '''
						/dev/sda1 on / type ext4 (rw,errors=remount-ro)
						proc on /proc type proc (rw,noexec,nosuid,nodev)
						sysfs on /sys type sysfs (rw,noexec,nosuid,nodev)
						devpts on /dev/pts type devpts (rw,noexec,nosuid,gid=5,mode=0620)
						tmpfs on /run type tmpfs (rw,noexec,nosuid,size=10%,mode=0755)
						gvfsd-fuse on /run/user/1000/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,user=jviotti)
						/dev/sdb1 on /media/jviotti/CD8B-7D3E type vfat (rw,nosuid,nodev,uid,utf8=1,showexec,flush,uhelper=udisks2)
					'''

				afterEach ->
					@childProcessExecStub.restore()

				it 'should return true for /dev/sdb', (done) ->
					umount.isMounted '/dev/sdb', (error, isMounted) ->
						expect(error).to.not.exist
						expect(isMounted).to.be.true
						done()

				it 'should return false for /dev/sdc', (done) ->
					umount.isMounted '/dev/sdc', (error, isMounted) ->
						expect(error).to.not.exist
						expect(isMounted).to.be.false
						done()
