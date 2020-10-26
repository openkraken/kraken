export class UnImplError extends Error {
  constructor(message: string) {
    super('UnImplError: ' + message);
  }
}
