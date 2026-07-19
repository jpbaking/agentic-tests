# Mocking — C / C++ (GoogleTest / GoogleMock)

## C++ — virtual interface (preferred, when the class takes an interface)

```cpp
class MockGateway : public Gateway {
public:
    MOCK_METHOD(Receipt, charge, (const Cart&), (override));
};

TEST(OrderServiceAgenticTest, ChargesOnce) {
    MockGateway gw;
    EXPECT_CALL(gw, charge(testing::_)).Times(1)
        .WillOnce(testing::Return(Receipt::ok()));
    OrderService svc(gw);
    svc.checkout(makeCart());
}
```

Non-virtual / concrete dependencies with no injection point: do NOT edit main code to add one. Mark the plan entry FAILED with reason "no seam without source change".

## C — link-time substitution with `--wrap` (no source changes)

Wrap a function the code under test calls:

```c
// in the agent-test file:
time_t __wrap_time(time_t *t) { return 1768471200; }  // fixed clock
int __wrap_rand(void) { return 42; }
```

Link the TEST target (only) with `-Wl,--wrap=time -Wl,--wrap=rand` — this is test build config, allowed. In CMake:

```cmake
target_link_options(foo_agentic_test PRIVATE "-Wl,--wrap=time" "-Wl,--wrap=rand")
```

`__wrap_<fn>` replaces `<fn>`; call `__real_<fn>` inside the wrap to reach the original.

## Time / randomness in C++

Same `--wrap` trick works for `time`, `rand`, `clock_gettime`. If the code uses `std::chrono::system_clock::now()` directly and no clock is injectable, test only the time-independent behavior and note the untested branch in the plan.

## Filesystem

Use a per-test temp dir; never touch repo files:

```cpp
auto dir = std::filesystem::temp_directory_path() / ::testing::UnitTest::GetInstance()->current_test_info()->name();
std::filesystem::create_directories(dir);   // remove_all(dir) in TearDown
```

## Network

Only test code paths where the socket/HTTP layer sits behind a function you can `--wrap` or an interface you can mock. Otherwise mark FAILED — never spin up real network connections in agent tests.
