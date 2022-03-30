const { spawnSync } = require('child_process');


function main() {
  const authors = spawnSync('sh', ['-c', 'git log --abbrev-commit | grep Author'])
    .stdout
    .toString()
    .split(/\n/);

  const uniqueAuthors = {}; // email -> username
  for (let line of authors) {
    const match = /Author: ([^\s]+) \<(.*)>/.exec(line);
    if (match) {
       const email = match[2];
       const username = match[1];
       uniqueAuthors[email] = username;
    }
  }
  console.log(uniqueAuthors);

  let content = '';
  Object.keys(uniqueAuthors).sort((prev, next) => {
    const prevUsername = uniqueAuthors[prev].toLowerCase();
    const nextUsername = uniqueAuthors[next].toLowerCase();
    return prevUsername > nextUsername ? 1 : -1;
  }).forEach((email) => {
    const username = uniqueAuthors[email];
    content += `${username} <${email}>\n`;
  });

  console.log(content);
}

main();
