////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#include <uv.h>

namespace realm {
namespace util {
template<typename Callback>
class EventLoopSignal {
public:
    EventLoopSignal(Callback&& callback)
    {
        m_handle->data = new Callback(std::move(callback));

        // This assumes that only one thread matters: the main thread (default loop).
        uv_async_init(uv_default_loop(), m_handle, [](uv_async_t* handle) {
            (*static_cast<Callback*>(handle->data))();
        });
    }

    ~EventLoopSignal()
    {
        uv_close((uv_handle_t*)m_handle, [](uv_handle_t* handle) {
            delete static_cast<Callback*>(handle->data);
            delete reinterpret_cast<uv_async_t*>(handle);
        });
    }

    EventLoopSignal(EventLoopSignal&&) = delete;
    EventLoopSignal& operator=(EventLoopSignal&&) = delete;
    EventLoopSignal(EventLoopSignal const&) = delete;
    EventLoopSignal& operator=(EventLoopSignal const&) = delete;

    void notify()
    {
        uv_async_send(m_handle);
    }

private:
    uv_async_t* m_handle = new uv_async_t;
};
} // namespace util
} // namespace realm
