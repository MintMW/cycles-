import Time "mo:base/Time";
import Result "mo:base/Result";

module {
    public type AccountId = Blob;
    public type Address = Text;
    public type Txid = Blob;
    public type Amount = Nat;
    public type Nonce = Nat;
    public type Data = Blob;
    public type Timestamp = Nat;
    public type IcpE8s = Nat;

    public type PriceResponse = { quantity: Nat; price: Nat; };
    public type OrderPrice = { quantity: {#Buy: (quantity: Nat, amount: Nat); #Sell: Nat; }; price: Nat; };
    
    public type TradingOrder = {
        account: AccountId;
        txid: Txid;
        orderPrice: OrderPrice;
        time: Time.Time;
        remaining: OrderPrice;
        nonce: Nat;
        index:Nat;
    };
    
   
    public type Vol = { value0: Amount; value1: Amount; };
   
    public type TradingResult = Result.Result<{   //<#ok, #err> 
        txid: Txid;
    }, {
        code: {
            #NonceError;
            #InvalidAmount;
            #InsufficientBalance;
            #TransferException;
            #UnacceptableVolatility;
            #TransactionBlocking;
            #UndefinedError;
        };
        message: Text;
    }>;
    public type KBar = {kid: Nat; open: Nat; high: Nat; low: Nat; close: Nat; vol: Nat; updatedTs: Timestamp};
    public type TrieList<K, V> = {data: [(K, V)]; total: Nat; totalPage: Nat; };
    
 };