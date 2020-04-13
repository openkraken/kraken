import { EventTarget } from 'event-target-shim';
import { krakenWindow, KrakenLocation } from './bridge';
import { NodeId } from "./document/node";
import { navigator } from './navigator';

const windowBuildInEvents = ['load', 'colorschemechange'];

class Window extends EventTarget {
  constructor() {
    super(NodeId.WINDOW, windowBuildInEvents);
  }

  public get colorScheme(): string {
    return krakenWindow.colorScheme;
  }

  public get devicePixelRatio() : number {
    return krakenWindow.devicePixelRatio;
  }

  public get location(): KrakenLocation {
    return krakenWindow.location;
  }

  public get window() {
    return this;
  }

  public get parent() {
    return this;
  }

  public get navigator() {
    return navigator;
  }

  public get Promise() {
    return Promise;
  }
}

// window is global object, which is created by JSEngine, assign some
// window API from polyfill.
Object.assign(window, new Window());
