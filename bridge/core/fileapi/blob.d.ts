interface Blob {
  readonly size: number;
  readonly type: string;
  arrayBuffer(): Promise<ArrayBuffer>;
  slice(start?: int64, end?: int64, contentType?: string): Blob;
  text(): Promise<string>;
  new(blobParts?: BlobPart[], options?: BlobPropertyBag): Blob;
}
