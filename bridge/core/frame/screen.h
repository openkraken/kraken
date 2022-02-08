/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SCREEN_H
#define KRAKENBRIDGE_SCREEN_H

namespace kraken {

struct NativeScreen {
  double width;
  double height;
};

//class Screen : public HostObject {
// public:
//  explicit Screen(ExecutionContext* context) : HostObject(context, "Screen"){};
//
// private:
//  DEFINE_READONLY_PROPERTY(width);
//  DEFINE_READONLY_PROPERTY(height);
//};

//void bindScreen(ExecutionContext* context);

}  // namespace kraken

class screen {};

#endif  // KRAKENBRIDGE_SCREEN_H
