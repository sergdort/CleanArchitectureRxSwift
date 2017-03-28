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

#include "util/event_loop.hpp"
#include "util/index_helpers.hpp"
#include "util/test_file.hpp"
#include "util/format.hpp"

#include "impl/realm_coordinator.hpp"
#include "binding_context.hpp"
#include "object_schema.hpp"
#include "property.hpp"
#include "results.hpp"
#include "schema.hpp"

#include <realm/group_shared.hpp>
#include <realm/link_view.hpp>
#include <realm/query_engine.hpp>

#if REALM_ENABLE_SYNC
#include "sync/sync_manager.hpp"
#include "sync/sync_session.hpp"
#endif

using namespace realm;

class joining_thread {
public:
    template<typename... Args>
    joining_thread(Args&&... args) : m_thread(std::forward<Args>(args)...) { }
    ~joining_thread() { if (m_thread.joinable()) m_thread.join(); }
    void join() { m_thread.join(); }

private:
    std::thread m_thread;
};

TEST_CASE("notifications: async delivery") {
    _impl::RealmCoordinator::assert_no_open_realms();

    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;

    auto r = Realm::get_shared_realm(config);
    r->update_schema({
        {"object", {
            {"value", PropertyType::Int}
        }},
    });

    auto coordinator = _impl::RealmCoordinator::get_existing_coordinator(config.path);
    auto table = r->read_group().get_table("class_object");

    r->begin_transaction();
    table->add_empty_row(10);
    for (int i = 0; i < 10; ++i)
        table->set_int(0, i, i * 2);
    r->commit_transaction();

    Results results(r, table->where().greater(0, 0).less(0, 10));

    int notification_calls = 0;
    auto token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
        REQUIRE_FALSE(err);
        ++notification_calls;
    });

    auto make_local_change = [&] {
        r->begin_transaction();
        table->set_int(0, 0, 4);
        r->commit_transaction();
    };

    auto make_remote_change = [&] {
        auto r2 = coordinator->get_realm();
        r2->begin_transaction();
        r2->read_group().get_table("class_object")->set_int(0, 0, 5);
        r2->commit_transaction();
    };

    SECTION("initial notification") {
        SECTION("is delivered on notify()") {
            REQUIRE(notification_calls == 0);
            advance_and_notify(*r);
            REQUIRE(notification_calls == 1);
        }

        SECTION("is delivered on refresh()") {
            coordinator->on_change();
            REQUIRE(notification_calls == 0);
            r->refresh();
            REQUIRE(notification_calls == 1);
        }

        SECTION("is delivered on begin_transaction()") {
            coordinator->on_change();
            REQUIRE(notification_calls == 0);
            r->begin_transaction();
            REQUIRE(notification_calls == 1);
            r->cancel_transaction();
        }

        SECTION("is delivered on notify() even with autorefresh disabled") {
            r->set_auto_refresh(false);
            REQUIRE(notification_calls == 0);
            advance_and_notify(*r);
            REQUIRE(notification_calls == 1);
        }

        SECTION("refresh() blocks due to initial results not being ready") {
            REQUIRE(notification_calls == 0);
            joining_thread thread([&] {
                std::this_thread::sleep_for(std::chrono::microseconds(5000));
                coordinator->on_change();
            });
            r->refresh();
            REQUIRE(notification_calls == 1);
        }

        SECTION("begin_transaction() blocks due to initial results not being ready") {
            REQUIRE(notification_calls == 0);
            joining_thread thread([&] {
                std::this_thread::sleep_for(std::chrono::microseconds(5000));
                coordinator->on_change();
            });
            r->begin_transaction();
            REQUIRE(notification_calls == 1);
            r->cancel_transaction();
        }

        SECTION("notify() does not block due to initial results not being ready") {
            REQUIRE(notification_calls == 0);
            r->notify();
            REQUIRE(notification_calls == 0);
        }

        SECTION("is delivered after invalidate()") {
            r->invalidate();

            SECTION("notify()") {
                coordinator->on_change();
                REQUIRE_FALSE(r->is_in_read_transaction());
                r->notify();
                REQUIRE(notification_calls == 1);
            }

            SECTION("notify() without autorefresh") {
                r->set_auto_refresh(false);
                coordinator->on_change();
                REQUIRE_FALSE(r->is_in_read_transaction());
                r->notify();
                REQUIRE(notification_calls == 1);
            }

            SECTION("refresh()") {
                coordinator->on_change();
                REQUIRE_FALSE(r->is_in_read_transaction());
                r->refresh();
                REQUIRE(notification_calls == 1);
            }

            SECTION("begin_transaction()") {
                coordinator->on_change();
                REQUIRE_FALSE(r->is_in_read_transaction());
                r->begin_transaction();
                REQUIRE(notification_calls == 1);
                r->cancel_transaction();
            }
        }
    }

    advance_and_notify(*r);

    SECTION("notifications for local changes") {
        make_local_change();
        coordinator->on_change();
        REQUIRE(notification_calls == 1);

        SECTION("notify()") {
            r->notify();
            REQUIRE(notification_calls == 2);
        }

        SECTION("notify() without autorefresh") {
            r->set_auto_refresh(false);
            r->notify();
            REQUIRE(notification_calls == 2);
        }

        SECTION("refresh()") {
            r->refresh();
            REQUIRE(notification_calls == 2);
        }

        SECTION("begin_transaction()") {
            r->begin_transaction();
            REQUIRE(notification_calls == 2);
            r->cancel_transaction();
        }
    }

    SECTION("notifications for remote changes") {
        make_remote_change();
        coordinator->on_change();
        REQUIRE(notification_calls == 1);

        SECTION("notify()") {
            r->notify();
            REQUIRE(notification_calls == 2);
        }

        SECTION("notify() without autorefresh") {
            r->set_auto_refresh(false);
            r->notify();
            REQUIRE(notification_calls == 1);
            r->refresh();
            REQUIRE(notification_calls == 2);
        }

        SECTION("refresh()") {
            r->refresh();
            REQUIRE(notification_calls == 2);
        }

        SECTION("begin_transaction()") {
            r->begin_transaction();
            REQUIRE(notification_calls == 2);
            r->cancel_transaction();
        }
    }

    SECTION("notifications are not delivered when the token is destroyed before they are calculated") {
        make_remote_change();
        REQUIRE(notification_calls == 1);
        token = {};
        advance_and_notify(*r);
        REQUIRE(notification_calls == 1);
    }

    SECTION("notifications are not delivered when the token is destroyed before they are delivered") {
        make_remote_change();
        REQUIRE(notification_calls == 1);
        coordinator->on_change();
        token = {};
        r->notify();
        REQUIRE(notification_calls == 1);
    }

    SECTION("notifications are delivered when a new callback is added from within a callback") {
        NotificationToken token2, token3;
        bool called = false;
        token2 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr) {
            token3 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr) {
                called = true;
            });
        });

        advance_and_notify(*r);
        REQUIRE(called);
    }

    SECTION("notifications are not delivered when a callback is removed from within a callback") {
        NotificationToken token2, token3;
        token2 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr) {
            token3 = {};
        });
        token3 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr) {
            REQUIRE(false);
        });

        advance_and_notify(*r);
    }

    SECTION("removing the current callback does not stop later ones from being called") {
        NotificationToken token2, token3;
        bool called = false;
        token2 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr) {
            token2 = {};
        });
        token3 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr) {
            called = true;
        });

        advance_and_notify(*r);

        REQUIRE(called);
    }

    SECTION("the first call of a notification can include changes if it previously ran for a different callback") {
        r->begin_transaction();
        auto token2 = results.add_notification_callback([&](CollectionChangeSet c, std::exception_ptr) {
            REQUIRE(!c.empty());
        });

        table->set_int(0, table->add_empty_row(), 5);
        r->commit_transaction();
        advance_and_notify(*r);
    }

    SECTION("handling of results not ready") {
        make_remote_change();

        SECTION("notify() does nothing") {
            r->notify();
            REQUIRE(notification_calls == 1);
            coordinator->on_change();
            r->notify();
            REQUIRE(notification_calls == 2);
        }

        SECTION("refresh() blocks") {
            REQUIRE(notification_calls == 1);
            joining_thread thread([&] {
                std::this_thread::sleep_for(std::chrono::microseconds(5000));
                coordinator->on_change();
            });
            r->refresh();
            REQUIRE(notification_calls == 2);
        }

        SECTION("refresh() advances to the first version with notifiers ready that is at least a recent as the newest at the time it is called") {
            joining_thread thread([&] {
                std::this_thread::sleep_for(std::chrono::microseconds(5000));
                make_remote_change();
                coordinator->on_change();
                make_remote_change();
            });
            // advances to the version after the one it was waiting for, but still
            // not the latest
            r->refresh();
            REQUIRE(notification_calls == 2);

            thread.join();
            REQUIRE(notification_calls == 2);

            // now advances to the latest
            coordinator->on_change();
            r->refresh();
            REQUIRE(notification_calls == 3);
        }

        SECTION("begin_transaction() blocks") {
            REQUIRE(notification_calls == 1);
            joining_thread thread([&] {
                std::this_thread::sleep_for(std::chrono::microseconds(5000));
                coordinator->on_change();
            });
            r->begin_transaction();
            REQUIRE(notification_calls == 2);
            r->cancel_transaction();
        }

        SECTION("refresh() does not block for results without callbacks") {
            token = {};
            // this would deadlock if it waits for the notifier to be ready
            r->refresh();
        }

        SECTION("begin_transaction() does not block for results without callbacks") {
            token = {};
            // this would deadlock if it waits for the notifier to be ready
            r->begin_transaction();
            r->cancel_transaction();
        }

        SECTION("begin_transaction() does not block for Results for different Realms") {
            // this would deadlock if beginning the write on the secondary Realm
            // waited for the primary Realm to be ready
            make_remote_change();

            // sanity check that the notifications never did run
            r->notify();
            REQUIRE(notification_calls == 1);
        }
    }

    SECTION("handling of stale results") {
        make_remote_change();
        coordinator->on_change();
        make_remote_change();

        SECTION("notify() uses the older version") {
            r->notify();
            REQUIRE(notification_calls == 2);
            coordinator->on_change();
            r->notify();
            REQUIRE(notification_calls == 3);
            r->notify();
            REQUIRE(notification_calls == 3);
        }

        SECTION("refresh() blocks") {
            REQUIRE(notification_calls == 1);
            joining_thread thread([&] {
                std::this_thread::sleep_for(std::chrono::microseconds(5000));
                coordinator->on_change();
            });
            r->refresh();
            REQUIRE(notification_calls == 2);
        }

        SECTION("begin_transaction() blocks") {
            REQUIRE(notification_calls == 1);
            joining_thread thread([&] {
                std::this_thread::sleep_for(std::chrono::microseconds(5000));
                coordinator->on_change();
            });
            r->begin_transaction();
            REQUIRE(notification_calls == 2);
            r->cancel_transaction();
        }
    }

    SECTION("updates are delivered after invalidate()") {
        r->invalidate();
        make_remote_change();

        SECTION("notify()") {
            coordinator->on_change();
            REQUIRE_FALSE(r->is_in_read_transaction());
            r->notify();
            REQUIRE(notification_calls == 2);
        }

        SECTION("notify() without autorefresh") {
            r->set_auto_refresh(false);
            coordinator->on_change();
            REQUIRE_FALSE(r->is_in_read_transaction());
            r->notify();
            REQUIRE(notification_calls == 1);
            r->refresh();
            REQUIRE(notification_calls == 2);
        }

        SECTION("refresh()") {
            coordinator->on_change();
            REQUIRE_FALSE(r->is_in_read_transaction());
            r->refresh();
            REQUIRE(notification_calls == 2);
        }

        SECTION("begin_transaction()") {
            coordinator->on_change();
            REQUIRE_FALSE(r->is_in_read_transaction());
            r->begin_transaction();
            REQUIRE(notification_calls == 2);
            r->cancel_transaction();
        }
    }

    SECTION("refresh() from within changes_available() do not interfere with notification delivery") {
        struct Context : BindingContext {
            Realm& realm;
            Context(Realm& realm) : realm(realm) { }

            void changes_available() override
            {
                REQUIRE(realm.refresh());
            }
        };

        make_remote_change();
        coordinator->on_change();

        r->set_auto_refresh(false);
        REQUIRE(notification_calls == 1);

        r->notify();
        REQUIRE(notification_calls == 1);

        r->m_binding_context.reset(new Context(*r));
        r->notify();
        REQUIRE(notification_calls == 2);
    }

    SECTION("refresh() from within a notification is a no-op") {
        token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            REQUIRE_FALSE(r->refresh()); // would deadlock if it actually tried to refresh
        });
        advance_and_notify(*r);
        make_remote_change(); // 1
        coordinator->on_change();
        make_remote_change(); // 2
        r->notify(); // advances to version from 1
        coordinator->on_change();
        REQUIRE(r->refresh()); // advances to version from 2
        REQUIRE_FALSE(r->refresh()); // does not advance since it's now up-to-date
    }

    SECTION("begin_transaction() from within a notification does not send notifications immediately") {
        bool first = true;
        auto token2 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            if (first)
                first = false;
            else {
                // would deadlock if it tried to send notifications as they aren't ready yet
                r->begin_transaction();
                r->cancel_transaction();
            }
        });
        advance_and_notify(*r);

        make_remote_change(); // 1
        coordinator->on_change();
        make_remote_change(); // 2
        r->notify(); // advances to version from 1
        REQUIRE(notification_calls == 2);
        coordinator->on_change();
        REQUIRE_FALSE(r->refresh()); // we made the commit locally, so no advancing here
        REQUIRE(notification_calls == 3);
    }

    SECTION("begin_transaction() from within a notification does not break delivering additional notifications") {
        size_t calls = 0;
        token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            if (++calls == 1)
                return;

            // force the read version to advance by beginning a transaction
            r->begin_transaction();
            r->cancel_transaction();
        });

        auto results2 = results;
        size_t calls2 = 0;
        auto token2 = results2.add_notification_callback([&](CollectionChangeSet c, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            if (++calls2 == 1)
                return;
            REQUIRE_INDICES(c.insertions, 0);
        });
        advance_and_notify(*r);
        REQUIRE(calls == 1);
        REQUIRE(calls2 == 1);

        make_remote_change(); // 1
        coordinator->on_change();
        make_remote_change(); // 2
        r->notify(); // advances to version from 1

        REQUIRE(calls == 2);
        REQUIRE(calls2 == 2);
    }

    SECTION("begin_transaction() from within did_change() does not break delivering collection notification") {
        struct Context : BindingContext {
            Realm& realm;
            Context(Realm& realm) : realm(realm) { }

            void did_change(std::vector<ObserverState> const&, std::vector<void*> const&, bool) override
            {
                if (!realm.is_in_transaction()) {
                    // advances to version from 2 (and recursively calls this, hence the check above)
                    realm.begin_transaction();
                    realm.cancel_transaction();
                }
            }
        };
        r->m_binding_context.reset(new Context(*r));

        make_remote_change(); // 1
        coordinator->on_change();
        make_remote_change(); // 2
        r->notify(); // advances to version from 1
    }

    SECTION("is_in_transaction() is reported correctly within a notification from begin_transaction() and changes can be made") {
        bool first = true;
        token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            if (first) {
                REQUIRE_FALSE(r->is_in_transaction());
                first = false;
            }
            else {
                REQUIRE(r->is_in_transaction());
                table->set_int(0, 0, 100);
            }
        });
        advance_and_notify(*r);
        make_remote_change();
        coordinator->on_change();
        r->begin_transaction();
        REQUIRE(table->get_int(0, 0) == 100);
        r->cancel_transaction();
        REQUIRE(table->get_int(0, 0) != 100);
    }

    SECTION("invalidate() from within notification is a no-op") {
        token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            r->invalidate();
            REQUIRE(r->is_in_read_transaction());
        });
        advance_and_notify(*r);
        REQUIRE(r->is_in_read_transaction());
        make_remote_change();
        coordinator->on_change();
        r->begin_transaction();
        REQUIRE(r->is_in_transaction());
        r->cancel_transaction();
    }

    SECTION("cancel_transaction() from within notification ends the write transaction started by begin_transaction()") {
        token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            if (r->is_in_transaction())
                r->cancel_transaction();
        });
        advance_and_notify(*r);
        make_remote_change();
        coordinator->on_change();
        r->begin_transaction();
        REQUIRE_FALSE(r->is_in_transaction());
    }
}

