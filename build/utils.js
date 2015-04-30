var os, _;

os = require('os');

_ = require('lodash');


/**
 * @summary Check if operating system is Windows
 * @private
 * @function
 *
 * @returns {Boolean} whether the os is Windows
 *
 * @example
 * utils.isWin32()
 */

exports.isWin32 = function() {
  return os.platform() === 'win32';
};


/**
 * @summary Prefix a command with sudo
 * @private
 * @function
 *
 * @param {String} command - command
 * @param {Object} options - options
 * @param {String} [options.sudo] - path to sudo
 * @returns {String} sudoified command
 *
 * @example
 * command = utils.elevate('umount', sudo: '/sbin/sudo')
 */

exports.elevate = function(command, options) {
  if (options == null) {
    options = {};
  }
  return "" + (options.sudo || 'sudo') + " " + command;
};


/**
 * @summary Build a command
 * @private
 * @function
 *
 * @description
 * Adds sudo with the corresponding path as required
 *
 * @param {String} command - command
 * @param {String[]} args - command arguments
 * @param {Object} options - options
 * @param {String} [options.sudo] - path to sudo
 * @param {Booelan} [options.noSudo] - don't use sudo
 * @returns {String} final command
 *
 * @example
 * command = utils.buildCommand 'umount', [ '/dev/disk2' ],
 *		sudo: '/sbin/sudo'
 *		noSudo: false
 */

exports.buildCommand = function(command, args, options) {
  var result;
  if (options == null) {
    options = {};
  }
  result = "" + command + " " + (args.join(' '));
  if (!options.noSudo) {
    result = exports.elevate(result, options);
  }
  return result;
};
