interface AnchorElement extends Element {
  href: string;
  target: string;
  accessKey: string;
  hash: string;
  host: string;
  hostname: string;
  port: string;
  readonly origin: string;
  password: string;
  pathname: string;
  protocol: string;
}
