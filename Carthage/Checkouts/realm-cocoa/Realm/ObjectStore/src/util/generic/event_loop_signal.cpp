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

#include "event_loop_signal.hpp"

using namespace realm::util;

GenericEventLoop (*realm::util::s_get_eventloop)() = [] { return GenericEventLoop(); };

void (*realm::util::s_post_on_eventloop)(GenericEventLoop, EventLoopPostHandler*, void* user_data) = [](GenericEventLoop, EventLoopPostHandler*, void*) { };

void (*realm::util::s_release_eventloop)(GenericEventLoop) = [](GenericEventLoop) { };
