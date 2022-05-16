import {EventTarget} from "../dom/events/event_target";

interface Window extends EventTarget {
  open(url?: string): Window | null;
}
