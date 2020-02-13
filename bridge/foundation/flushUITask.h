/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_FLUSHUITASK_H
#define KRAKENBRIDGE_FLUSHUITASK_H

#include "thread_safe_stack.h"

using Task = void (*)(void*);

namespace kraken {
namespace foundation {

void flushUITask();
void registerUITask(Task task, void* context);

}
}


#endif // KRAKENBRIDGE_FLUSHUITASK_H
