module suitable::suitable {
    use std::option;
    use sui::coin;
    use std::ascii;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self as UrlModule, Url};

    // Name matches the module name, but in UPPERCASE
    struct SUITABLE has drop {}

    // Module initializer is called once on module publish.
    // A treasury cap is sent to the publisher, who then controls minting and burning.
    fun init(witness: SUITABLE, ctx: &mut TxContext) {
        let icon_url_str = b"https://s9.gifyu.com/images/SFnHN.png";
        let icon_url = UrlModule::new_unsafe(ascii::string(icon_url_str));
        let (treasury, metadata) = coin::create_currency(witness, 9, b"Suitable", b"TABLE", b"Pristine TABLEs", option::some(icon_url), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    // Manager can mint new TABLE tokens
    public entry fun mint(
        treasury: &mut coin::TreasuryCap<SUITABLE>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury, amount, recipient, ctx)
    }

    // Manager can burn TABLE tokens
    public entry fun burn(treasury: &mut coin::TreasuryCap<SUITABLE>, coin: coin::Coin<SUITABLE>) {
        coin::burn(treasury, coin);
    }
}
