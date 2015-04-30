var child_process, settings, utils, _;

_ = require('lodash');

child_process = require('child_process');

utils = require('./utils');

settings = require('./settings');


/**
 * @summary Unmount a device
 * @public
 * @function
 *
 * @describe
 * It does nothing for Windows.
 *
 * @param {String} device - device path
 * @param {Object} options - options
 * @param {String} [options.umount] - path to umount
 * @param {String} [options.sudo] - path to sudo
 * @param {Boolean} [options.noSudo] - don't use sudo
 * @param {Function} callback - callback (error, stdout, stderr)
 *
 * @example
 * umount.umount '/dev/disk2',
 *		umount: 'umount'
 *		sudo: 'sudo'
 *	, (error, stdout, stderr) ->
 *		throw error if error?
 */

exports.umount = function(device, options, callback) {
  var command;
  if (options == null) {
    options = {};
  }
  if (_.isFunction(options)) {
    callback = options;
    options = {};
  }
  if (device == null) {
    throw new Error('Missing device');
  }
  if (!_.isString(device)) {
    throw new Error("Invalid device: " + device);
  }
  if (!_.isPlainObject(options)) {
    throw new Error("Invalid options: " + options);
  }
  if ((options.sudo != null) && !_.isString(options.sudo)) {
    throw new Error("Invalid sudo option: " + options.sudo);
  }
  if ((options.umount != null) && !_.isString(options.umount)) {
    throw new Error("Invalid umount option: " + options.umount);
  }
  if ((options.noSudo != null) && !_.isBoolean(options.noSudo)) {
    throw new Error("Invalid noSudo option: " + options.noSudo);
  }
  if (callback == null) {
    throw new Error('Missing callback');
  }
  if (!_.isFunction(callback)) {
    throw new Error("Invalid callback: " + callback);
  }
  if (utils.isWin32()) {
    return callback(null, null, null);
  }
  _.defaults(options, settings);
  command = utils.buildCommand(options.umount, [device], options);
  return child_process.exec(command, callback);
};
