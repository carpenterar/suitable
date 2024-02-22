module fungible_tokens::testcoin {
    use std::option;
    use sui::coin;
    use std::ascii;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self as UrlModule, Url};

    // Name matches the module name, but in UPPERCASE
    struct TESTCOIN has drop {}

    // Module initializer is called once on module publish.
    // A treasury cap is sent to the publisher, who then controls minting and burning.
    fun init(witness: TESTCOIN, ctx: &mut TxContext) {
        let icon_url_str = b"https://img.freepik.com/vektoren-premium/larve-im-pixel-art-stil_475147-1547.jpg?w=1380";
        let icon_url = UrlModule::new_unsafe(ascii::string(icon_url_str));
        let (treasury, metadata) = coin::create_currency(witness, 9, b"TABLE", b"TESTCOIN", b"testcoin",  option::some(icon_url), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    // Manager can mint new TABLE tokens
    public entry fun mint(
        treasury: &mut coin::TreasuryCap<TESTCOIN>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        // Get the current total supply
        let current_supply = get_total_supply(treasury);

        // Check if minting would exceed the total supply cap
        if (amount + current_supply > 1000000) {
            // Minting exceeds the limit, handle accordingly (e.g., revert, emit an event)
            // Note: This is a simplified example; you might want to handle it differently in a real scenario.
            assert!(false, 0);
        } else {
            // Mint new tokens
            coin::mint_and_transfer(treasury, amount, recipient, ctx);
        }
    }

    // Manager can burn TABLE tokens
    public entry fun burn(treasury: &mut coin::TreasuryCap<TESTCOIN>, coin: coin::Coin<TESTCOIN>) {
        coin::burn(treasury, coin);
    }

    // Get the current total supply
    public fun get_total_supply(treasury: &coin::TreasuryCap<TESTCOIN>): u64 {
        get_total_supply(treasury)
    }                                                                                                                                                                                                           
}