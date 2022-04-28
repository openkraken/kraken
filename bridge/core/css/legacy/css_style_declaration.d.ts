export interface CSSStyleDeclaration {
  // @ts-ignore
  readonly length: int64;
  // @ts-ignore
  getPropertyValue(property: string): string;
  // @ts-ignore
  setProperty(property: string, value: string): void;
  // @ts-ignore
  removeProperty(property: string): string;

  [prop: string]: string;

  new(): void;
}
