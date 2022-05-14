import { createElement } from 'rax';
import View from 'rax-view';
import Text from 'rax-text';
import Image from 'rax-image';
import styles from './card.module.css';

function Card(props) {
  return (
    <View className={styles.card} onClick={props.onClick}>
      <View className={'relative'}>
        {props.image ? (
          <Image
            resizeMode={'cover'}
            source={{ uri: props.image.src }}
            style={{
              width: 326,
              height: 326 * props.image.ratio,
              borderRadius: 16,
            }}
          />
        ) : null}

        <View className={styles.bottom}>
          <View className={styles.flexbetween}>
            <View className={styles.corner}>{props.leftCorner}</View>
            <View className={styles.corner}>{props.rightCorner}</View>
          </View>
        </View>
      </View>

      <Text className={styles.title}>{props.title}</Text>

      <View>{props.bottom}</View>
    </View>
  );
}

export default Card;
