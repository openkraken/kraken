interface Event {
  /**s
  * Returns true or false depending on how event was initialized. True if event goes through its target's ancestors in reverse tree order, and false otherwise.
  */
  readonly bubbles: boolean;
  cancelBubble: boolean;
  /**
   * Returns true or false depending on how event was initialized. Its return value does not always carry meaning, but true can indicate that part of the operation during which event was dispatched, can be canceled by invoking the preventDefault() method.
   */
  readonly cancelable: boolean;
  /**
   * Returns the object whose event listener's callback is currently being invoked.
   */
  readonly currentTarget: EventTarget | null;
  /**
   * Returns true if preventDefault() was invoked successfully to indicate cancelation, and false otherwise.
   */
  readonly defaultPrevented: boolean;
  readonly srcElement: EventTarget | null;
  readonly target: EventTarget | null;
  /**
   * Returns the event's timestamp as the number of milliseconds measured relative to the time origin.
   */
  readonly timeStamp: number;
  /**
   * Returns the type of event, e.g. "click", "hashchange", or "submit".
   */
  readonly type: string;
  /** @deprecated */
  initEvent(type: string, bubbles?: boolean, cancelable?: boolean): void;
  /**
   * If invoked when the cancelable attribute value is true, and while executing a listener for the event with passive set to false, signals to the operation that caused event to be dispatched that it needs to be canceled.
   */
  preventDefault(): void;
  /**
   * Invoking this method prevents event from reaching any registered event listeners after the current one finishes running and, when dispatched in a tree, also prevents event from reaching any other objects.
   */
  stopImmediatePropagation(): void;
  /**
   * When dispatched in a tree, invoking this method prevents event from reaching any objects other than the current object.
   */
  stopPropagation(): void;
}
