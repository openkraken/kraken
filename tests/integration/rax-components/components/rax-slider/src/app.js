import { createElement, Component, render, createRef } from 'rax';
import View from 'rax-view';
import Image from 'rax-image';
import Slider from 'rax-slider';
import DriverUniversal from 'driver-universal';
import styles from './app.css';

const App = () => {
  let index = 0;

  const handleChange = async (idx) => {
    await matchScreenshot();
    if (index >= 1) {
      done();
    } else {
      index++;
    }
  };

  return (
    <View>
      <Slider
        className="slider"
        width="750"
        height="500"
        autoPlayInterval={1500}
        autoPlay
        onChange={handleChange}
      >
        <Slider.Item>
          <View style={styles.itemWrap}>
            <Image
              style={styles.image}
              source={{
                height: '500rpx',
                width: '375rpx',
                uri:
                  'https://gw.alicdn.com/tfs/TB19NbqKFXXXXXLXVXXXXXXXXXX-750-500.png',
              }}
            />
          </View>
        </Slider.Item>
        <Slider.Item>
          <View style={styles.itemWrap}>
            <Image
              style={styles.image}
              source={{
                height: '500rpx',
                width: 375,
                uri:
                  'https://gw.alicdn.com/tfs/TB1tWYBKFXXXXatXpXXXXXXXXXX-750-500.png',
              }}
            />
          </View>
        </Slider.Item>
        <Slider.Item>
          <View style={styles.itemWrap}>
            <Image
              style={styles.image}
              source={{
                height: '500rpx',
                width: '375rpx',
                uri:
                  'https://gw.alicdn.com/tfs/TB1SX_vKFXXXXbyXFXXXXXXXXXX-750-500.png',
              }}
            />
          </View>
        </Slider.Item>
      </Slider>
    </View>
  );
}

render(<App />, document.body, { driver: DriverUniversal });