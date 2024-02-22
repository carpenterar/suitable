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
        locked_obj: T,
        unlock_timestamp: u64,
    }

    struct TimeEvent has copy, drop, store {
        timestamp_ms: u64
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
    locked_obj: T,
    unlock_timestamp: u64,
    ctx: &mut TxContext,
    ) {
    let locker = Safe {
        id: object::new(ctx),
        locked_obj,
        unlock_timestamp,
    };

    transfer::transfer(locker, tx_context::sender(ctx))
    }

    /// Unlock the object in `locked`, consuming the `key`.  Fails if the wrong
    /// `key` is passed in for the locked object.
    public fun unlock<T: store>(
        locked: Safe<T>,
        clock: &Clock,  // Add Clock as a parameter
        ctx: &mut TxContext
        ): T {
            let current_timestamp = get_current_timestamp(clock);

            assert!(current_timestamp >= locked.unlock_timestamp, EUnlockTimestampNotMet);

            let Safe { id, locked_obj, unlock_timestamp } = locked;
            object::delete(id);
            locked_obj
    }

}