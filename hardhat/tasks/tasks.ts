import { BigNumber, constants, ethers, utils } from 'ethers';
import { task } from 'hardhat/config';
import { TLSSocketOptions } from 'tls';
import sha256 from 'crypto-js/sha256';

task('contract:verify', 'verify contract')
  .addOptionalParam('address', 'address')
  .addOptionalParam('symbol', 'symbol')
  .setAction(async (taskArgs, hre) => {
    const address = taskArgs.address || '0x428C95C3Eaa171FA966068143DD07140B3d255f8';
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

  const tx = await instance.methods.createOrder(data.id, `0x${hash.toString()}`).send({ from: deployer});

  console.log(`tx hash: ${tx.transactionHash}`);
  });

task('contract:updateStatus', 'Update order status')
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

  enum OrderStatus {
    accepted, 
    call_ship,
    taked,
    warehouse,
    delivering,
    delivery_success,
    rejected,
    return_warehouse,
    return_shop,
    cancel,
    checking,
    checked,
    wait_deposit, 
    deposited 
  };

  const tx = await instance.methods.updateOrderStatus(data.id, OrderStatus.return_shop).send({ from: deployer});

  console.log(`tx hash: ${tx.transactionHash}`);
  });

  task('contract:getOrder', 'Update order status')
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

    const response = await instance.methods.getOrder(data.id).call();

    console.log(response);
  });

  task('contract:setSigner', 'Update order status')
  .addOptionalParam('address', 'address')
  .addOptionalParam('symbol', 'symbol')
  .setAction(async (taskArgs, hre) => {
    const { deployments, getNamedAccounts, web3 } = hre;
    const { deployer } = await getNamedAccounts();

    const Contract = await deployments.get('OrderStore');
    const instance = new web3.eth.Contract(Contract.abi, Contract.address);

    const tx = await instance.methods.setSigner('0x656F29aAe1b4dc71e3070B324515c2208997B348').send({from: deployer});

    console.log(`tx hash: ${tx.transactionHash}`);
  });

  task('contract:setRole', 'Update order status')
  .addOptionalParam('address', 'address')
  .addOptionalParam('symbol', 'symbol')
  .setAction(async (taskArgs, hre) => {
    const { deployments, getNamedAccounts, web3 } = hre;
    const { deployer } = await getNamedAccounts();

    const Contract = await deployments.get('OrderStore');
    const instance = new web3.eth.Contract(Contract.abi, Contract.address);

    const tx = await instance.methods.setRole('0x656F29aAe1b4dc71e3070B324515c2208997B348', '0x80d27d05994edf4994028aeca85fdaca3f2d00ef05d9d609a8b295c631139a65').send({from: deployer});

    console.log(`tx hash: ${tx.transactionHash}`);
  });

  task('contract:consensus', 'Consensus')
  .addOptionalParam('address', 'address')
  .addOptionalParam('symbol', 'symbol')
  .setAction(async (taskArgs, hre) => {
    const { deployments, getNamedAccounts, web3 } = hre;
    const { deployer } = await getNamedAccounts();

    const Contract = await deployments.get('OrderStore');
    const instance = new web3.eth.Contract(Contract.abi, Contract.address);

    const data = {
      id: "18",
      name: "Rượu Mẫu Sơn",
    }
    const hash = sha256(data.name);
    console.log(hash.toString());

    const tx = await instance.methods.submitTransaction('18', `0x${hash}`).send({from: deployer});

    console.log(`tx hash: ${tx.transactionHash}`);
  });