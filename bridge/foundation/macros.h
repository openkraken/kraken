#ifndef KRAKEN_MACROS_H_
#define KRAKEN_MACROS_H_

//////////

/////////////////

#define KRAKEN_DISALLOW_COPY(TypeName) TypeName(const TypeName &) = delete

#define KRAKEN_DISALLOW_ASSIGN(TypeName) TypeName &operator=(const TypeName &) = delete

#define KRAKEN_DISALLOW_MOVE(TypeName)                                                                                 \
  TypeName(TypeName &&) = delete;                                                                                      \
  TypeName &operator=(TypeName &&) = delete

#define KRAKEN_DISALLOW_COPY_AND_ASSIGN(TypeName)                                                                      \
  TypeName(const TypeName &) = delete;                                                                                 \
  TypeName &operator=(const TypeName &) = delete

#define KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName)                                                                 \
  TypeName(const TypeName &) = delete;                                                                                 \
  TypeName(TypeName &&) = delete;                                                                                      \
  TypeName &operator=(const TypeName &) = delete;                                                                      \
  TypeName &operator=(TypeName &&) = delete

#define KRAKEN_DISALLOW_IMPLICIT_CONSTRUCTORS(TypeName)                                                                \
  TypeName() = delete;                                                                                                 \
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName)

#endif // KRAKEN_MACROS_H_
