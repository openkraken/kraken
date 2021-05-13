// Impl by W3C vibration API.
// https://w3c.github.io/vibration/
import { kraken } from './kraken';

type VibratePattern = number | number[];
type _ValidVibratePattern = number[];

export function vibrate(pattern: VibratePattern) : boolean {
  const validPattern = _validateVibratePattern(pattern);
  return _performVibration(validPattern);
}

function _validateVibratePattern(pattern: VibratePattern) : _ValidVibratePattern | null {
  if (Array.isArray(pattern)) return pattern;
  if (typeof pattern === 'number') return [pattern];
  return null;
}

/**
 * If another instance of the perform vibration algorithm is already running, run the
 * following substeps:
 *   1. Abort that other instance of the perform vibration algorithm, if any.
 *   2. If pattern is an empty list, contains a single entry with a value of 0,
 *     or if the device is unable to vibrate, then return true and terminate these steps.
 */
function _performVibration(pattern: VibratePattern | null ) : boolean {
  if (!pattern) return false;

  _cancelVibration();

  kraken.invokeModule('Navigator', 'vibrate', (pattern));

  return true;
}

function _cancelVibration() {
  kraken.invokeModule('Navigator', 'cancelVibrate');
}
