umount
------

[![npm version](https://badge.fury.io/js/umount.svg)](http://badge.fury.io/js/umount)
[![dependencies](https://david-dm.org/jviotti/node-umount.png)](https://david-dm.org/jviotti/node-umount.png)
[![Build Status](https://travis-ci.org/jviotti/node-umount.svg?branch=master)](https://travis-ci.org/jviotti/node-umount)

Unmount a device in UNIX, do nothing in Windows.

This module doesn't include native bindings, it constructs and runs the
corresponding `umount` command with [child_process.exec()](https://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback).

If the platform is `win32`, the `umount` function does nothing, and calls the given callback with `(null, null, null)`. This allows the client to call this module independently of the operating system while getting the desired behaviour.

Installation
------------

Install `umount` by running:

```sh
$ npm install --save umount
```

Documentation
-------------

### umount.umount(String device[, Object options], Function callback)

Unmount a device.

The accepted options are:

- `sudo`: Path to sudo (defaults to `sudo`).
- `umount`: Path to umount (defaults to `umount`).
- `noSudo`: Do not run the command with sudo (defaults to `false`).

The callback gets three arguments: `(error, stdout, stderr)`.

Example:

```coffee
umount = require('umount') 

umount.umount '/dev/disk2',
	sudo: '/usr/bin/sudo'
	umount: '/sbin/umount'
	noSudo: false
, (error, stdout, stderr) ->
	throw error if error?
	console.log(stdout)
```

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/jviotti/node-umount/issues](https://github.com/jviotti/node-umount/issues)
- Source Code: [github.com/jviotti/node-umount](https://github.com/jviotti/node-umount)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

Support
-------

If you're having any problem, please [raise an issue](https://github.com/jviotti/node-umount/issues/new) on GitHub.

License
-------

The project is licensed under the MIT license.
