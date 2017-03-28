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

#include "catch.hpp"
#include "object_store.hpp"
#include <realm/string_data.hpp>

using namespace realm;

TEST_CASE("ObjectStore: table_name_for_object_type()") {

    SECTION("should work with strings that aren't null-terminated") {
        auto input = StringData("good_no_bad", 4);
        auto result = ObjectStore::table_name_for_object_type(input);
        REQUIRE(result == "class_good");
    }
}
