#!/usr/bin/env node
const { spawn } = require('node:child_process');
const p = spawn(__dirname + '/../cs/init-cs-tools.sh', {stdio: 'inherit'});
p.on('close', (code) => process.exit(code))