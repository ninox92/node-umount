_ = require('lodash')
child_process = require('child_process')
utils = require('./utils')
settings = require('./settings')

###*
# @summary Unmount a device
# @public
# @function
#
# @description
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
		unmountCommand = '/usr/sbin/diskutil unmountDisk force'

		# OS X doesn't require `sudo` to unmount disks
		options.noSudo = true
	else
		unmountCommand = 'umount'

	# If trying to unmount the raw device in Linux, we get:
	# > umount: /dev/sdN: not mounted
	# Therefore we use the ?* glob to make sure umount processes
	# the partitions of sdN independently (even if they contain multiple digits)
	# but not the raw device.
	# We also redirect stderr to /dev/null to ignore warnings
	# if a device is already unmounted.
	# Finally, we also wrap the command in a boolean expression
	# that always evaluates to true to ignore the return code,
	# which is non zero when a device was already unmounted.
	if utils.isLinux()
		device += '?* 2>/dev/null || /bin/true'

	command = utils.buildCommand(unmountCommand, [ device ], options)

	return child_process.exec(command, callback)

###*
# @summary Check if a device is mounted
# @public
# @function
#
# @description
# It always returns true in Windows.
#
# @param {String} device - device path
# @param {Function} callback - callback (error, isMounted)
#
# @example
# umount.isMounted '/dev/disk2', (error, isMounted) ->
#		throw error if error?
#		console.log("Is mounted? #{isMounted}")
###
exports.isMounted = (device, callback) ->

	if not device?
		throw new Error('Missing device')

	if not _.isString(device)
		throw new Error("Invalid device: #{device}")

	if not callback?
		throw new Error('Missing callback')

	if not _.isFunction(callback)
		throw new Error("Invalid callback: #{callback}")

	return callback(null, true) if utils.isWin32()

	child_process.exec 'mount', (error, stdout, stderr) ->
		return callback(error) if error?

		if not _.isEmpty(stderr)
			return callback(new Error(stderr))

		return callback(null, stdout.indexOf(device) isnt -1)
