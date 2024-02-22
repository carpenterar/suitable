module wood::wood {
    use std::option;
    use sui::coin;
    use std::ascii;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self as UrlModule, Url};

    // Name matches the module name, but in UPPERCASE
    struct WOOD has drop {}

    // Module initializer is called once on module publish.
    // A treasury cap is sent to the publisher, who then controls minting and burning.
    fun init(witness: WOOD, ctx: &mut TxContext) {
        let icon_url_str = b"https://s9.gifyu.com/images/SF73b.png";
        let icon_url = UrlModule::new_unsafe(ascii::string(icon_url_str));
        let (treasury, metadata) = coin::create_currency(witness, 9, b"WOOD", b"WOOD", b"Basic but juicy WOOD", option::some(icon_url), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    // Manager can mint new TABLE tokens
    public entry fun mint(
        treasury: &mut coin::TreasuryCap<WOOD>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury, amount, recipient, ctx)
    }

    // Manager can burn TABLE tokens
    public entry fun burn(treasury: &mut coin::TreasuryCap<WOOD>, coin: coin::Coin<WOOD>) {
        coin::burn(treasury, coin);
    }
}