TEST_CASE("notifications: skip") {
    _impl::RealmCoordinator::assert_no_open_realms();

    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;

    auto r = Realm::get_shared_realm(config);
    r->update_schema({
        {"object", {
            {"value", PropertyType::Int}
        }},
    });

    auto coordinator = _impl::RealmCoordinator::get_existing_coordinator(config.path);
    auto table = r->read_group().get_table("class_object");

    r->begin_transaction();
    table->add_empty_row(10);
    for (int i = 0; i < 10; ++i)
        table->set_int(0, i, i * 2);
    r->commit_transaction();

    Results results(r, table->where());

    auto add_callback = [](Results& results, int& calls, CollectionChangeSet& changes) {
        return results.add_notification_callback([&](CollectionChangeSet c, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            ++calls;
            changes = std::move(c);
        });
    };

    auto make_local_change = [&](auto& token) {
        r->begin_transaction();
        table->add_empty_row();
        token.suppress_next();
        r->commit_transaction();
    };

    auto make_remote_change = [&] {
        auto r2 = coordinator->get_realm();
        r2->begin_transaction();
        r2->read_group().get_table("class_object")->add_empty_row();
        r2->commit_transaction();
    };

    int calls1 = 0;
    CollectionChangeSet changes1;
    auto token1 = add_callback(results, calls1, changes1);

    SECTION("no notification is sent when only callback is skipped") {
        advance_and_notify(*r);
        REQUIRE(calls1 == 1);

        make_local_change(token1);
        advance_and_notify(*r);

        REQUIRE(calls1 == 1);
        REQUIRE(changes1.empty());
    }

    SECTION("unskipped tokens for the same Results are still delivered") {
        int calls2 = 0;
        CollectionChangeSet changes2;
        auto token2 = add_callback(results, calls2, changes2);

        advance_and_notify(*r);
        REQUIRE(calls1 == 1);
        REQUIRE(calls2 == 1);

        make_local_change(token1);
        advance_and_notify(*r);

        REQUIRE(calls1 == 1);
        REQUIRE(changes1.empty());
        REQUIRE(calls2 == 2);
        REQUIRE_INDICES(changes2.insertions, 10);
    }

    SECTION("unskipped tokens for different Results are still delivered") {
        Results results2(r, table->where());
        int calls2 = 0;
        CollectionChangeSet changes2;
        auto token2 = add_callback(results2, calls2, changes2);

        advance_and_notify(*r);
        REQUIRE(calls1 == 1);
        REQUIRE(calls2 == 1);

        make_local_change(token1);
        advance_and_notify(*r);

        REQUIRE(calls1 == 1);
        REQUIRE(changes1.empty());
        REQUIRE(calls2 == 2);
        REQUIRE_INDICES(changes2.insertions, 10);
    }

    SECTION("additional commits which occur before calculation are merged in") {
        int calls2 = 0;
        CollectionChangeSet changes2;
        auto token2 = add_callback(results, calls2, changes2);

        advance_and_notify(*r);
        REQUIRE(calls1 == 1);
        REQUIRE(calls2 == 1);

        make_local_change(token1);
        make_remote_change();
        advance_and_notify(*r);

        REQUIRE(calls1 == 2);
        REQUIRE_INDICES(changes1.insertions, 11);
        REQUIRE(calls2 == 2);
        REQUIRE_INDICES(changes2.insertions, 10, 11);
    }

    SECTION("additional commits which occur before delivery are merged in") {
        int calls2 = 0;
        CollectionChangeSet changes2;
        auto token2 = add_callback(results, calls2, changes2);

        advance_and_notify(*r);
        REQUIRE(calls1 == 1);
        REQUIRE(calls2 == 1);

        make_local_change(token1);
        coordinator->on_change();
        make_remote_change();
        advance_and_notify(*r);

        REQUIRE(calls1 == 2);
        REQUIRE_INDICES(changes1.insertions, 11);
        REQUIRE(calls2 == 2);
        REQUIRE_INDICES(changes2.insertions, 10, 11);
    }

    SECTION("skipping must be done from within a write transaction") {
        REQUIRE_THROWS(token1.suppress_next());
    }

    SECTION("skipping must be done from the Realm's thread") {
        advance_and_notify(*r);
        r->begin_transaction();
        std::thread([&] {
            REQUIRE_THROWS(token1.suppress_next());
        }).join();
        r->cancel_transaction();
    }

    SECTION("new notifiers do not interfere with skipping") {
        advance_and_notify(*r);
        REQUIRE(calls1 == 1);

        CollectionChangeSet changes;

        // new notifier at a version before the skipped one
        auto r2 = coordinator->get_realm();
        Results results2(r2, r2->read_group().get_table("class_object")->where());
        int calls2 = 0;
        auto token2 = add_callback(results2, calls2, changes);

        make_local_change(token1);

        // new notifier at the skipped version
        auto r3 = coordinator->get_realm();
        Results results3(r3, r3->read_group().get_table("class_object")->where());
        int calls3 = 0;
        auto token3 = add_callback(results3, calls3, changes);

        make_remote_change();

        // new notifier at version after the skipped one
        auto r4 = coordinator->get_realm();
        Results results4(r4, r4->read_group().get_table("class_object")->where());
        int calls4 = 0;
        auto token4 = add_callback(results4, calls4, changes);

        coordinator->on_change();
        r->notify();
        r2->notify();
        r3->notify();
        r4->notify();

        REQUIRE(calls1 == 2);
        REQUIRE(calls2 == 1);
        REQUIRE(calls3 == 1);
        REQUIRE(calls4 == 1);
    }

    SECTION("skipping only effects the current transaction even if no notification would occur anyway") {
        advance_and_notify(*r);
        REQUIRE(calls1 == 1);

        // would not produce a notification even if it wasn't skipped because no changes were made
        r->begin_transaction();
        token1.suppress_next();
        r->commit_transaction();
        advance_and_notify(*r);
        REQUIRE(calls1 == 1);

        // should now produce a notification
        r->begin_transaction();
        table->add_empty_row();
        r->commit_transaction();
        advance_and_notify(*r);
        REQUIRE(calls1 == 2);
    }
}

