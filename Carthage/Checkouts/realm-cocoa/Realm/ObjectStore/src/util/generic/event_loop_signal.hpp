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

#include <utility>

namespace realm {
namespace util {

using GenericEventLoop = void*;
using EventLoopPostHandler = void(const void* user_data);

extern GenericEventLoop (*s_get_eventloop)();

extern void (*s_post_on_eventloop)(GenericEventLoop, EventLoopPostHandler*, void* user_data);

extern void (*s_release_eventloop)(GenericEventLoop);

template<typename Callback>
class EventLoopSignal {
public:
    EventLoopSignal(Callback&& callback) 
    : m_callback(std::move(callback))
    , m_eventloop(s_get_eventloop())
    { }

    void notify() {
        s_post_on_eventloop(m_eventloop, &on_post, this);
    }
    
    ~EventLoopSignal() {
        s_release_eventloop(m_eventloop);
    }
private:
    static void on_post(const void* user_data) {
        reinterpret_cast<const EventLoopSignal<Callback>*>(user_data)->m_callback();
    }
    
    const Callback m_callback;
    const GenericEventLoop m_eventloop;
};

} // namespace util
} // namespace realm

