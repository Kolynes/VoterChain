import detectEthereumProvider from '@metamask/detect-provider';

import Web3 from "web3";

const web3 = new Web3();

export default abstract class Provider {
  static provider: any;

  static async sendTransaction<R>(transaction: ITransaction): Promise<R> {
    return web3.eth.abi.decodeParameters(
      transaction.outputs || [],
      await this.provider.request({
        method: "eth_sendTransaction",
        params: [{
          nonce: transaction.nonce,
          gasPrice: transaction.gasPrice,
          gas: transaction.gas,
          value: transaction.value,
          chainId: transaction.chainId,
          to: transaction.to,
          from: transaction.from || this.provider.selectedAddress,
          data: web3.eth.abi.encodeFunctionCall({
            name: transaction.name,
            type: "function",
            inputs: (transaction.inputs || []).map(input => ({
              type: input.type,
              name: input.name
            })),
          }, (transaction.inputs || []).map(input => input.value) as any[]),
        }],
      })
    ) as R;
  }

  static async call<R>(transaction: ITransaction): Promise<R> {
    return web3.eth.abi.decodeParameters(
      transaction.outputs || [],
      await this.provider.request({
        method: "eth_call",
        params: [{
          nonce: transaction.nonce,
          chainId: transaction.chainId,
          to: transaction.to,
          from: transaction.from || this.provider.selectedAddress,
          data: web3.eth.abi.encodeFunctionCall({
            name: transaction.name,
            type: "function",
            inputs: (transaction.inputs || []).map(input => ({
              type: input.type,
              name: input.name
            })),
          }, (transaction.inputs || []).map(input => input.value) as any[]),
        }]
      })
    ) as R;
  }

  static async getDefaultProvider(callback: Function = new Function()): Promise<any> {
    this.provider = await detectEthereumProvider();
    if (this.provider) {
      this.provider.on('accountsChanged', function (accounts: any[]) {
        window.location.reload();
      });
      this.provider.on('chainChanged', function (accounts: any[]) {
        window.location.reload();
      });
      await this.provider.request({
        method: "eth_requestAccounts"
      });
      this.provider.on("transaction", console.log)
      callback();
    }
    else {
      console.log('Please install MetaMask!');
      alert("Please install MetaMask");
      return null;
    }
  }
}