#if REALM_PLATFORM_APPLE
TEST_CASE("notifications: async error handling") {
    _impl::RealmCoordinator::assert_no_open_realms();

    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;

    auto r = Realm::get_shared_realm(config);
    r->update_schema({
        {"object", {
            {"value", PropertyType::Int},
        }},
    });

    auto coordinator = _impl::RealmCoordinator::get_existing_coordinator(config.path);
    Results results(r, *r->read_group().get_table("class_object"));

    auto r2 = Realm::get_shared_realm(config);

    class OpenFileLimiter {
    public:
        OpenFileLimiter()
        {
            // Set the max open files to zero so that opening new files will fail
            getrlimit(RLIMIT_NOFILE, &m_old);
            rlimit rl = m_old;
            rl.rlim_cur = 0;
            setrlimit(RLIMIT_NOFILE, &rl);
        }

        ~OpenFileLimiter()
        {
            setrlimit(RLIMIT_NOFILE, &m_old);
        }

    private:
        rlimit m_old;
    };

    SECTION("error when opening the advancer SG") {
        OpenFileLimiter limiter;

        bool called = false;
        auto token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
            REQUIRE(err);
            REQUIRE_FALSE(called);
            called = true;
        });
        REQUIRE(!called);

        SECTION("error is delivered on notify() without changes") {
            coordinator->on_change();
            REQUIRE(!called);
            r->notify();
            REQUIRE(called);
        }

        SECTION("error is delivered on notify() with changes") {
            r2->begin_transaction(); r2->commit_transaction();
            REQUIRE(!called);
            coordinator->on_change();
            REQUIRE(!called);
            r->notify();
            REQUIRE(called);
        }

        SECTION("error is delivered on refresh() without changes") {
            coordinator->on_change();
            REQUIRE(!called);
            r->refresh();
            REQUIRE(called);
        }

        SECTION("error is delivered on refresh() with changes") {
            r2->begin_transaction(); r2->commit_transaction();
            REQUIRE(!called);
            coordinator->on_change();
            REQUIRE(!called);
            r->refresh();
            REQUIRE(called);
        }

        SECTION("error is delivered on begin_transaction() without changes") {
            coordinator->on_change();
            REQUIRE(!called);
            r->begin_transaction();
            REQUIRE(called);
            r->cancel_transaction();
        }

        SECTION("error is delivered on begin_transaction() with changes") {
            r2->begin_transaction(); r2->commit_transaction();
            REQUIRE(!called);
            coordinator->on_change();
            REQUIRE(!called);
            r->begin_transaction();
            REQUIRE(called);
            r->cancel_transaction();
        }

        SECTION("adding another callback does not send the error again") {
            advance_and_notify(*r);
            REQUIRE(called);

            bool called2 = false;
            auto token2 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
                REQUIRE(err);
                REQUIRE_FALSE(called2);
                called2 = true;
            });

            advance_and_notify(*r);
            REQUIRE(called2);
        }
    }

    SECTION("error when opening the executor SG") {
        SECTION("error is delivered asynchronously") {
            bool called = false;
            auto token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
                REQUIRE(err);
                called = true;
            });
            OpenFileLimiter limiter;

            REQUIRE(!called);
            coordinator->on_change();
            REQUIRE(!called);
            r->notify();
            REQUIRE(called);
        }

        SECTION("adding another callback does not send the error again") {
            bool called = false;
            auto token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
                REQUIRE(err);
                REQUIRE_FALSE(called);
                called = true;
            });
            OpenFileLimiter limiter;

            advance_and_notify(*r);

            bool called2 = false;
            auto token2 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
                REQUIRE(err);
                REQUIRE_FALSE(called2);
                called2 = true;
            });

            advance_and_notify(*r);

            REQUIRE(called2);
        }
    }
}
#endif

