/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_task_queue.h"

namespace foundation {
std::mutex UITaskQueue::ui_task_creation_mutex_{};
fml::RefPtr<UITaskQueue> UITaskQueue::instance_{};
}
