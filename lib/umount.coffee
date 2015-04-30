_ = require('lodash')
child_process = require('child_process')
utils = require('./utils')
settings = require('./settings')

###*
# @summary Unmount a device
# @public
# @function
#
# @describe
# It does nothing for Windows.
#
# @param {String} device - device path
# @param {Object} options - options
# @param {String} [options.sudo] - path to sudo
# @param {Boolean} [options.noSudo] - don't use sudo
# @param {Function} callback - callback (error, stdout, stderr)
#
# @example
# umount.umount '/dev/disk2',
#		sudo: 'sudo'
#	, (error, stdout, stderr) ->
#		throw error if error?
###
exports.umount = (device, options = {}, callback) ->

	# Support omitting options argument altogether
	if _.isFunction(options)
		callback = options
		options = {}

	if not device?
		throw new Error('Missing device')

	if not _.isString(device)
		throw new Error("Invalid device: #{device}")

	if not _.isPlainObject(options)
		throw new Error("Invalid options: #{options}")

	if options.sudo? and not _.isString(options.sudo)
		throw new Error("Invalid sudo option: #{options.sudo}")

	if options.noSudo? and not _.isBoolean(options.noSudo)
		throw new Error("Invalid noSudo option: #{options.noSudo}")

	if not callback?
		throw new Error('Missing callback')

	if not _.isFunction(callback)
		throw new Error("Invalid callback: #{callback}")

	# async get's confused if we return different
	# numbers of arguments in different cases
	return callback(null, null, null) if utils.isWin32()

	_.defaults(options, settings)

	if utils.isMacOSX()
		unmountCommand = 'diskutil unmountDisk'
	else
		unmountCommand = 'umount'

	command = utils.buildCommand(unmountCommand, [ device ], options)

	return child_process.exec(command, callback)
