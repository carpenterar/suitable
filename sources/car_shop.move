
module car::car_shop {
    
    use sui::transfer;
    use sui::sui::SUI;
    use sui::url::{Self, Url};
    use std::string;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use 

    const EInsufficientBalance: u64 = 0;
    const BURN_ADDRESS: address = @burn;

    struct Locker has key, store {
        id: UID,
        balance: Balance<SUI>
    }

    



    struct Car has key {
        id: UID,
        name: string::String,
        description: string::String,
        url: Url,
        speed: u8,
        acceleration: u8,
        handling: u8
    }

    struct CarShop has key {
        id: UID,
        price: u64,
        balance: Balance<SUI>
    }

    struct ShopOwnerCap has key { id: UID }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(ShopOwnerCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::share_object(CarShop {
            id: object::new(ctx),
            price: 100,
            balance: balance::zero()
        })
    }

    // New function to create a Locker object and send it to the sender
    //WOOD WOOOD SNED ME WOOD SIR
    public entry fun create_locker(locked_coin: &mut Coin<SUI>, amount: u64, ctx: &mut TxContext) {

        let locker = Locker {
            id: object::new(ctx),
            balance: balance::zero()
        };
        let coin_balance = coin::balance_mut(locked_coin);
        let locked = balance::split(coin_balance, amount);

        balance::join(&mut locker.balance, locked);

        
        transfer::transfer(locker, tx_context::sender(ctx));
    }

    // Function to unlock a Locker and regain the locked SUI
    public entry fun unlock_locker(locker: Locker, ctx: &mut TxContext) {
        let amount = balance::value(&locker.balance);
        let sui = coin::take(&mut locker.balance, amount, ctx);
        transfer::public_transfer(sui, tx_context::sender(ctx));
        // Transfer the Locker to the burn address
        transfer::public_transfer(locker, BURN_ADDRESS);
    }





    public entry fun buy_car(
        shop: &mut CarShop,
        payment: &mut Coin<SUI>,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>, ctx: &mut TxContext) {

        assert!(coin::value(payment) >= shop.price, EInsufficientBalance);
        let coin_balance = coin::balance_mut(payment);
        let paid = balance::split(coin_balance, shop.price);

        balance::join(&mut shop.balance, paid);

        transfer::transfer(Car {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            speed: 50,
            acceleration: 50,
            handling: 50
        }, tx_context::sender(ctx))
    }

    public entry fun collect_profits(_: &ShopOwnerCap, shop: &mut CarShop, ctx: &mut TxContext) {
        let amount = balance::value(&shop.balance);
        let profits = coin::take(&mut shop.balance, amount, ctx);

        transfer::public_transfer(profits, tx_context::sender(ctx))
    }

}