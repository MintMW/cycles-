import Blob "mo:base/Blob";
import Trie "mo:base/Trie";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Cycles "mo:base/ExperimentalCycles";
import Types "./lib/OrderTypes";
import Hex "./lib/Hex";
import Binary "./lib/Binary";
import SHA224 "./lib/SHA224";
import CyclesWallet "./lib/CyclesWallet";

shared actor class Order() = this {

    type AccountId = Types.AccountId;
    type Address = Types.Address;
    type Txid = Types.Txid;
    type TradingOrder = Types.TradingOrder;
    type TradingResult = Types.TradingResult;
    type TxAccount = Text;
    type Nonce = Types.Nonce;
    type OrderPrice = Types.OrderPrice;
    type PriceResponse = Types.PriceResponse;
    
    private stable var nonces: Trie.Trie<AccountId, Nonce> = Trie.empty(); 
    private stable var orders : Trie.Trie<Txid, TradingOrder> = Trie.empty();
    private stable var index: Nat = 0;
    private stable var txids:[Txid] = [];
    private func keyb(t: Blob) : Trie.Key<Blob> { return { key = t; hash = Blob.hash(t) }; };

    private func arrayAppend<T>(a: [T], b: [T]) : [T]{
        let buffer = Buffer.Buffer<T>(1);
        for (t in a.vals()){
            buffer.add(t);
        };
        for (t in b.vals()){
            buffer.add(t);
        };
        return buffer.toArray();
    };

    private func _getNonce(_a: AccountId): Nat{
        switch(Trie.get(nonces, keyb(_a), Blob.equal)){
            case(?(v)){ return v; };
            case(_){ return 0; };
        };
    };

    private func _addNonce(_a: AccountId): (){
        var n = _getNonce(_a);
        nonces := Trie.put(nonces, keyb(_a), Blob.equal, n+1).0;
        index += 1;
    };

    private func _quantity(_orderPrice: OrderPrice) : Nat{
        switch(_orderPrice.quantity){
            case(#Buy(value)){ return value.0; };
            case(#Sell(value)){ return value; };
        };
    };

    private func _generateTxid( _caller: Principal, _nonce: Nat): Txid{
        let appType: [Nat8] = [83:Nat8, 87, 65, 80]; //SWAP
        let caller: [Nat8] = Blob.toArray(Principal.toBlob(_caller));
        let nonce: [Nat8] = Binary.BigEndian.fromNat32(Nat32.fromNat(_nonce));
        let txInfo = arrayAppend(caller, nonce);
        let h224: [Nat8] = SHA224.sha224(txInfo);
        return Blob.fromArray(arrayAppend(nonce, h224));
    };

    private func _sendCycles(to:Principal,cycles:Nat):async (){
        let wallet: CyclesWallet.Self = actor(Principal.toText(to));
        Cycles.add(cycles);
        await wallet.wallet_receive();
    };

    // just example
    public shared(msg) func trade(_orderPrice: OrderPrice):async TradingResult{
        if (_orderPrice.price > 0){
            assert(_quantity(_orderPrice) > 0);
        };
        let user = msg.caller;
        let nonce = _getNonce(Principal.toBlob(user));
        let txid = _generateTxid(user,_getNonce(Principal.toBlob(user)));   
        switch(_orderPrice.quantity){
            case(#Sell(value)){
                // todo
            };
            case(#Buy(value)){
                // todo
            };
        };
        return #ok({ txid = txid});
    };

    public shared(msg) func cancel(){
        // return cycles to buyer

    };

    public query func getOrders() : async [TradingOrder]{
        var result : [TradingOrder]= [];
        for(txid in txids.vals()){
            var tradingOrder = Trie.get(orders, keyb(txid), Blob.equal);
            switch(tradingOrder){
                case(?order){
                    result := Array.append(result,[order]);
                };
                case(_){}
            }
        };
        return result;
    };

    public shared func wallet_receive(){
        let amount:Nat = Cycles.available();
        let accepted = Cycles.accept(amount);
    };
}