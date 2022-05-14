/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "inspector_task_queue.h"

namespace kraken {

std::mutex InspectorTaskQueue::inspector_task_creation_mutex_{};
fml::RefPtr<InspectorTaskQueue> InspectorTaskQueue::instance_{};

}  // namespace kraken
