_ = require('lodash')
chai = require('chai')
expect = chai.expect
settings = require('../lib/settings')

describe 'Settings:', ->

	describe '.umount', ->

		it 'should exist', ->
			expect(settings.umount).to.exist

		it 'should be a string', ->
			expect(settings.umount).to.be.a('string')

		it 'should not be empty', ->
			expect(settings.umount).to.not.have.length(0)

	describe '.sudo', ->

		it 'should exist', ->
			expect(settings.sudo).to.exist

		it 'should be a string', ->
			expect(settings.sudo).to.be.a('string')

		it 'should not be empty', ->
			expect(settings.sudo).to.not.have.length(0)

	describe '.noSudo', ->

		it 'should exist', ->
			expect(settings.noSudo).to.exist

		it 'should be boolean', ->
			expect(_.isBoolean(settings.noSudo)).to.be.true
