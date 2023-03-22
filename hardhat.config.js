require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {

  defaultNetwork: "hardhat",
  solidity: {
      compilers: [
          {
              version: '0.8.17',
              settings: {
                  optimizer: {
                      enabled: true,
                      runs: 50,
                  },
              },
          },
      ],
  },
  networks: {
    hardhat: {
      initialDate:'01 Jan 1970 00:00:00 GMT',
    },
    local: {
        url: 'http://127.0.0.1:8545',
        chainId: 111,
        accounts: [
        ]
    },
    polygontest: {
      url: 'https://rpc-mumbai.maticvigil.com/',
      chainId: 80001,
      accounts: [
      ]
    },
  },
};
