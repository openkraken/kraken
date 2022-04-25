declare type int64 = number;
declare type double = number;

declare interface Dictionary {}

declare interface BlobPart {}
declare interface BlobPropertyBag {}
declare function Dictionary() : any;
declare type JSEventListener = void;

// This property will return new created value.
type NewObject<T> = T;

// This property is implemented by Dart side
type DartImpl<T> = T;
