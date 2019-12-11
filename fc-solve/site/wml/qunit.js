#!/usr/bin/env node

"use strict";

const program = require( "commander" );
const run = require( "qunit/src/cli/run" );
const FindReporter = require( "qunit/src/cli/find-reporter" );
const pkg = require( "qunit/package.json" );

const findReporter = FindReporter.findReporter;

program.parse( process.argv );

const args = program.args;
const options = {
	reporter: findReporter( program.reporter ),
	requires: [],
	seed: program.seed
};

run( args, options );
