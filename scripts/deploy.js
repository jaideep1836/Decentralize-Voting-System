/**
 * Deploys DecentralizedVoting.sol to the “coreTestnet” network.
 *
 * Uses Hardhat config:
 *  - RPC: https://rpc.test2.btcs.network
 *  - Chain ID: 1114
 *  - Signer: PRIVATE_KEY in .env
 *
 * To run:
 *   npx hardhat run scripts/deploy.js --network coreTestnet
 */

const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const Voting = await hre.ethers.getContractFactory("DecentralizedVoting");
  const voting = await Voting.deploy();
  await voting.deployed();

  console.log("DecentralizedVoting deployed to:", voting.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