#if REALM_ENABLE_SYNC
TEST_CASE("notifications: sync") {
    _impl::RealmCoordinator::assert_no_open_realms();

    SyncServer server(false);
    SyncTestFile config(server);
    config.cache = false;
    config.schema = Schema{
        {"object", {
            {"value", PropertyType::Int},
        }},
    };

    SECTION("sync progress commits do not distrupt notifications") {
        auto r = Realm::get_shared_realm(config);
        auto wait_realm = Realm::get_shared_realm(config);

        Results results(r, *r->read_group().get_table("class_object"));
        Results wait_results(wait_realm, *wait_realm->read_group().get_table("class_object"));
        auto token1 = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr) { });
        auto token2 = wait_results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr) { });

        // Add an object to the Realm so that notifications are needed
        {
            auto write_realm = Realm::get_shared_realm(config);
            write_realm->begin_transaction();
            write_realm->read_group().get_table("class_object")->add_empty_row();
            write_realm->commit_transaction();
        }

        // Wait for the notifications to become ready for the new version
        wait_realm->refresh();

        // Start the server and wait for the Realm to be uploaded so that sync
        // makes some writes to the Realm and bumps the version
        server.start();
        std::condition_variable cv;
        std::mutex wait_mutex;
        std::atomic<bool> wait_flag(false);
        SyncManager::shared().get_session(config.path, *config.sync_config)->wait_for_upload_completion([&](auto) {
            wait_flag = true;
            cv.notify_one();
        });
        std::unique_lock<std::mutex> lock(wait_mutex);
        cv.wait(lock, [&]() { return wait_flag == true; });

        // Make sure that the notifications still get delivered rather than
        // waiting forever due to that we don't get a commit notification from
        // the commits sync makes to store the upload progress
        r->refresh();
    }
}
#endif

