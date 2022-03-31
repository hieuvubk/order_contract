import { BigNumber, constants, ethers, utils } from 'ethers';
import { task } from 'hardhat/config';
import { TLSSocketOptions } from 'tls';
import sha256 from 'crypto-js/sha256';

task('contract:verify', 'verify contract')
  .addOptionalParam('address', 'address')
  .addOptionalParam('symbol', 'symbol')
  .setAction(async (taskArgs, hre) => {
    const address = taskArgs.address || '0x53850231024722511f845295e7909b6860539160';
    await hre.run('verify:verify', {
      address,
      constructorArguments: [],
    });
  });

task('contract:createOrder', 'verify contract')
  .addOptionalParam('address', 'address')
  .addOptionalParam('symbol', 'symbol')
  .setAction(async (taskArgs, hre) => {
    const { deployments, getNamedAccounts, web3 } = hre;
  const { deployer } = await getNamedAccounts();

  const Contract = await deployments.get('OrderStore');
  const instance = new web3.eth.Contract(Contract.abi, Contract.address);

  const data = {
      id: "1234",
      name: "abc",
  }
  const hash = sha256(data.name);
  console.log(hash.toString());

  const tx = await instance.methods.issue(data.id, '0xba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad').send({ from: deployer});

  console.log(`tx hash: ${tx.transactionHash}`);
  });