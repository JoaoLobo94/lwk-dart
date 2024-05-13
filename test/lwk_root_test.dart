// ignore_for_file: avoid_print

import 'package:lwk_dart/lwk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Wallet', () {
    test('Wallet Flow', () async {
      await LibLwk.init();
      const mnemonic =
          "bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon bacon";
      const network = Network.testnet;
      const electrumUrl = 'blockstream.info:465';
      const dbPath = '/tmp/lwk-darti';
      const outAmount = 10000;
      const outAddress =
          "tlq1qqt4hjkl6sug5ld89sdaekt7ew04va8w7c63adw07l33vcx86vpj5th3w7rkdnckmfpraufnnrfcep4thqt6024phuav99djeu";
      const feeRate = 1000.0;
      final descriptor = await Descriptor.newConfidential(
        network: network,
        mnemonic: mnemonic,
      );
      final wallet = await Wallet.init(
        network: network,
        dbpath: dbPath,
        descriptor: descriptor,
      );
      await wallet.sync(electrumUrl: electrumUrl);
      final address = await wallet.addressLastUnused();
      print(address);
      // print(wallet.descriptor());
      final balance = await wallet.balances();
      print('Pre Balance: $balance');
      final txs = await wallet.txs();
      for (final tx in txs) {
        print('${tx.txid}:${tx.balances} ${tx.timestamp}');
      }
      final pset = await wallet.buildLbtcTx(
          sats: outAmount, outAddress: outAddress, feeRate: feeRate);
      final decodedPset = await wallet.decodeTx(pset: pset);
      print("Amount: ${decodedPset.balances} , Fee: ${decodedPset.fee}");
      final signedTxBytes =
          await wallet.signTx(network: network, pset: pset, mnemonic: mnemonic);
      final tx = await Wallet.broadcastTx(
          electrumUrl: electrumUrl, txBytes: signedTxBytes);
      print(tx);
      await wallet.sync(electrumUrl: electrumUrl);
      final postBalance = await wallet.balances();
      print('Post Balance: ${postBalance}');
      final getUnspendUtxos = await wallet.utxos();
      print('Unspent Utxos: $getUnspendUtxos');
      final sign_pset_string = await wallet.signedPsetWithExtraDetails(
          network: network, pset: pset, mnemonic: mnemonic);
      print('Signed Tx String: $sign_pset_string');
    });
  });
}