TEST_CASE("notifications: results") {
    _impl::RealmCoordinator::assert_no_open_realms();

    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;

    auto r = Realm::get_shared_realm(config);
    r->update_schema({
        {"object", {
            {"value", PropertyType::Int},
            {"link", PropertyType::Object, "linked to object", "", false, false, true}
        }},
        {"other object", {
            {"value", PropertyType::Int}
        }},
        {"linking object", {
            {"link", PropertyType::Object, "object", "", false, false, true}
        }},
        {"linked to object", {
            {"value", PropertyType::Int}
        }}
    });

    auto coordinator = _impl::RealmCoordinator::get_existing_coordinator(config.path);
    auto table = r->read_group().get_table("class_object");

    r->begin_transaction();
    table->add_empty_row(10);
    for (int i = 0; i < 10; ++i)
        table->set_int(0, i, i * 2);
    r->commit_transaction();

    auto r2 = coordinator->get_realm();
    auto r2_table = r2->read_group().get_table("class_object");

    Results results(r, table->where().greater(0, 0).less(0, 10));

    SECTION("unsorted notifications") {
        int notification_calls = 0;
        CollectionChangeSet change;
        auto token = results.add_notification_callback([&](CollectionChangeSet c, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            change = c;
            ++notification_calls;
        });

        advance_and_notify(*r);

        auto write = [&](auto&& f) {
            r->begin_transaction();
            f();
            r->commit_transaction();
            advance_and_notify(*r);
        };

        SECTION("modifications to unrelated tables do not send notifications") {
            write([&] {
                r->read_group().get_table("class_other object")->add_empty_row();
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("irrelevant modifications to linked tables do not send notifications") {
            write([&] {
                r->read_group().get_table("class_linked to object")->add_empty_row();
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("irrelevant modifications to linking tables do not send notifications") {
            write([&] {
                r->read_group().get_table("class_linking object")->add_empty_row();
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("modifications that leave a non-matching row non-matching do not send notifications") {
            write([&] {
                table->set_int(0, 6, 13);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("deleting non-matching rows does not send a notification") {
            write([&] {
                table->move_last_over(0);
                table->move_last_over(6);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("swapping adjacent matching and non-matching rows does not send notifications") {
            write([&] {
                table->swap_rows(0, 1);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("swapping non-adjacent matching and non-matching rows send a single insert/delete pair") {
            write([&] {
                table->swap_rows(0, 2);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 1);
            REQUIRE_INDICES(change.insertions, 0);
        }

        SECTION("swapping matching rows sends insert/delete pairs") {
            write([&] {
                table->swap_rows(1, 4);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 0, 3);
            REQUIRE_INDICES(change.insertions, 0, 3);

            write([&] {
                table->swap_rows(1, 2);
                table->swap_rows(2, 3);
                table->swap_rows(3, 4);
            });
            REQUIRE(notification_calls == 3);
            REQUIRE_INDICES(change.deletions, 1, 2, 3);
            REQUIRE_INDICES(change.insertions, 0, 1, 2);
        }

        SECTION("swap does not inhibit move collapsing after removals") {
            write([&] {
                table->swap_rows(2, 3);
                table->set_int(0, 3, 100);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 1);
            REQUIRE(change.insertions.empty());
        }

        SECTION("modifying a matching row and leaving it matching marks that row as modified") {
            write([&] {
                table->set_int(0, 1, 3);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.modifications, 0);
            REQUIRE_INDICES(change.modifications_new, 0);
        }

        SECTION("modifying a matching row to no longer match marks that row as deleted") {
            write([&] {
                table->set_int(0, 2, 0);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 1);
        }

        SECTION("modifying a non-matching row to match marks that row as inserted, but not modified") {
            write([&] {
                table->set_int(0, 7, 3);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.insertions, 4);
            REQUIRE(change.modifications.empty());
            REQUIRE(change.modifications_new.empty());
        }

        SECTION("deleting a matching row marks that row as deleted") {
            write([&] {
                table->move_last_over(3);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 2);
        }

        SECTION("moving a matching row via deletion marks that row as moved") {
            write([&] {
                table->where().greater_equal(0, 10).find_all().clear(RemoveMode::unordered);
                table->move_last_over(0);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_MOVES(change, {3, 0});
        }

        SECTION("moving a matching row via subsumption marks that row as modified") {
            write([&] {
                table->where().greater_equal(0, 10).find_all().clear(RemoveMode::unordered);
                table->move_last_over(0);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_MOVES(change, {3, 0});
        }

        SECTION("modifications from multiple transactions are collapsed") {
            r2->begin_transaction();
            r2_table->set_int(0, 0, 6);
            r2->commit_transaction();

            coordinator->on_change();

            r2->begin_transaction();
            r2_table->set_int(0, 1, 0);
            r2->commit_transaction();

            REQUIRE(notification_calls == 1);
            coordinator->on_change();
            r->notify();
            REQUIRE(notification_calls == 2);
        }

        SECTION("inserting a row then modifying it in a second transaction does not report it as modified") {
            r2->begin_transaction();
            size_t ndx = r2_table->add_empty_row();
            r2_table->set_int(0, ndx, 6);
            r2->commit_transaction();

            coordinator->on_change();

            r2->begin_transaction();
            r2_table->set_int(0, ndx, 7);
            r2->commit_transaction();

            advance_and_notify(*r);

            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.insertions, 4);
            REQUIRE(change.modifications.empty());
            REQUIRE(change.modifications_new.empty());
        }

        SECTION("modification indices are pre-insert/delete") {
            r->begin_transaction();
            table->set_int(0, 2, 0);
            table->set_int(0, 3, 6);
            r->commit_transaction();
            advance_and_notify(*r);

            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 1);
            REQUIRE_INDICES(change.modifications, 2);
            REQUIRE_INDICES(change.modifications_new, 1);
        }

        SECTION("notifications are not delivered when collapsing transactions results in no net change") {
            r2->begin_transaction();
            size_t ndx = r2_table->add_empty_row();
            r2_table->set_int(0, ndx, 5);
            r2->commit_transaction();

            coordinator->on_change();

            r2->begin_transaction();
            r2_table->move_last_over(ndx);
            r2->commit_transaction();

            REQUIRE(notification_calls == 1);
            coordinator->on_change();
            r->notify();
            REQUIRE(notification_calls == 1);
        }
    }

    SECTION("before/after change callback") {
        struct Callback {
            size_t before_calls = 0;
            size_t after_calls = 0;
            CollectionChangeSet before_change;
            CollectionChangeSet after_change;
            std::function<void(void)> on_before = []{};
            std::function<void(void)> on_after = []{};

            void before(CollectionChangeSet c) {
                before_change = c;
                ++before_calls;
                on_before();
            }
            void after(CollectionChangeSet c) {
                after_change = c;
                ++after_calls;
                on_after();
            }
            void error(std::exception_ptr) {
                FAIL("error() should not be called");
            }
        } callback;
        auto token = results.add_notification_callback(&callback);
        advance_and_notify(*r);

        SECTION("only after() is called for initial results") {
            REQUIRE(callback.before_calls == 0);
            REQUIRE(callback.after_calls == 1);
            REQUIRE(callback.after_change.empty());
        }

        auto write = [&](auto&& func) {
            r2->begin_transaction();
            func(*r2_table);
            r2->commit_transaction();
            advance_and_notify(*r);
        };

        SECTION("both are called after a write") {
            write([&](auto&& t) {
                t.set_int(0, t.add_empty_row(), 5);
            });
            REQUIRE(callback.before_calls == 1);
            REQUIRE(callback.after_calls == 2);
            REQUIRE_INDICES(callback.before_change.insertions, 4);
            REQUIRE_INDICES(callback.after_change.insertions, 4);
        }

        SECTION("deleted objects are usable in before()") {
            callback.on_before = [&] {
                REQUIRE(results.size() == 4);
                REQUIRE_INDICES(callback.before_change.deletions, 0);
                REQUIRE(results.get(0).is_attached());
                REQUIRE(results.get(0).get_int(0) == 2);
            };
            write([&](auto&& t) {
                t.move_last_over(results.get(0).get_index());
            });
            REQUIRE(callback.before_calls == 1);
            REQUIRE(callback.after_calls == 2);
        }

        SECTION("inserted objects are usable in after()") {
            callback.on_after = [&] {
                REQUIRE(results.size() == 5);
                REQUIRE_INDICES(callback.after_change.insertions, 4);
                REQUIRE(results.last()->get_int(0) == 5);
            };
            write([&](auto&& t) {
                t.set_int(0, t.add_empty_row(), 5);
            });
            REQUIRE(callback.before_calls == 1);
            REQUIRE(callback.after_calls == 2);
        }
    }

    SECTION("sorted notifications") {
        // Sort in descending order
        results = results.sort({*table, {{0}}, {false}});

        int notification_calls = 0;
        CollectionChangeSet change;
        auto token = results.add_notification_callback([&](CollectionChangeSet c, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            change = c;
            ++notification_calls;
        });

        advance_and_notify(*r);

        auto write = [&](auto&& f) {
            r->begin_transaction();
            f();
            r->commit_transaction();
            advance_and_notify(*r);
        };

        SECTION("swapping rows does not send notifications") {
            write([&] {
                table->swap_rows(2, 3);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("modifications that leave a non-matching row non-matching do not send notifications") {
            write([&] {
                table->set_int(0, 6, 13);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("deleting non-matching rows does not send a notification") {
            write([&] {
                table->move_last_over(0);
                table->move_last_over(6);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("modifying a matching row and leaving it matching marks that row as modified") {
            write([&] {
                table->set_int(0, 1, 3);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.modifications, 3);
            REQUIRE_INDICES(change.modifications_new, 3);
        }

        SECTION("swapping leaves modified rows marked as modified") {
            write([&] {
                table->set_int(0, 1, 3);
                table->swap_rows(1, 2);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.modifications, 3);
            REQUIRE_INDICES(change.modifications_new, 3);

            write([&] {
                table->swap_rows(3, 1);
                table->set_int(0, 1, 7);
            });
            REQUIRE(notification_calls == 3);
            REQUIRE_INDICES(change.modifications, 1);
            REQUIRE_INDICES(change.modifications_new, 1);
        }

        SECTION("modifying a matching row to no longer match marks that row as deleted") {
            write([&] {
                table->set_int(0, 2, 0);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 2);
        }

        SECTION("modifying a non-matching row to match marks that row as inserted") {
            write([&] {
                table->set_int(0, 7, 3);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.insertions, 3);
        }

        SECTION("deleting a matching row marks that row as deleted") {
            write([&] {
                table->move_last_over(3);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 1);
        }

        SECTION("moving a matching row via deletion does not send a notification") {
            write([&] {
                table->where().greater_equal(0, 10).find_all().clear(RemoveMode::unordered);
                table->move_last_over(0);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("modifying a matching row to change its position sends insert+delete") {
            write([&] {
                table->set_int(0, 2, 9);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 2);
            REQUIRE_INDICES(change.insertions, 0);
        }

        SECTION("modifications from multiple transactions are collapsed") {
            r2->begin_transaction();
            r2_table->set_int(0, 0, 5);
            r2->commit_transaction();

            r2->begin_transaction();
            r2_table->set_int(0, 1, 0);
            r2->commit_transaction();

            REQUIRE(notification_calls == 1);
            advance_and_notify(*r);
            REQUIRE(notification_calls == 2);
        }

        SECTION("moving a matching row by deleting all other rows") {
            r->begin_transaction();
            table->clear();
            table->add_empty_row(2);
            table->set_int(0, 0, 15);
            table->set_int(0, 1, 5);
            r->commit_transaction();
            advance_and_notify(*r);

            write([&] {
                table->move_last_over(0);
                table->add_empty_row();
                table->set_int(0, 1, 3);
            });

            REQUIRE(notification_calls == 3);
            REQUIRE(change.deletions.empty());
            REQUIRE_INDICES(change.insertions, 1);
        }
    }

    SECTION("distinct notifications") {
        results = results.distinct(SortDescriptor(*table, {{0}}));

        int notification_calls = 0;
        CollectionChangeSet change;
        auto token = results.add_notification_callback([&](CollectionChangeSet c, std::exception_ptr err) {
            REQUIRE_FALSE(err);
            change = c;
            ++notification_calls;
        });

        advance_and_notify(*r);

        auto write = [&](auto&& f) {
            r->begin_transaction();
            f();
            r->commit_transaction();
            advance_and_notify(*r);
        };

        SECTION("modifications that leave a non-matching row non-matching do not send notifications") {
            write([&] {
                table->set_int(0, 6, 13);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("deleting non-matching rows does not send a notification") {
            write([&] {
                table->move_last_over(0);
                table->move_last_over(6);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("modifying a matching row and leaving it matching marks that row as modified") {
            write([&] {
                table->set_int(0, 1, 3);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.modifications, 0);
            REQUIRE_INDICES(change.modifications_new, 0);
        }

        SECTION("modifying a non-matching row which is after the distinct results in the table to be a same value \
                in the distinct results doesn't send notification.") {
            write([&] {
                table->set_int(0, 6, 2);
            });
            REQUIRE(notification_calls == 1);
        }

        SECTION("modifying a non-matching row which is before the distinct results in the table to be a same value \
                in the distinct results send insert + delete.") {
            write([&] {
                table->set_int(0, 0, 2);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 0);
            REQUIRE_INDICES(change.insertions, 0);
        }

        SECTION("modifying a matching row to duplicated value in distinct results marks that row as deleted") {
            write([&] {
                table->set_int(0, 2, 2);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.deletions, 1);
        }

        SECTION("modifying a non-matching row to match and different value marks that row as inserted") {
            write([&] {
                table->set_int(0, 0, 1);
            });
            REQUIRE(notification_calls == 2);
            REQUIRE_INDICES(change.insertions, 0);
        }
    }
}

TEST_CASE("results: notifications after move") {
    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;

    auto r = Realm::get_shared_realm(config);
    r->update_schema({
        {"object", {
            {"value", PropertyType::Int},
        }},
    });

    auto table = r->read_group().get_table("class_object");
    auto results = std::make_unique<Results>(r, *table);

    int notification_calls = 0;
    auto token = results->add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
        REQUIRE_FALSE(err);
        ++notification_calls;
    });

    advance_and_notify(*r);

    auto write = [&](auto&& f) {
        r->begin_transaction();
        f();
        r->commit_transaction();
        advance_and_notify(*r);
    };

    SECTION("notifications continue to work after Results is moved (move-constructor)") {
        Results r(std::move(*results));
        results.reset();

        write([&] {
            table->set_int(0, table->add_empty_row(), 1);
        });
        REQUIRE(notification_calls == 2);
    }

    SECTION("notifications continue to work after Results is moved (move-assignment)") {
        Results r;
        r = std::move(*results);
        results.reset();

        write([&] {
            table->set_int(0, table->add_empty_row(), 1);
        });
        REQUIRE(notification_calls == 2);
    }
}

TEST_CASE("results: implicit background notifier") {
    _impl::RealmCoordinator::assert_no_open_realms();

    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;

    auto coordinator = _impl::RealmCoordinator::get_coordinator(config.path);
    auto r = coordinator->get_realm(std::move(config));
    r->update_schema({
        {"object", {
            {"value", PropertyType::Int},
        }},
    });

    auto table = r->read_group().get_table("class_object");
    Results results(r, table->where());
    results.last(); // force evaluation and creation of TableView

    SECTION("refresh() does not block due to implicit notifier") {
        auto r2 = coordinator->get_realm();
        r2->begin_transaction();
        r2->read_group().get_table("class_object")->add_empty_row();
        r2->commit_transaction();

        r->refresh(); // would deadlock if there was a callback
    }

    SECTION("refresh() does not attempt to deliver stale results") {
        // Create version 1
        r->begin_transaction();
        table->add_empty_row();
        r->commit_transaction();

        r->begin_transaction();
        // Run async query for version 1
        coordinator->on_change();
        // Create version 2 without ever letting 1 be delivered
        table->add_empty_row();
        r->commit_transaction();

        // Give it a chance to deliver the async query results (and fail, becuse
        // they're for version 1 and the realm is at 2)
        r->refresh();
    }
}

TEST_CASE("results: error messages") {
    InMemoryTestFile config;
    config.schema = Schema{
        {"object", {
            {"value", PropertyType::String},
        }},
    };

    auto r = Realm::get_shared_realm(config);
    auto table = r->read_group().get_table("class_object");
    Results results(r, *table);

    r->begin_transaction();
    table->add_empty_row();
    r->commit_transaction();

    SECTION("out of bounds access") {
        REQUIRE_THROWS_WITH(results.get(5), "Requested index 5 greater than max 1");
    }

    SECTION("unsupported aggregate operation") {
        REQUIRE_THROWS_WITH(results.sum(0), "Cannot sum property 'value': operation not supported for 'string' properties");
    }
}

TEST_CASE("results: snapshots") {
    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;
    config.schema = Schema{
        {"object", {
            {"value", PropertyType::Int},
            {"array", PropertyType::Array, "linked to object"}
        }},
        {"linked to object", {
            {"value", PropertyType::Int}
        }}
    };

    auto r = Realm::get_shared_realm(config);

    auto write = [&](auto&& f) {
        r->begin_transaction();
        f();
        r->commit_transaction();
        advance_and_notify(*r);
    };

    SECTION("snapshot of empty Results") {
        Results results;
        auto snapshot = results.snapshot();
        REQUIRE(snapshot.size() == 0);
    }

    SECTION("snapshot of Results based on Table") {
        auto table = r->read_group().get_table("class_object");
        Results results(r, *table);

        {
            // A newly-added row should not appear in the snapshot.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 0);
            write([=]{
                table->add_empty_row();
            });
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 0);
        }

        {
            // Removing a row present in the snapshot should not affect the size of the snapshot,
            // but will result in the snapshot returning a detached row accessor.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 1);
            write([=]{
                table->move_last_over(0);
            });
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());

            // Adding a row at the same index that was formerly present in the snapshot shouldn't
            // affect the state of the snapshot.
            write([=]{
                table->add_empty_row();
            });
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());
        }
    }

    SECTION("snapshot of Results based on LinkView") {
        auto object = r->read_group().get_table("class_object");
        auto linked_to = r->read_group().get_table("class_linked to object");

        write([=]{
            object->add_empty_row();
        });

        LinkViewRef lv = object->get_linklist(1, 0);
        Results results(r, lv);

        {
            // A newly-added row should not appear in the snapshot.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 0);
            write([=]{
                lv->add(linked_to->add_empty_row());
            });
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 0);
        }

        {
            // Removing a row from the link list should not affect the snapshot.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 1);
            write([=]{
                lv->remove(0);
            });
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 1);
            REQUIRE(snapshot.get(0).is_attached());

            // Removing a row present in the snapshot from its table should result in the snapshot
            // returning a detached row accessor.
            write([=]{
                linked_to->remove(0);
            });
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());

            // Adding a new row to the link list shouldn't affect the state of the snapshot.
            write([=]{
                lv->add(linked_to->add_empty_row());
            });
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());
        }
    }

    SECTION("snapshot of Results based on Query") {
        auto table = r->read_group().get_table("class_object");
        Query q = table->column<Int>(0) > 0;
        Results results(r, std::move(q));

        {
            // A newly-added row should not appear in the snapshot.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 0);
            write([=]{
                table->set_int(0, table->add_empty_row(), 1);
            });
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 0);
        }

        {
            // Updating a row to no longer match the query criteria should not affect the snapshot.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 1);
            write([=]{
                table->set_int(0, 0, 0);
            });
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 1);
            REQUIRE(snapshot.get(0).is_attached());

            // Removing a row present in the snapshot from its table should result in the snapshot
            // returning a detached row accessor.
            write([=]{
                table->remove(0);
            });
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());

            // Adding a new row that matches the query criteria shouldn't affect the state of the snapshot.
            write([=]{
                table->set_int(0, table->add_empty_row(), 1);
            });
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());
        }
    }

    SECTION("snapshot of Results based on TableView from query") {
        auto table = r->read_group().get_table("class_object");
        Query q = table->column<Int>(0) > 0;
        Results results(r, q.find_all());

        {
            // A newly-added row should not appear in the snapshot.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 0);
            write([=]{
                table->set_int(0, table->add_empty_row(), 1);
            });
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 0);
        }

        {
            // Updating a row to no longer match the query criteria should not affect the snapshot.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 1);
            write([=]{
                table->set_int(0, 0, 0);
            });
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 1);
            REQUIRE(snapshot.get(0).is_attached());

            // Removing a row present in the snapshot from its table should result in the snapshot
            // returning a detached row accessor.
            write([=]{
                table->remove(0);
            });
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());

            // Adding a new row that matches the query criteria shouldn't affect the state of the snapshot.
            write([=]{
                table->set_int(0, table->add_empty_row(), 1);
            });
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());
        }
    }

    SECTION("snapshot of Results based on TableView from backlinks") {
        auto object = r->read_group().get_table("class_object");
        auto linked_to = r->read_group().get_table("class_linked to object");

        write([=]{
            linked_to->add_empty_row();
        });

        TableView backlinks = linked_to->get_backlink_view(0, object.get(), 1);
        Results results(r, std::move(backlinks));

        auto lv = object->get_linklist(1, object->add_empty_row());

        {
            // A newly-added row should not appear in the snapshot.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 0);
            write([=]{
                lv->add(0);
            });
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 0);
        }

        {
            // Removing the link should not affect the snapshot.
            auto snapshot = results.snapshot();
            REQUIRE(results.size() == 1);
            REQUIRE(snapshot.size() == 1);
            write([=]{
                lv->remove(0);
            });
            REQUIRE(results.size() == 0);
            REQUIRE(snapshot.size() == 1);
            REQUIRE(snapshot.get(0).is_attached());

            // Removing a row present in the snapshot from its table should result in the snapshot
            // returning a detached row accessor.
            write([=]{
                object->remove(0);
            });
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());

            // Adding a new link shouldn't affect the state of the snapshot.
            write([=]{
                object->add_empty_row();
                auto lv = object->get_linklist(1, object->add_empty_row());
                lv->add(0);
            });
            REQUIRE(snapshot.size() == 1);
            REQUIRE(!snapshot.get(0).is_attached());
        }
    }

    SECTION("snapshot of Results with notification callback registered") {
        auto table = r->read_group().get_table("class_object");
        Query q = table->column<Int>(0) > 0;
        Results results(r, q.find_all());

        auto token = results.add_notification_callback([&](CollectionChangeSet, std::exception_ptr err) {
            REQUIRE_FALSE(err);
        });
        advance_and_notify(*r);

        SECTION("snapshot of lvalue") {
            auto snapshot = results.snapshot();
            write([=] {
                table->set_int(0, table->add_empty_row(), 1);
            });
            REQUIRE(snapshot.size() == 0);
        }

        SECTION("snapshot of rvalue") {
            auto snapshot = std::move(results).snapshot();
            write([=] {
                table->set_int(0, table->add_empty_row(), 1);
            });
            REQUIRE(snapshot.size() == 0);
        }
    }

    SECTION("adding notification callback to snapshot throws") {
        auto table = r->read_group().get_table("class_object");
        Query q = table->column<Int>(0) > 0;
        Results results(r, q.find_all());
        auto snapshot = results.snapshot();
        CHECK_THROWS(snapshot.add_notification_callback([](CollectionChangeSet, std::exception_ptr) {}));
    }

    SECTION("accessors should return none for detached row") {
        auto table = r->read_group().get_table("class_object");
        write([=] {
            table->add_empty_row();
        });
        Results results(r, *table);
        auto snapshot = results.snapshot();
        write([=] {;
            table->clear();
        });

        REQUIRE_FALSE(snapshot.get(0).is_attached());
        REQUIRE_FALSE(snapshot.first()->is_attached());
        REQUIRE_FALSE(snapshot.last()->is_attached());
    }
}

TEST_CASE("distinct") {
    const int N = 10;
    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;

    auto r = Realm::get_shared_realm(config);
    r->update_schema({
        {"object", {
            {"num1", PropertyType::Int},
            {"string", PropertyType::String},
            {"num2", PropertyType::Int}
        }},
    });

    auto table = r->read_group().get_table("class_object");

    r->begin_transaction();
    table->add_empty_row(N);
    for (int i = 0; i < N; ++i) {
        table->set_int(0, i, i % 3);
        table->set_string(1, i, util::format("Foo_%1", i % 3).c_str());
        table->set_int(2, i, N - i);
    }
    // table:
    //   0, Foo_0, 10
    //   1, Foo_1,  9
    //   2, Foo_2,  8
    //   0, Foo_0,  7
    //   1, Foo_1,  6
    //   2, Foo_2,  5
    //   0, Foo_0,  4
    //   1, Foo_1,  3
    //   2, Foo_2,  2
    //   0, Foo_0,  1

    r->commit_transaction();
    Results results(r, table->where());

    SECTION("Single integer property") {
        Results unique = results.distinct(SortDescriptor(results.get_tableview().get_parent(), {{0}}));
        // unique:
        //  0, Foo_0, 10
        //  1, Foo_1,  9
        //  2, Foo_2,  8
        REQUIRE(unique.size() == 3);
        REQUIRE(unique.get(0).get_int(2) == 10);
        REQUIRE(unique.get(1).get_int(2) == 9);
        REQUIRE(unique.get(2).get_int(2) == 8);
    }

    SECTION("Single string property") {
        Results unique = results.distinct(SortDescriptor(results.get_tableview().get_parent(), {{1}}));
        // unique:
        //  0, Foo_0, 10
        //  1, Foo_1,  9
        //  2, Foo_2,  8
        REQUIRE(unique.size() == 3);
        REQUIRE(unique.get(0).get_int(2) == 10);
        REQUIRE(unique.get(1).get_int(2) == 9);
        REQUIRE(unique.get(2).get_int(2) == 8);
    }

    SECTION("Two integer properties combined") {
        Results unique = results.distinct(SortDescriptor(results.get_tableview().get_parent(), {{0}, {2}}));
        // unique is the same as the table
        REQUIRE(unique.size() == N);
        for (int i = 0; i < N; ++i) {
            REQUIRE(unique.get(i).get_string(1) == StringData(util::format("Foo_%1", i % 3).c_str()));
        }
    }

    SECTION("String and integer combined") {
        Results unique = results.distinct(SortDescriptor(results.get_tableview().get_parent(), {{2}, {1}}));
        // unique is the same as the table
        REQUIRE(unique.size() == N);
        for (int i = 0; i < N; ++i) {
            REQUIRE(unique.get(i).get_string(1) == StringData(util::format("Foo_%1", i % 3).c_str()));
        }
    }

    // This section and next section demonstrate that sort().distinct() == distinct().sort()
    SECTION("Order after sort and distinct") {
        Results reverse = results.sort(SortDescriptor(results.get_tableview().get_parent(), {{2}}, {true}));
        // reverse:
        //   0, Foo_0,  1
        //  ...
        //   0, Foo_0, 10
        REQUIRE(reverse.first()->get_int(2) == 1);
        REQUIRE(reverse.last()->get_int(2) == 10);

        // distinct() will first be applied to the table, and then sorting is reapplied
        Results unique = reverse.distinct(SortDescriptor(reverse.get_tableview().get_parent(), {{0}}));
        // unique:
        //  2, Foo_2,  8
        //  1, Foo_1,  9
        //  0, Foo_0, 10
        REQUIRE(unique.size() == 3);
        REQUIRE(unique.get(0).get_int(2) == 8);
        REQUIRE(unique.get(1).get_int(2) == 9);
        REQUIRE(unique.get(2).get_int(2) == 10);
    }

    SECTION("Order after distinct and sort") {
        Results unique = results.distinct(SortDescriptor(results.get_tableview().get_parent(), {{0}}));
        // unique:
        //  0, Foo_0, 10
        //  1, Foo_1,  9
        //  2, Foo_2,  8
        REQUIRE(unique.size() == 3);
        REQUIRE(unique.first()->get_int(2) == 10);
        REQUIRE(unique.last()->get_int(2) == 8);

        // sort() is only applied to unique
        Results reverse = unique.sort(SortDescriptor(unique.get_tableview().get_parent(), {{2}}, {true}));
        // reversed:
        //  2, Foo_2,  8
        //  1, Foo_1,  9
        //  0, Foo_0, 10
        REQUIRE(reverse.size() == 3);
        REQUIRE(reverse.get(0).get_int(2) == 8);
        REQUIRE(reverse.get(1).get_int(2) == 9);
        REQUIRE(reverse.get(2).get_int(2) == 10);
    }

    SECTION("Chaining distinct") {
        Results first = results.distinct(SortDescriptor(results.get_tableview().get_parent(), {{0}}));
        REQUIRE(first.size() == 3);

        // distinct() will discard the previous applied distinct() calls
        Results second = first.distinct(SortDescriptor(first.get_tableview().get_parent(), {{2}}));
        REQUIRE(second.size() == N);
    }

    SECTION("Distinct is carried over to new queries") {
        Results unique = results.distinct(SortDescriptor(results.get_tableview().get_parent(), {{0}}));
        // unique:
        //  0, Foo_0, 10
        //  1, Foo_1,  9
        //  2, Foo_2,  8
        REQUIRE(unique.size() == 3);

        Results filtered = unique.filter(Query(table->where().less(0, 2)));
        // filtered:
        //  0, Foo_0, 10
        //  1, Foo_1,  9
        REQUIRE(filtered.size() == 2);
        REQUIRE(filtered.get(0).get_int(2) == 10);
        REQUIRE(filtered.get(1).get_int(2) == 9);
    }

    SECTION("Distinct will not forget previous query") {
        Results filtered = results.filter(Query(table->where().greater(2, 5)));
        // filtered:
        //   0, Foo_0, 10
        //   1, Foo_1,  9
        //   2, Foo_2,  8
        //   0, Foo_0,  7
        //   1, Foo_1,  6
        REQUIRE(filtered.size() == 5);

        Results unique = filtered.distinct(SortDescriptor(filtered.get_tableview().get_parent(), {{0}}));
        // unique:
        //   0, Foo_0, 10
        //   1, Foo_1,  9
        //   2, Foo_2,  8
        REQUIRE(unique.size() == 3);
        REQUIRE(unique.get(0).get_int(2) == 10);
        REQUIRE(unique.get(1).get_int(2) == 9);
        REQUIRE(unique.get(2).get_int(2) == 8);

        Results further_filtered = unique.filter(Query(table->where().equal(2, 9)));
        // further_filtered:
        //   1, Foo_1,  9
        REQUIRE(further_filtered.size() == 1);
        REQUIRE(further_filtered.get(0).get_int(2) == 9);
    }
}


TEST_CASE("aggregate") {
#define SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW() \
    SECTION("results built from table") { \
        results = Results(r, *table); \
    } \
    SECTION("results built from query") { \
        results = Results(r, table->where()); \
    } \
    SECTION("results built from tableview") { \
        results = Results(r, table->where().find_all()); \
    } \
    SECTION("results built from linkview") { \
        r->begin_transaction(); \
        auto link_table = r->read_group().get_table("class_linking_object"); \
        link_table->add_empty_row(1); \
        auto link_view = link_table->get_linklist(0, 0); \
        auto table_view = table->where().find_all(); \
        for (size_t i = 0; i< table_view.size(); ++i) { \
            link_view->add(table_view.get_source_ndx(i)); \
        } \
        r->commit_transaction(); \
        results = Results(r, link_view); \
    }

    const int column_count = 4;
    InMemoryTestFile config;
    config.cache = false;
    config.automatic_change_notifications = false;


    auto r = Realm::get_shared_realm(config);
    r->update_schema({
        {"object", {
            {"int", PropertyType::Int, "", "", false, false, true},
            {"float", PropertyType::Float,  "", "", false, false, true},
            {"double", PropertyType::Double, "", "", false, false, true},
            {"date", PropertyType::Date, "", "", false, false, true},
        }},
        {"linking_object", {
            {"link", PropertyType::Array, "object", "", false, false, false}
        }},
    });

    auto table = r->read_group().get_table("class_object");

    SECTION("one row with null values") {
        r->begin_transaction();
        table->add_empty_row(3);
        for (int i = 0; i < column_count; ++i) {
            table->set_null(i, 0);
        }

        table->set_int(0, 1, 0);
        table->set_float(1, 1, 0.f);
        table->set_double(2, 1, 0.0);
        table->set_timestamp(3, 1, Timestamp(0, 0));

        table->set_int(0, 2, 2);
        table->set_float(1, 2, 2.f);
        table->set_double(2, 2, 2.0);
        table->set_timestamp(3, 2, Timestamp(2, 0));
        // table:
        //  null, null, null,  null,
        //  0,    0,    0,    (0, 0)
        //  2,    2,    2,    (2, 0)
        r->commit_transaction();

        SECTION("max") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(results.max(0)->get_int() == 2);
            REQUIRE(results.max(1)->get_float() == 2.f);
            REQUIRE(results.max(2)->get_double() == 2.0);
            REQUIRE(results.max(3)->get_timestamp() == Timestamp(2, 0));
        }

        SECTION("min") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(results.min(0)->get_int() == 0);
            REQUIRE(results.min(1)->get_float() == 0.f);
            REQUIRE(results.min(2)->get_double() == 0.0);
            REQUIRE(results.min(3)->get_timestamp() == Timestamp(0, 0));
        }

        SECTION("average") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(results.average(0)->get_double() == 1.0);
            REQUIRE(results.average(1)->get_double() == 1.0);
            REQUIRE(results.average(2)->get_double() == 1.0);
            REQUIRE_THROWS_AS(results.average(3), Results::UnsupportedColumnTypeException);
        }

        SECTION("sum") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(results.sum(0)->get_int() == 2);
            REQUIRE(results.sum(1)->get_double() == 2.0);
            REQUIRE(results.sum(2)->get_double() == 2.0);
            REQUIRE_THROWS_AS(results.sum(3), Results::UnsupportedColumnTypeException);
        }
    }

    SECTION("rows with all null values") {
        const int row_count = 3;
        r->begin_transaction();
        table->add_empty_row(row_count);
        for (int i = 0; i < column_count; ++i) {
            for (int j = 0; j < row_count; ++j) {
                table->set_null(i, j);
            }
        }
        // table:
        //  null, null, null,  null,  null
        //  null, null, null,  null,  null
        //  null, null, null,  null,  null
        r->commit_transaction();

        SECTION("max") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(!results.max(0));
            REQUIRE(!results.max(1));
            REQUIRE(!results.max(2));
            REQUIRE(!results.max(3));
        }

        SECTION("min") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(!results.min(0));
            REQUIRE(!results.min(1));
            REQUIRE(!results.min(2));
            REQUIRE(!results.min(3));
        }

        SECTION("average") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(!results.average(0));
            REQUIRE(!results.average(1));
            REQUIRE(!results.average(2));
            REQUIRE_THROWS_AS(results.average(3), Results::UnsupportedColumnTypeException);
        }

        SECTION("sum") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(results.sum(0)->get_int() == 0);
            REQUIRE(results.sum(1)->get_double() == 0.0);
            REQUIRE(results.sum(2)->get_double() == 0.0);
            REQUIRE_THROWS_AS(results.sum(3), Results::UnsupportedColumnTypeException);
        }
    }

    SECTION("empty") {
        SECTION("max") {
            Results results;

            SECTION("empty results") {
                results = Results();
            }

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(!results.max(0));
            REQUIRE(!results.max(1));
            REQUIRE(!results.max(2));
            REQUIRE(!results.max(3));
        }

        SECTION("min") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(!results.min(0));
            REQUIRE(!results.min(1));
            REQUIRE(!results.min(2));
            REQUIRE(!results.min(3));
        }

        SECTION("average") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(!results.average(0));
            REQUIRE(!results.average(1));
            REQUIRE(!results.average(2));
            REQUIRE_THROWS_AS(results.average(3), Results::UnsupportedColumnTypeException);
        }

        SECTION("sum") {
            Results results;

            SECTIONS_RESULT_BUILT_FROM_TABLE_QUERY_TABLE_VIEW()

            REQUIRE(results.sum(0)->get_int() == 0);
            REQUIRE(results.sum(1)->get_double() == 0.0);
            REQUIRE(results.sum(2)->get_double() == 0.0);
            REQUIRE_THROWS_AS(results.sum(3), Results::UnsupportedColumnTypeException);
        }
    }
}
