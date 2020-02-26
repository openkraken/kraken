/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef JSA_JSA_H_
#define JSA_JSA_H_

#include "js_context.h"
#include "js_error.h"
#include "js_type.h"
#include "instrumentation.h"
#include "macros.h"

#ifdef KRAKEN_JSC_ENGINE
#include "jsc/jsc_implementation.h"
#endif

#ifdef KRAKEN_V8_ENGINE
#include "v8/v8_implementation.h"
#endif

#endif // JSA_JSA_H_
