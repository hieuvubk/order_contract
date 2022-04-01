import { BigNumber, constants, ethers, utils } from 'ethers';
import { task } from 'hardhat/config';
import { TLSSocketOptions } from 'tls';
import sha256 from 'crypto-js/sha256';

task('contract:verify', 'verify contract')
  .addOptionalParam('address', 'address')
  .addOptionalParam('symbol', 'symbol')
  .setAction(async (taskArgs, hre) => {
    const address = taskArgs.address || '0x7b2f2D90Fc30b5358c368Ce3d65a0c1BEb9ecBF4';
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
      id: "DL1648827286185",
      name: "afsdfasdbc",
  }
  const hash = sha256(data.name);
  console.log(hash.toString());

  const tx = await instance.methods.issue(data.id, `0x${hash.toString()}`).send({ from: deployer});

  console.log(`tx hash: ${tx.transactionHash}`);
  });