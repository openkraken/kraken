/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "inspector_task_queue.h"

namespace foundation {

std::mutex InspectorTaskQueue::inspector_task_creation_mutex_{};
fml::RefPtr<InspectorTaskQueue> InspectorTaskQueue::instance_{};

}  // namespace foundation
