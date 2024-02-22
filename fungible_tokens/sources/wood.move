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


0x1354b8e33eaef238fd795640f9881f5b19db5c253019787f84bd92ad099dafd7

sui client call --package 0xa3154bd7e8f1aaa1356e2926853a4064c543d90088a99780d02121fac8fb7610 --module wood --function mint --args 0x834aa3e6f544aad256b694e5cf71bac3c7c054f1970c009658d1649901d7eb5a 6942000000000 0xbf963163b163610bd9b73ad6af33ffc3ae42dd38d63fa4ec1f60417059e3d0a7 --gas-budget 50000000