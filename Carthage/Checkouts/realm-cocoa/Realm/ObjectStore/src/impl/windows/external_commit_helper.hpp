////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
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

#include <realm/group_shared.hpp>

#include <future>
#include <windows.h>

namespace realm {
class Replication;

namespace _impl {
class RealmCoordinator;

class ExternalCommitHelper {
public:
    ExternalCommitHelper(RealmCoordinator& parent);
    ~ExternalCommitHelper();

    void notify_others();

private:
    void listen();

    RealmCoordinator& m_parent;

    // The listener thread
    std::future<void> m_thread;

    HANDLE m_event;
    HANDLE m_close_mutex;
};

} // namespace _impl
} // namespace realm

