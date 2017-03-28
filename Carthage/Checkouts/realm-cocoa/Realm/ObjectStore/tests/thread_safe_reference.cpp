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

#include "util/test_file.hpp"

#include "list.hpp"
#include "object.hpp"
#include "object_schema.hpp"
#include "object_store.hpp"
#include "results.hpp"
#include "schema.hpp"
#include "thread_safe_reference.hpp"

#include <realm/history.hpp>
#include <realm/util/optional.hpp>

#include <future>
#include <thread>

using namespace realm;

static TableRef get_table(Realm& realm, const ObjectSchema &object_schema) {
    return ObjectStore::table_for_object_type(realm.read_group(), object_schema.name);
}

static Object create_object(SharedRealm realm, const ObjectSchema &object_schema) {
    TableRef table = get_table(*realm, object_schema);
    return Object(std::move(realm), object_schema, (*table)[table->add_empty_row()]);
}

static List get_list(const Object& object, size_t column_ndx) {
    return List(object.realm(), object.row().get_linklist(column_ndx));
}

static Property nullable(Property p) {
    p.is_nullable = true;
    return p;
}

TEST_CASE("thread safe reference") {
    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;

    SharedRealm r = Realm::get_shared_realm(config);

    static const ObjectSchema foo_object({"foo_object", {
        {"ignore_me", PropertyType::Int}, // Used in tests cases that don't care about the value.
    }});
    static const ObjectSchema string_object({"string_object", {
        nullable({"value", PropertyType::String}),
    }});
    static const ObjectSchema int_object({"int_object", {
        {"value", PropertyType::Int},
    }});
    static const ObjectSchema int_array_object({"int_array_object", {
        {"value", PropertyType::Array, "int_object"}
    }});
    r->update_schema({foo_object, string_object, int_object, int_array_object});

    // Convenience object
    r->begin_transaction();
    Object foo = create_object(r, foo_object);
    r->commit_transaction();

    SECTION("disallowed during write transactions") {
        SECTION("obtain") {
            r->begin_transaction();
            REQUIRE_THROWS(r->obtain_thread_safe_reference(foo));
        }
        SECTION("resolve") {
            auto ref = r->obtain_thread_safe_reference(foo);
            r->begin_transaction();
            REQUIRE_THROWS(r->resolve_thread_safe_reference(std::move(ref)));
        }
    }

    SECTION("cleanup properly unpins version") {
        auto history = make_in_realm_history(config.path);
        SharedGroup shared_group(*history, config.options());

        auto get_current_version = [&]() -> VersionID {
            shared_group.begin_read();
            auto version = shared_group.get_version_of_current_transaction();
            shared_group.end_read();
            return version;
        };

        auto reference_version = get_current_version();
        auto ref = util::make_optional(r->obtain_thread_safe_reference(foo));
        r->begin_transaction(); r->commit_transaction(); // Advance version

        REQUIRE(get_current_version() != reference_version); // Ensure advanced
        REQUIRE_NOTHROW(shared_group.begin_read(reference_version)); shared_group.end_read(); // Ensure pinned

        SECTION("destroyed without being resolved") {
            ref = {}; // Destroy thread safe reference, unpinning version
        }
        SECTION("exception thrown on resolve") {
            r->begin_transaction(); // Get into state that'll throw exception on resolve
            REQUIRE_THROWS(r->resolve_thread_safe_reference(std::move(*ref)));
            r->commit_transaction();
        }
        r->begin_transaction(); r->commit_transaction(); // Clean up old versions
        REQUIRE_THROWS(shared_group.begin_read(reference_version)); // Ensure unpinned
    }

    SECTION("version mismatch") {
#ifndef _MSC_VER // Visual C++'s buggy <future> needs its template argument to be default constructible so skip this test
        SECTION("resolves at older version") {
            r->begin_transaction();
            Object num = create_object(r, int_object);
            num.row().set_int(0, 7);
            r->commit_transaction();

            REQUIRE(num.row().get_int(0) == 7);
            auto ref = std::async([config]() -> auto {
                SharedRealm r = Realm::get_shared_realm(config);
                auto results = Results(r, get_table(*r, int_object)->where());
                REQUIRE(results.size() == 1);
                Object num = Object(r, int_object, results.get(0));
                REQUIRE(num.row().get_int(0) == 7);

                r->begin_transaction();
                num.row().set_int(0, 9);
                r->commit_transaction();
                REQUIRE(num.row().get_int(0) == 9);

                return r->obtain_thread_safe_reference(num);
            }).get();
            REQUIRE(num.row().get_int(0) == 7);
            Object num_prime = r->resolve_thread_safe_reference(std::move(ref));
            REQUIRE(num_prime.row().get_int(0) == 9);
            REQUIRE(num.row().get_int(0) == 9);
            r->begin_transaction();
            num.row().set_int(0, 11);
            r->commit_transaction();
            REQUIRE(num_prime.row().get_int(0) == 11);
            REQUIRE(num.row().get_int(0) == 11);
        }
#endif
        SECTION("resolve at newer version") {
            r->begin_transaction();
            Object num = create_object(r, int_object);
            num.row().set_int(0, 7);
            r->commit_transaction();

            REQUIRE(num.row().get_int(0) == 7);
            auto ref = r->obtain_thread_safe_reference(num);
            std::thread([ref = std::move(ref), config]() mutable {
                SharedRealm r = Realm::get_shared_realm(config);
                auto results = Results(r, get_table(*r, int_object)->where());
                REQUIRE(results.size() == 1);
                Object num = Object(r, int_object, results.get(0));
                REQUIRE(num.row().get_int(0) == 7);

                r->begin_transaction();
                num.row().set_int(0, 9);
                r->commit_transaction();
                REQUIRE(num.row().get_int(0) == 9);

                Object num_prime = r->resolve_thread_safe_reference(std::move(ref));
                REQUIRE(num_prime.row().get_int(0) == 9);
                r->begin_transaction();
                num_prime.row().set_int(0, 11);
                r->commit_transaction();
                REQUIRE(num.row().get_int(0) == 11);
                REQUIRE(num_prime.row().get_int(0) == 11);
            }).join();
            REQUIRE(num.row().get_int(0) == 7);
            r->refresh();
            REQUIRE(num.row().get_int(0) == 11);
        }
        SECTION("resolve references at multiple versions") {
            auto commit_new_num = [&](int value) -> Object {
                r->begin_transaction();
                Object num = create_object(r, int_object);
                num.row().set_int(0, value);
                r->commit_transaction();
                return num;
            };

            auto ref1 = r->obtain_thread_safe_reference(commit_new_num(1));
            auto ref2 = r->obtain_thread_safe_reference(commit_new_num(2));
            std::thread([ref1 = std::move(ref1), ref2 = std::move(ref2), config]() mutable {
                SharedRealm r = Realm::get_shared_realm(config);
                Object num1 = r->resolve_thread_safe_reference(std::move(ref1));
                Object num2 = r->resolve_thread_safe_reference(std::move(ref2));

                REQUIRE(num1.row().get_int(0) == 1);
                REQUIRE(num2.row().get_int(0) == 2);
            }).join();
        }
    }

    SECTION("same thread") {
        r->begin_transaction();
        Object num = create_object(r, int_object);
        num.row().set_int(0, 7);
        r->commit_transaction();

        REQUIRE(num.row().get_int(0) == 7);
        auto ref = r->obtain_thread_safe_reference(num);
        SECTION("same realm") {
            {
                Object num = r->resolve_thread_safe_reference(std::move(ref));
                REQUIRE(num.row().get_int(0) == 7);
                r->begin_transaction();
                num.row().set_int(0, 9);
                r->commit_transaction();
                REQUIRE(num.row().get_int(0) == 9);
            }
            REQUIRE(num.row().get_int(0) == 9);
        }
        SECTION("different realm") {
            {
                config.cache = false;
                SharedRealm r = Realm::get_shared_realm(config);
                Object num = r->resolve_thread_safe_reference(std::move(ref));
                REQUIRE(num.row().get_int(0) == 7);
                r->begin_transaction();
                num.row().set_int(0, 9);
                r->commit_transaction();
                REQUIRE(num.row().get_int(0) == 9);
            }
            REQUIRE(num.row().get_int(0) == 7);
        }
        r->refresh();
        REQUIRE(num.row().get_int(0) == 9);
    }

    SECTION("passing over") {
        SECTION("nothing") {
            r->begin_transaction();
            Object num = create_object(r, int_object);
            r->commit_transaction();

            auto results = Results(r, get_table(*r, int_object)->where());
            REQUIRE(results.size() == 1);
            auto ref = r->obtain_thread_safe_reference(foo);
            std::thread([ref = std::move(ref), config]() mutable {
                SharedRealm r = Realm::get_shared_realm(config);
                auto ref_val = r->resolve_thread_safe_reference(std::move(ref));

                auto results = Results(r, get_table(*r, int_object)->where());
                REQUIRE(results.size() == 1);
                r->begin_transaction();
                Object num = create_object(r, int_object);
                r->commit_transaction();
                REQUIRE(results.size() == 2);
            }).join();
            REQUIRE(results.size() == 1);
            r->refresh();
            REQUIRE(results.size() == 2);
        }

        SECTION("objects") {
            r->begin_transaction();
            Object str = create_object(r, string_object);
            Object num = create_object(r, int_object);
            r->commit_transaction();

            REQUIRE(str.row().get_string(0).is_null());
            REQUIRE(num.row().get_int(0) == 0);
            auto ref_str = r->obtain_thread_safe_reference(str);
            auto ref_num = r->obtain_thread_safe_reference(num);
            std::thread([ref_str = std::move(ref_str), ref_num = std::move(ref_num), config]() mutable {
                SharedRealm r = Realm::get_shared_realm(config);
                Object str = r->resolve_thread_safe_reference(std::move(ref_str));
                Object num = r->resolve_thread_safe_reference(std::move(ref_num));

                REQUIRE(str.row().get_string(0).is_null());
                REQUIRE(num.row().get_int(0) == 0);
                r->begin_transaction();
                str.row().set_string(0, "the meaning of life");
                num.row().set_int(0, 42);
                r->commit_transaction();
                REQUIRE(str.row().get_string(0) == "the meaning of life");
                REQUIRE(num.row().get_int(0) == 42);
            }).join();

            REQUIRE(str.row().get_string(0).is_null());
            REQUIRE(num.row().get_int(0) == 0);
            r->refresh();
            REQUIRE(str.row().get_string(0) == "the meaning of life");
            REQUIRE(num.row().get_int(0) == 42);
        }

        SECTION("array") {
            r->begin_transaction();
            Object zero = create_object(r, int_object);
            zero.row().set_int(0, 0);
            List lst = get_list(create_object(r, int_array_object), 0);
            lst.add(zero.row().get_index());
            r->commit_transaction();

            REQUIRE(lst.size() == 1);
            REQUIRE(lst.get(0).get_int(0) == 0);
            auto ref = r->obtain_thread_safe_reference(lst);
            std::thread([ref = std::move(ref), config]() mutable {
                SharedRealm r = Realm::get_shared_realm(config);
                List lst = r->resolve_thread_safe_reference(std::move(ref));

                REQUIRE(lst.size() == 1);
                REQUIRE(lst.get(0).get_int(0) == 0);
                r->begin_transaction();
                lst.remove_all();
                Object one = create_object(r, int_object);
                one.row().set_int(0, 1);
                lst.add(one.row().get_index());
                Object two = create_object(r, int_object);
                two.row().set_int(0, 2);
                lst.add(two.row().get_index());
                r->commit_transaction();
                REQUIRE(lst.size() == 2);
                REQUIRE(lst.get(0).get_int(0) == 1);
                REQUIRE(lst.get(1).get_int(0) == 2);
            }).join();

            REQUIRE(lst.size() == 1);
            REQUIRE(lst.get(0).get_int(0) == 0);
            r->refresh();
            REQUIRE(lst.size() == 2);
            REQUIRE(lst.get(0).get_int(0) == 1);
            REQUIRE(lst.get(1).get_int(0) == 2);
        }

        SECTION("sorted results") {
            auto& table = *get_table(*r, string_object);
            auto results = Results(r, table.where().not_equal(0, "C")).sort({table, {{0}}, {false}});

            r->begin_transaction();
            Object strA = create_object(r, string_object);
            strA.row().set_string(0, "A");
            Object strB = create_object(r, string_object);
            strB.row().set_string(0, "B");
            Object strC = create_object(r, string_object);
            strC.row().set_string(0, "C");
            Object strD = create_object(r, string_object);
            strD.row().set_string(0, "D");
            r->commit_transaction();

            REQUIRE(results.size() == 3);
            REQUIRE(results.get(0).get_string(0) == "D");
            REQUIRE(results.get(1).get_string(0) == "B");
            REQUIRE(results.get(2).get_string(0) == "A");
            auto ref = r->obtain_thread_safe_reference(results);
            std::thread([ref = std::move(ref), config]() mutable {
                SharedRealm r = Realm::get_shared_realm(config);
                Results results = r->resolve_thread_safe_reference(std::move(ref));

                REQUIRE(results.size() == 3);
                REQUIRE(results.get(0).get_string(0) == "D");
                REQUIRE(results.get(1).get_string(0) == "B");
                REQUIRE(results.get(2).get_string(0) == "A");
                r->begin_transaction();
                results.get(2).move_last_over();
                results.get(0).move_last_over();
                Object strE = create_object(r, string_object);
                strE.row().set_string(0, "E");
                r->commit_transaction();
                REQUIRE(results.size() == 2);
                REQUIRE(results.get(0).get_string(0) == "E");
                REQUIRE(results.get(1).get_string(0) == "B");
            }).join();

            REQUIRE(results.size() == 3);
            REQUIRE(results.get(0).get_string(0) == "D");
            REQUIRE(results.get(1).get_string(0) == "B");
            REQUIRE(results.get(2).get_string(0) == "A");
            r->refresh();
            REQUIRE(results.size() == 2);
            REQUIRE(results.get(0).get_string(0) == "E");
            REQUIRE(results.get(1).get_string(0) == "B");
        }

        SECTION("distinct results") {
            auto& table = *get_table(*r, string_object);
            // Sort the results to make checks easier.
            auto results = Results(r, table.where()).distinct({table, {{0}}}).sort({table, {{0}}, {true}});

            r->begin_transaction();
            Object strA1 = create_object(r, string_object);
            strA1.row().set_string(0, "A");
            Object strA2 = create_object(r, string_object);
            strA2.row().set_string(0, "A");
            Object strB1 = create_object(r, string_object);
            strB1.row().set_string(0, "B");
            r->commit_transaction();

            REQUIRE(results.size() == 2);
            REQUIRE(results.get(0).get_string(0) == "A");
            REQUIRE(results.get(1).get_string(0) == "B");
            auto ref = r->obtain_thread_safe_reference(results);
            std::thread([ref = std::move(ref), config]() mutable {
                SharedRealm r = Realm::get_shared_realm(config);
                Results results = r->resolve_thread_safe_reference(std::move(ref));

                REQUIRE(results.size() == 2);
                REQUIRE(results.get(0).get_string(0) == "A");
                REQUIRE(results.get(1).get_string(0) == "B");

                r->begin_transaction();
                results.get(0).move_last_over();
                Object strC = create_object(r, string_object);
                strC.row().set_string(0, "C");
                r->commit_transaction();
                REQUIRE(results.size() == 3);
                REQUIRE(results.get(0).get_string(0) == "A");
                REQUIRE(results.get(1).get_string(0) == "B");
                REQUIRE(results.get(2).get_string(0) == "C");
            }).join();

            REQUIRE(results.size() == 2);
            REQUIRE(results.get(0).get_string(0) == "A");
            REQUIRE(results.get(1).get_string(0) == "B");
            r->refresh();
            REQUIRE(results.size() == 3);
            REQUIRE(results.get(0).get_string(0) == "A");
            REQUIRE(results.get(1).get_string(0) == "B");
            REQUIRE(results.get(2).get_string(0) == "C");
        }

        SECTION("multiple types") {
            auto results = Results(r, get_table(*r, int_object)->where().equal(0, 5));

            r->begin_transaction();
            Object num = create_object(r, int_object);
            num.row().set_int(0, 5);
            List lst = get_list(create_object(r, int_array_object), 0);
            r->commit_transaction();

            REQUIRE(lst.size() == 0);
            REQUIRE(results.size() == 1);
            REQUIRE(results.get(0).get_int(0) == 5);
            auto ref_num = r->obtain_thread_safe_reference(num);
            auto ref_lst = r->obtain_thread_safe_reference(lst);
            auto ref_results = r->obtain_thread_safe_reference(results);
            std::thread([ref_num = std::move(ref_num), ref_lst = std::move(ref_lst),
                         ref_results = std::move(ref_results), config]() mutable {
                SharedRealm r = Realm::get_shared_realm(config);
                Object num = r->resolve_thread_safe_reference(std::move(ref_num));
                List lst = r->resolve_thread_safe_reference(std::move(ref_lst));
                Results results = r->resolve_thread_safe_reference(std::move(ref_results));

                REQUIRE(lst.size() == 0);
                REQUIRE(results.size() == 1);
                REQUIRE(results.get(0).get_int(0) == 5);
                r->begin_transaction();
                num.row().set_int(0, 6);
                lst.add(num.row().get_index());
                r->commit_transaction();
                REQUIRE(lst.size() == 1);
                REQUIRE(lst.get(0).get_int(0) == 6);
                REQUIRE(results.size() == 0);
            }).join();

            REQUIRE(lst.size() == 0);
            REQUIRE(results.size() == 1);
            REQUIRE(results.get(0).get_int(0) == 5);
            r->refresh();
            REQUIRE(lst.size() == 1);
            REQUIRE(lst.get(0).get_int(0) == 6);
            REQUIRE(results.size() == 0);
        }
    }

    SECTION("lifetime") {
        SECTION("retains source realm") { // else version will become unpinned
            auto ref = r->obtain_thread_safe_reference(foo);
            r = nullptr;
            r = Realm::get_shared_realm(config);
            REQUIRE_NOTHROW(r->resolve_thread_safe_reference(std::move(ref)));
        }
    }

    SECTION("metadata") {
        r->begin_transaction();
        Object num = create_object(r, int_object);
        r->commit_transaction();
        REQUIRE(num.get_object_schema().name == "int_object");
        auto ref = r->obtain_thread_safe_reference(num);
        std::thread([ref = std::move(ref), config]() mutable {
            SharedRealm r = Realm::get_shared_realm(config);
            Object num = r->resolve_thread_safe_reference(std::move(ref));
            REQUIRE(num.get_object_schema().name == "int_object");
        }).join();
    }

    SECTION("disallow multiple resolves") {
        auto ref = r->obtain_thread_safe_reference(foo);
        r->resolve_thread_safe_reference(std::move(ref));
        REQUIRE_THROWS(r->resolve_thread_safe_reference(std::move(ref)));
    }
}
