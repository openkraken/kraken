import {KrakenBlob, krakenBlob} from './bridge';

export class Blob {
  public size: number;
  public type: string;
  private blob: KrakenBlob;
  constructor(blobParts?: BlobPart[], options?: BlobPropertyBag) {
    if (Array.isArray(blobParts)) {
      // extract internal hostObject from polyfill wrapper.
      blobParts = blobParts.map(item => {
        if (item instanceof Blob) {
          // @ts-ignore
          return item.blob;
        }
        return item;
      });
    }

    let blob = krakenBlob(blobParts, options);
    this.blob = blob;
    this.size = blob.size;
    this.type = blob.type;
  }

  public slice(start?: number, end?: number, contentType?: string) {
    return this.blob.slice(start, end, contentType);
  }

  public text() {
    let self = this;
    return new Promise((resolve, reject) => {
      resolve(self.blob.text());
    });
  }

  public arrayBuffer() {
    let self = this;
    return new Promise((resolve, reject) => {
      resolve(self.blob.arrayBuffer());
    });
  }
}
