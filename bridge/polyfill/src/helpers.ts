/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

export function initPropertyHandlersForEventTargets(eventTarget: EventTarget, builtInEvents: string[]) {
  for (let i = 0; i < builtInEvents.length; i ++) {
    let eventName = builtInEvents[i];
    let propertyName = 'on' + eventName;
    Object.defineProperty(eventTarget, propertyName, {
      get() {
        return this['_' + propertyName];
      },
      set(value) {
        if (value == null) {
          this.removeEventListener(eventName, this['_' + propertyName]);
        } else {
          this.addEventListener(eventName, value);
        }

        this['_' + propertyName] = value;
      }
    });
  }
}
