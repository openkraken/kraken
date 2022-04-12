import { createElement } from 'rax';
import Text from 'rax-text';
import View from 'rax-view';
import styles from './price.module.css';

export default function Price(props) {
  let price = '0';
  if (typeof props.price === 'number') {
    price = props.price.toFixed(2);
    const arr = price.split('.');
    if (arr.length && arr[1] === '00') {
      price = arr[0];
    }
  } else if (typeof props.price === 'string') {
    price = props.price;
  }

  return (
    <View className={styles.container}>
      <View className={styles.common}>
        <Text className={styles.preText}>{props.preText || null}</Text>
        {props.price && (props.pricePreIcon === true || props.pricePreIcon === undefined) ? (
          <Text className={styles.priceIcon}>¥</Text>
        ) : null}
        {typeof props.pricePreIcon !== 'boolean' && typeof props.pricePreIcon !== 'undefined'
          ? props.pricePreIcon
          : null}
        {props.price ? <Text className={styles.price}>{price}</Text> : null}
        {props.postText ? <Text className={styles.postText}>{props.postText}</Text> : null}
      </View>
      {props.rightText === false ? null : (
        <View
          style={{
            flexDirection: 'row',
            justifyContent: 'center',
          }}
        >
          <Text className={styles.want}>{props.rightText}</Text>
        </View>
      )}
    </View>
  );
}
