module token_locker::locker {
    use std::option;
    use sui::coin;
    use std::ascii;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::object::{Self, ID, UID};
    use sui::dynamic_object_field as ofield;
    use sui::clock::{Self, Clock};
    use sui::event;

    struct Safe<T: store> has key {
        id: UID,
        obj: T,
        key: ID,
        unlock_timestamp: u64,
    }
    struct TestObject has key, store {
    id: UID,
    }

    struct Key has key, store { id: UID }

    struct TimeEvent has copy, drop, store {
        timestamp_ms: u64
    }

    public fun new(ctx: &mut TxContext): TestObject {
    TestObject { id: object::new(ctx)}
    }

    public fun get_current_timestamp(clock: &Clock): u64 {
        event::emit(TimeEvent {
            timestamp_ms: clock::timestamp_ms(clock),
        });
        clock::timestamp_ms(clock)
    }

    /// The key does not match this lock.
    const ELockKeyMismatch: u64 = 1;
    /// The timestamp not reached.
    const EUnlockTimestampNotMet: u64 = 2;

    public fun create_Safe<T: store>(
        obj: T,
        unlock_timestamp: u64,
        ctx: &mut TxContext,):
            (Safe<T>, Key) {
        let key = Key { id: object::new(ctx) };
        let token_locker = Safe {
            id: object::new(ctx),
            obj,
            key: object::id(&key),
            unlock_timestamp,
        };
        (token_locker, key)
    }

    /// Unlock the object in `locked`, consuming the `key`.  Fails if the wrong
    /// `key` is passed in for the locked object.
    public fun unlock<T: store>(
        locked: Safe<T>,
        key: Key,
        clock: &Clock,  // Add Clock as a parameter
        ctx: &mut TxContext
        ): T {
            let current_timestamp = get_current_timestamp(clock);

            assert!(current_timestamp >= locked.unlock_timestamp, EUnlockTimestampNotMet);

            assert!(locked.key == object::id(&key), ELockKeyMismatch);

            let Key { id } = key;
            object::delete(id);

            let Safe { id, locked_obj, key: _, unlock_timestamp } = locked;
            object::delete(id);
            locked_obj
    }

}sui client call --package 0x58e9238ea1fbe7a3cace3975648579fec4cfc151c1ca6db9ea20fd3c0c22a596 --module 'lock' --function 'create_Safe' --args '0xc316b10f10cabf75a655dd23d1d44df5fb13d103b31b7ec633023faa141520ad' '1706056543511' --gas-budget 100000000000
sui client call --package 0xed003ae9ebc088edc09a6e03f81ab8b601f04fe16a1d9d8986a17f3f1bb1b5e0  --module 'locker' --function 'new' --gas-budget 100000000000
sui client call --package 0x58e9238ea1fbe7a3cace3975648579fec4cfc151c1ca6db9ea20fd3c0c22a596 --module 'locker' --function 'create_Safe' --args 0x98f5c31592a69b955e9f9fea12284c4b73ad480c0593beffbc743a8dc0de9528 1706056543511 --gas-budget 100000000000
