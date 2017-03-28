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

#include "impl/external_commit_helper.hpp"

#include "impl/realm_coordinator.hpp"

#include <algorithm>
#include <codecvt>

using namespace realm;
using namespace realm::_impl;

static HANDLE CreateNotificationEvent(std::string realm_path)
{
    // replace backslashes because they're significant in object namespace names
    std::replace(realm_path.begin(), realm_path.end(), '\\', '/');

    std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
    std::wstring path(L"Local\\" + converter.from_bytes(realm_path));

    HANDLE event = CreateEventEx(nullptr, path.c_str(), CREATE_EVENT_MANUAL_RESET, SYNCHRONIZE | EVENT_MODIFY_STATE);
    if (event == nullptr) {
        throw std::system_error(GetLastError(), std::system_category());
    }

    return event;
}

ExternalCommitHelper::ExternalCommitHelper(RealmCoordinator& parent)
: m_parent(parent)
, m_event(CreateNotificationEvent(parent.get_path()))
, m_close_mutex(CreateMutexEx(nullptr, nullptr, CREATE_MUTEX_INITIAL_OWNER, SYNCHRONIZE | MUTEX_MODIFY_STATE))
{
    m_thread = std::async(std::launch::async, [this]() { listen(); });
}

ExternalCommitHelper::~ExternalCommitHelper()
{
    ReleaseMutex(m_close_mutex);
    m_thread.wait();

    CloseHandle(m_event);
    CloseHandle(m_close_mutex);
}

void ExternalCommitHelper::notify_others()
{
    SetEvent(m_event);
    std::this_thread::yield();
    ResetEvent(m_event);
}

void ExternalCommitHelper::listen()
{
    std::array<HANDLE, 2> handles{ m_event, m_close_mutex };
    while (true) {
        DWORD wait_result = WaitForMultipleObjectsEx(handles.size(), handles.data(), false, INFINITE, false);
        switch (wait_result) {
        case WAIT_OBJECT_0: // event signaled 
            m_parent.on_change();
            continue;
        case WAIT_OBJECT_0 + 1: // mutex released
            return; // exit the loop
        case WAIT_FAILED:
            throw std::system_error(GetLastError(), std::system_category());
        }
    }
    REALM_UNREACHABLE();
}
