#!/usr/bin/env node

const fs = require('fs');
const program = require('commander');
const readline = require('readline');

program
  .requiredOption('-s, --source <file>', 'source log file')
  .requiredOption('-o, --output <file>', 'output dart file')
  .action(options => {
    let codes = [];

    const rl = readline.createInterface({
      input: fs.createReadStream(options.source),
    });

    rl.on('line', input => {
      if (!input) return;
      let msg = input.match(/bridge\:\s\[(\w+)\]\s\[(\w+)\]:\s(.+)/);
      if (msg) {
        let mode = msg[1];
        let method = msg[2];
        let data = msg[3];

        switch (method) {
          case 'setProperty': {
            codes.push('setProperty ' + data);
            break;
          }
          case 'setStyle': {
            codes.push('setStyle ' + data);
            break;
          }
          case 'createElement': {
            codes.push('createElement ' + data);
            break;
          }
          case 'insertAdjacentNode': {
            codes.push('insertAdjacentNode ' + data);
            break;
          }
          case 'requestAnimationFrame': {
            codes.push('requestAnimationFrame ' + data);
            break;
          }
        }
      }
    });

    rl.on('close',() => {
      fs.writeFileSync(options.output, codes.join('\n'));
    });
  });

program.parse(process.argv);
