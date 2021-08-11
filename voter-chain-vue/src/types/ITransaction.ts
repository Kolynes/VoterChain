interface ITransaction {
    nonce?: string;
    gasPrice?: string;
    gas?: string;
    to: string;
    from?: string;
    value?: string;
    chainId?: string;
    outputs?: {type: string, name: string}[];
    name?: string;
    inputs?: {type: string, name: string, value: any}[];
}