/**
 * Build for def.
 */
const { join } = require('path');
const { readdirSync, mkdirSync, readFileSync, writeFileSync } = require('fs');
const { spawnSync } = require('child_process');

const KRAKEN_PATH = 'build/kraken'
const UTF8 = 'utf-8';
const destDir = process.env.BUILD_DEST || __dirname;
const projects = readdirSync('./components');
mkdirSync(destDir);

function build(projectName) {
  const contextPath = join(__dirname, 'components', projectName);
  const spawnOptions = {
    stdio: 'inherit',
    cwd: contextPath,
  };
  try {
    spawnSync('tnpm', ['i'], spawnOptions);
    spawnSync('npm', ['run', 'build'], spawnOptions);

    mkdirSync(join(destDir, projectName));

    try {
      const buff = readFileSync(join(contextPath, KRAKEN_PATH, 'index.js'));
      writeFileSync(join(contextPath, KRAKEN_PATH, 'index.js'), `describe('rax-components', () => {it('${projectName}', async (done) => {${buff};});});`);
    } catch (err) {
      console.log(err)
    }
    spawnSync('mv', [
      join(contextPath, KRAKEN_PATH),
      join(destDir, projectName)
    ], {
      stdio: 'inherit',
    });

    return Promise.resolve();
  } catch (err) {
    return Promise.reject(err);
  }
}

Promise.all(
  projects.map(projectName => build(projectName))
)
  .then(() => {
    console.log('Build successful!');
    process.exit(0);
  })
  .catch((err) => {
    console.log('Build failed with error!')
    console.log(err);
    process.exit(1);
  });