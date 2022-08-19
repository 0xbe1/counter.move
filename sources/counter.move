module counter::counter {
    use std::signer;
    use aptos_std::table::{Self, Table};
    
    struct Counter has key {
        t: Table<u64, u64>
    }

    public fun init(account: &signer) {
        move_to(account, Counter { t: table::new<u64, u64>() });
    }

    public fun get(account_addr: address, key: u64): u64 acquires Counter {
        assert!(exists<Counter>(account_addr), 0);
        let c = borrow_global<Counter>(account_addr);
        *table::borrow(&c.t, key)
    }

    public fun inc(account_addr: address, key: u64) acquires Counter {
        assert!(exists<Counter>(account_addr), 0);
        let mc = borrow_global_mut<Counter>(account_addr); 
        if (table::contains<u64, u64>(&mc.t, key)) {
            let mv = table::borrow_mut(&mut mc.t, key);
            *mv = *mv + 1;
        } else {
            table::add(&mut mc.t, key, 1);
        }
    }

    #[test(account = @0xA)]
    public fun inc_ok(account: &signer) acquires Counter {
        init(account);
        let account_addr = signer::address_of(account);
        inc(account_addr, 100);
        inc(account_addr, 100);
        assert!(get(account_addr, 100) == 2, 0)
    }
}