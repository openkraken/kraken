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
      let msg = input.match(/.+\["(\w+)\",(\[[\w\W]+\])\]/);
      if (msg) {
        let method = msg[1];
        let data = JSON.parse(msg[2]);

        switch (method) {
          case 'setProperty': {
            codes.push(`KrakenSetProperty(${data[0]}, "${data[1]}", "${data[2]}");`);
            break;
          }
          case 'createElement': {
            codes.push(`KrakenCreateElement("${data[0].type}", ${data[0].id}, "{}", "[]");`);
            break;
          }
          case 'insertAdjacentNode': {
            codes.push(`KrakenInsertAdjacentNode(${data[0]},"${data[1]}",${data[2]});`);
            break;
          }
          case 'requestAnimationFrame': {
            codes.push(`requestAnimationFrame(${data[0]});`);
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
