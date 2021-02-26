//
// Created by rowandjj on 2019/4/1.
//

#ifndef KRAKEN_DEBUGGER_DISPATCHER_BASE_H
#define KRAKEN_DEBUGGER_DISPATCHER_BASE_H

#include "foundation/macros.h"
#include "devtools/protocol/frontend_channel.h"
#include "foundation/logging.h"
#include "devtools/service/rpc/protocol.h"
#include "devtools/protocol/dispatch_response.h"
#include "devtools/protocol/error_support.h"

#include <string>
#include <memory>
#include <unordered_set>

namespace kraken{
    namespace Debugger {

        namespace Internal{

            /**
             *
             * jsonRPC error response
             *
             * {
             *      id:100,
             *      error:{
             *          code:10001,
             *          message:'',
             *          data:''
             *      }
             * }
             *
             * */
            static void reportProtocolErrorTo(FrontendChannel* frontendChannel,
                                              uint64_t callId,
                                              jsonRpc::ErrorCode code,
                                              const std::string& errorMessage,
                                              ErrorSupport* errors) {
                if (!frontendChannel) {
                    return;
                }

                jsonRpc::Response response;
                response.id = callId;
                response.result = jsonRpc::JSONObject(rapidjson::kObjectType);
                response.hasError = true;

                rapidjson::Document d;
                jsonRpc::JSONObject error;
                error.SetObject();// 一定要先初始化结构啊
                error.AddMember("code",code, d.GetAllocator());

                jsonRpc::JSONObject msg;
                msg.SetString(errorMessage.c_str(),errorMessage.length(),d.GetAllocator());

                error.AddMember("message", msg, d.GetAllocator());
                if(errors) {
                    jsonRpc::JSONObject err;
                    err.SetString(errors->errors().c_str(),errors->errors().length(), d.GetAllocator());
                    error.AddMember("data", err, d.GetAllocator());
                }
                response.error = std::move(error);
                frontendChannel->sendProtocolResponse(callId, std::move(response));
            }

            /**
             * jsonRPC error notification
             * A Notification is a Request object without an "id" member.
             *
             * {
             *      error:{
             *          code:'',
             *          message: ''
             *      }
             * }
             *
             * */
            static void reportProtocolErrorTo(FrontendChannel* frontendChannel,
                                              jsonRpc::ErrorCode code,
                                              const std::string& errorMessage) {
                if (!frontendChannel) {
                    return;
                }
                jsonRpc::Error error;

                error.code = code;
                error.message = errorMessage;
                error.data = jsonRpc::JSONObject(rapidjson::kObjectType);
                frontendChannel->sendProtocolError(std::move(error));
            }
        }

        class DispatcherBase {
        private:
            KRAKEN_DISALLOW_COPY(DispatcherBase);
        public:
            static const char kInvalidParamsString[];

            /*RAII*/
            class WeakPtr {
            public:
                explicit WeakPtr(DispatcherBase*);
                ~WeakPtr();
                DispatcherBase* get() { return m_dispatcher; }
                void dispose() { m_dispatcher = nullptr; }

            private:
                DispatcherBase* m_dispatcher;
            };

            class Callback {
            public:
                Callback(std::unique_ptr<WeakPtr> backendImpl,uint64_t callId,const std::string& method,jsonRpc::JSONObject message);
                virtual ~Callback();
                void dispose();

            protected:
                void sendIfActive(jsonRpc::JSONObject message, const DispatchResponse& response);
                void fallThroughIfActive();

            private:
                std::unique_ptr<WeakPtr> m_backendImpl;
                uint64_t m_callId;
                std::string m_method;

                jsonRpc::JSONObject m_message;
            };

            explicit DispatcherBase(Debugger::FrontendChannel*);
            virtual ~DispatcherBase();

            virtual bool canDispatch(const std::string& method) = 0;
            virtual void dispatch(uint64_t callId, const std::string& method, jsonRpc::JSONObject message) = 0;
            FrontendChannel* channel() { return m_frontendChannel; }

            void sendResponse(uint64_t callId, const DispatchResponse&, jsonRpc::JSONObject result);
            void sendResponse(uint64_t callId, const DispatchResponse&);

            void reportProtocolError(uint64_t callId, jsonRpc::ErrorCode, const std::string& errorMessage, ErrorSupport* errors);
            void clearFrontend();

            std::unique_ptr<WeakPtr> weakPtr();

        private:
            FrontendChannel* m_frontendChannel;
            std::unordered_set<WeakPtr*> m_weakPtrs;
        };
    }
}

#endif //KRAKEN_DEBUGGER_DISPATCHER_BASE_H
