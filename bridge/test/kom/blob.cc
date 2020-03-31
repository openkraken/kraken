/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include "gtest/gtest.h"
#include "bridge.h"
#include "jsa.h"
#include "dart_methods.h"
#include <memory>

using namespace alibaba;

void handleError(const jsa::JSError &error) {
  std::cerr << error.what() << std::endl;
  FAIL();
}

#define MOCK_DART_METHOD \
  kraken::getDartMethod()->onPlatformBrightnessChanged = []() {}


// The fixture for testing class Foo.
class BlobTest : public ::testing::Test {
protected:
  // You can remove any or all of the following functions if their bodies would
  // be empty.

  BlobTest() {
    // You can do set-up work for each test here.
    MOCK_DART_METHOD;
  }

  ~BlobTest() override {
    // You can do clean-up work that doesn't throw exceptions here.
  }

  void SetUp() override {
    // Code here will be called immediately after the constructor (right
    // before each test).
  }

  void TearDown() override {
    // Code here will be called immediately after each test (right
    // before the destructor).
  }
};

TEST_F(BlobTest, initWithString) {
  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  jsa::JSContext *context = bridge->getContext();
  jsa::Value result = bridge->evaluateScript("new Blob(['1234']);", "", 0);
  EXPECT_EQ(result.isObject(), true);
  size_t size = result.getObject(*context).getProperty(*context, "size").getNumber();
  EXPECT_EQ(size, 4);
}

TEST_F(BlobTest, initWithAnotherBlob) {
  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  jsa::JSContext *context = bridge->getContext();
  jsa::Value result = bridge->evaluateScript(R"(
var blob = new Blob(['1234']);
new Blob([blob]);
)", "internal://", 0);
  EXPECT_EQ(result.isObject(), true);
  size_t size = result.getObject(*context).getProperty(*context, "size").getNumber();
  EXPECT_EQ(size, 4);
}

TEST_F(BlobTest, initWithArrayBuffer) {
  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  jsa::JSContext *context = bridge->getContext();
  jsa::Value result = bridge->evaluateScript(R"(
new Blob([new Int8Array([1,2,3,4,5]).buffer]);
)", "", 0);
  EXPECT_EQ(result.isObject(), true);
  size_t size = result.getObject(*context).getProperty(*context, "size").getNumber();
  EXPECT_EQ(size, 5);
}

TEST_F(BlobTest, initWithArrayBufferView) {
  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  jsa::JSContext *context = bridge->getContext();
  jsa::Value result = bridge->evaluateScript(R"(
new Blob([new Int8Array([1,2,3,4,5])]);
)", "", 0);
  EXPECT_EQ(result.isObject(), true);
  size_t size = result.getObject(*context).getProperty(*context, "size").getNumber();
  EXPECT_EQ(size, 5);
}

TEST_F(BlobTest, sliceWithStart) {
  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  jsa::JSContext *context = bridge->getContext();
  jsa::Value result = bridge->evaluateScript(R"(
let blob = new Blob([new Int8Array([1,2,3,4,5])]);
blob.slice(1);
)", "", 0);
  EXPECT_EQ(result.isObject(), true);
  size_t size = result.getObject(*context).getProperty(*context, "size").getNumber();
  EXPECT_EQ(size, 4);
}

TEST_F(BlobTest, sliceWithStartEnd) {
  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  jsa::JSContext *context = bridge->getContext();
  jsa::Value result = bridge->evaluateScript(R"(
let blob = new Blob([new Int8Array([1,2,3,4,5])]);
blob.slice(1, 3);
)", "", 0);
  EXPECT_EQ(result.isObject(), true);
  size_t size = result.getObject(*context).getProperty(*context, "size").getNumber();
  EXPECT_EQ(size, 2);
}

TEST_F(BlobTest, sliceWithStartWithJsaApi) {
  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  jsa::JSContext *context = bridge->getContext();
  jsa::Value result = bridge->evaluateScript(R"(
new Blob([new Int8Array([1,2,3,4,5])]);
)", "", 0);
  EXPECT_EQ(result.isObject(), true);
  size_t size = result.getObject(*context).getProperty(*context, "size").getNumber();
  EXPECT_EQ(size, 5);
  jsa::Value newBlob = result.getObject(*context)
      .getPropertyAsFunction(*context, "slice")
      .callWithThis(*context,
                    result.getObject(*context), {
                        jsa::Value(1)
                    });
  EXPECT_EQ(newBlob.isObject(), true);
}

TEST_F(BlobTest, text) {
  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  jsa::JSContext *context = bridge->getContext();
  jsa::Value result = bridge->evaluateScript(R"(
var blob = __kraken_blob__([new Int8Array([97,98,99,100,101])]);
blob.text();
)", "", 0);
  EXPECT_EQ(result.isString(), true);
  EXPECT_EQ(result.getString(*context).utf8(*context), "abcde");
}

TEST_F(BlobTest, arrayBuffer) {
  std::unique_ptr<kraken::JSBridge> bridge = std::make_unique<kraken::JSBridge>(handleError);
  jsa::JSContext *context = bridge->getContext();
  jsa::Value result = bridge->evaluateScript(R"(
var blob = __kraken_blob__([new Int8Array([97,98,99,100,101])]);
blob.arrayBuffer();
)", "", 0);
  EXPECT_EQ(result.isObject(), true);
  EXPECT_EQ(result.getObject(*context).isArrayBuffer(*context), true);
  jsa::ArrayBuffer arrayBuffer = result.getObject(*context).getArrayBuffer(*context);
  EXPECT_EQ(arrayBuffer.size(*context), 5);
  uint8_t *data = arrayBuffer.data<uint8_t>(*context);
  EXPECT_EQ(data[0], 97);
  EXPECT_EQ(data[1], 98);
  EXPECT_EQ(data[2], 99);
  EXPECT_EQ(data[3], 100);
  EXPECT_EQ(data[4], 101);
}