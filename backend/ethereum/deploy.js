const fs = require('fs');
const HDWalletProvider = require('truffle-hdwallet-provider');//bản 0.0.5 bị lỗi => 0.0.3
const Web3 = require('web3');
const compiledFactory = require('../public/json/BallotFactory.json');

// const provider = new HDWalletProvider(
//     'climb buyer trash also pull rule pull rapid apart ensure coin spend',
//     'https://ropsten.infura.io/v3/2ee8969fa00742efb10051fc923552e1'
// );

// const web3 = new Web3(provider);

const web3 = new Web3('https://node.credential.asia');

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    // const account_ = {
    //     address: '0x29a2886aA7fF449fe1C7b23086Ed63844C0E6985',
    //     privateKey: '0x7cfb5f2ceccd2aee144b676384689f0bce5812e32ba2d7126ea49ba38199a187'
    // }

    console.log('Attempting to deploy contract from account ', accounts[0]);
    let result = {};
    try {
        result = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
            .deploy({ data: compiledFactory.bytecode, arguments: [ 2 ] })
            .send({ from: accounts[0], gas: '3000000' });

        console.log('Contract deploy to address ', result.options.address);
        fs.writeFile('./Factory.address.js', result.options.address, function (err) {
            if (err) throw err;
            console.log('Saved address!');
        });
    } catch(err) {
        console.log(err.message);
    }
}

deploy();