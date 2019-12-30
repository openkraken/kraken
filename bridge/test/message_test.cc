#include "message.h"
#include "gtest/gtest.h"
#include <iostream>

TEST(message, get_name) {
  kraken::message::Message message;

  message.parseMessageBody("name=1123;age=10");
  std::string result;
  message.readMessage("name", result);
  EXPECT_EQ(result, "1123");
}

TEST(message, get_age) {
  kraken::message::Message message;

  message.parseMessageBody("name=1123;age=10;");
  std::string result;
  message.readMessage("age", result);
  EXPECT_EQ(result, "10");
}

TEST(message, getRepeatToken) {
  kraken::message::Message message;

  message.parseMessageBody(
      "error=Socket error, time = 0.0, cost = 1.2;name=1234");
  std::string result;
  message.readMessage("error", result);
  EXPECT_EQ(result, "Socket error, time = 0.0, cost = 1.2");
}

TEST(message, getBracketsValue) {
  kraken::message::Message message;

  std::string result;
  message.getBracketsValue("22[100]=2", result);
  EXPECT_EQ(result, "100");
}
