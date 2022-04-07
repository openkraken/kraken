/**
 * Benchmark script
 */

require('./tasks');
const { series, task } = require('gulp');
const chalk = require('chalk');
const uploader = require('./utils/uploader');

process.env.ENABLE_PROFILE = 'true';

task('run-benchmark', async (done) => {
  const childProcess = spawn('http-server', ['./', '-p 7878'], {
    stdio: 'pipe',
    cwd: path.join(paths.performanceTests, '/benchmark/build')
  })

  let serverIpAddress;
  let interfaces = os.networkInterfaces();
  for (let devName in interfaces) {
    interfaces[devName].forEach((item) => {
      if (item.family === 'IPv4' && !item.internal && item.address !== '127.0.0.1') {
        serverIpAddress = item.address;
      }
    })
  }

  if (!serverIpAddress) {
    const err = new Error('The IP address was not found.');
    done(err);
  }

  let androidDevices = getDevicesInfo();
  let performanceInfos = execSync(
    `flutter run -d ${androidDevices[0].id} --profile --dart-define="IP=${serverIpAddress}" | grep Performance`,
    {
      cwd: paths.performanceTests
    }
  ).toString().split(/\n/);

  const KrakenPerformancePath = 'kraken-performance';
  for (let item in performanceInfos) {
    let info = performanceInfos[item];
    const match = /\[(\s?\d,?)+\]/.exec(info);
    if (match) {
      const viewType = item == 0 ? 'kraken' : 'web';
      try {
        let performanceDatas = JSON.parse(match[0]);
        // Remove the top and the bottom five from the final numbers to eliminate fluctuations, and calculate the average.
        performanceDatas = performanceDatas.sort().slice(5, performanceDatas.length - 5);

        // Save performance list to file and upload to OSS.
        const listFile = path.join(__dirname, `${viewType}-load-time-list.txt`);
        fs.writeFileSync(listFile, performanceDatas.toString());
        uploader(`${KrakenPerformancePath}/${viewType}-load-time-list.txt`, listFile).then(() => {
          console.log('Snapshot Upload Success: https://kraken.oss-cn-hangzhou.aliyuncs.com/kraken-performance.txt');
        }).catch(err => done(err));

        // Get average of list.
        let sumLoadTimes = 0;
        performanceDatas.forEach(item => sumLoadTimes += item);
        let averageLoadTime = (sumLoadTimes / performanceDatas.length).toFixed();

        // Save average time to file and upload to OSS.
        const averageFile = path.join(__dirname, `../${viewType}-average-load-time.txt`);
        fs.writeFileSync(averageFile, averageLoadTime.toString());
        uploader(`${KrakenPerformancePath}/${viewType}-average-load-time.txt`, averageFile).then(() => {
          console.log('Snapshot Upload Success: https://kraken.oss-cn-hangzhou.aliyuncs.com/kraken-performance.txt');
        }).catch(err => done(err));

      } catch {
        const err = new Error('The performance info parse exception.');
        done(err);
      }
    }
  }
  
  execSync('adb uninstall com.example.performance_tests');
  
  done();
});

series(
  'android-so-clean',
  'compile-polyfill',
  'build-android-kraken-lib',
  'build-benchmark-app',
  'run-benchmark'
)(() => {
  console.log(chalk.green('Test Success.'));
});
