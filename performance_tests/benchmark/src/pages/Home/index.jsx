import { createElement, useState, useEffect } from 'rax';
import View from 'rax-view';
import Text from 'rax-text';
import originDatas from '../../mock.js';

import styles from './index.module.css';
import Price from '../../components/Price';
import Card from '../../components/Card';

if (!window.startTime) {
  window.startTime = Date.now();
}

window.onload = () => {
  const endTime = Date.now();
  const firstPaint = endTime - startTime;
  console.log('startTime=', startTime);
  console.log('endTime=', endTime);
  console.log('firstPaint=', firstPaint);
  // document.getElementById('firstPaint').innerHTML = firstPaint;

  if (window.kraken) {
    kraken.methodChannel.invokeMethod('firstPaint', firstPaint);
  } else {
    Message.postMessage(firstPaint);  
  }
};

export default function Home() {
  const calcRatio = (item) => {
    const h = item.imageInfos[0].heightSize;
    const w = item.imageInfos[0].widthSize;

    return Math.min(4 / 3, Math.max(h / w, 3 / 4));
  };

  const renderElement = (dataList) => {
    return dataList.map((item, index) => {
      const props = {
        key: index,
        title: item.title,
        bottom: <Price price={item.price} rightText={`${item.wantNum}人想要`} />,
        onClick: () => {},
      };
      const ratio = calcRatio(item);
      props.image = {
        src: item.imageInfos[0].url,
        ratio,
      };

      return (<div key={index} style={{ display: 'inline-block', padding: '2px' }}>
        <Card key={index} {...props} />
      </div>);
    });
  };

  return (
    <div>
      <View className={styles.homeContainer}>
        <div>firstPaint: <span id="firstPaint"></span></div>
        <View
          style={{ height: '100vh', display: 'block' }}
        >
          {
            renderElement(originDatas)
          }
        </View>
      </View>
    </div>
  );
}
