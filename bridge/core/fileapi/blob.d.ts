interface Blob {
  readonly size: number;
  readonly type: string;
  arrayBuffer(): Promise<ArrayBuffer>;
  slice(start?: number, end?: number, contentType?: string): Blob;
  text(): Promise<string>;

  prototype: Blob;
  new(blobParts?: BlobPart[], options?: BlobPropertyBag): Blob;
}
