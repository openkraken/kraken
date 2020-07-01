import { createElement, render } from 'rax';
import driver from 'driver-universal';
import { isWeb } from 'universal-env';
import App from './pages';

if (isWeb) {
  document.body.style.margin = 0;
}

render(<App />, null, { driver });