import {KrakenBlob, krakenBlob} from './kraken';

class BlobClass {
  public size: number;
  public type: string;
  private blob: KrakenBlob;
  constructor(blobParts?: BlobPart[], options?: BlobPropertyBag) {
    let blob = krakenBlob(blobParts, options)
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

Object.defineProperty(global, 'Blob', {
  configurable: false,
  enumerable: true,
  value: BlobClass,
  writable: false
});