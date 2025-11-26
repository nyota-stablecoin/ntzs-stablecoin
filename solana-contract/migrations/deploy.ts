import * as anchor from '@coral-xyz/anchor';
import * as mpl from "@metaplex-foundation/mpl-token-metadata";
import fs from 'fs';
import { Keypair, PublicKey, } from '@solana/web3.js';
import { calculatePDAs, TokenPDAs } from '../utils/helpers';
import { initializeToken } from '../utils/token_initializer';
import { transferMintAuthority } from '../utils/transfer_authority';
import { createTokenMetadata, updateTokenMetadata } from '../app/utils/metadata';
import { loadOrCreateKeypair } from '../app/utils/helpers';
import { transferFreezeAuthority } from '../utils/freeze_authority';


const { web3 } = anchor;

async function main() {
  const connection = new web3.Connection("http://api.testnet.solana.com", "confirmed");
  // Configure the connection to the cluster
  const provider = new anchor.AnchorProvider(
    connection,
    anchor.Wallet.local(),
  );
  anchor.setProvider(provider);
  const payer = (provider.wallet as anchor.Wallet).payer;
  const program = new anchor.Program(anchor.workspace.Ntzs.idl, provider);
  console.log("Program ID: ", program.programId.toBase58());
  // Create the mint keypair - this will be the actual token
  const ntzsMintKeypair = await loadOrCreateKeypair("ntzsMint")
  console.log("Mint Keypair:", ntzsMintKeypair.publicKey.toString());
 const str = "";
        const newMintAuthority = new PublicKey(str);

  let pdas: TokenPDAs;

  // Calculate all PDAs for the token
  pdas = calculatePDAs(ntzsMintKeypair.publicKey, program.programId);

  try {
        console.log('Program ID: ', program.programId.toBase58());
    console.log("Wallet:", provider.wallet.publicKey.toString());
    console.log("Mint Keypair:", ntzsMintKeypair.publicKey.toString());
    // Initialize the token
   // await initializeToken(program, provider, ntzsMintKeypair, pdas);





    // Step 2: Create token metadata
    console.log("\n--- Step 2: Creating token metadata ---");

    // Create metadata
    const params = {
      name: "NTZS",
      symbol: "nTZS",
      uri: "https://aqua-changing-meadowlark-684.mypinata.cloud/ipfs/bafkreiesa7z3kyazntetn6ce257tax4wipnlx6ss3ahajpn5l7f33rwfsy", // You can update this with a JSON URI later
      sellerFeeBasisPoints: 0,
      creators: null,
      collection: null,
      uses: null,
    };
    console.log("creating/updating NTZS mint metadata")
    await updateTokenMetadata(
      provider,
      ntzsMintKeypair,
      params,
      newMintAuthority
    )
    //await transferFreezeAuthority(newMintAuthority, ntzsMintKeypair.publicKey, payer, connection) 
  } catch (error) {
    console.error("Error during initialization:", error);
    if (error instanceof Error) {
      console.error("Error message:", error.message);
      console.error("Error stack:", error.stack);
    } else {
      console.error("Unknown error:", JSON.stringify(error, null, 2));
    }
  }
}

main().then(
  () => process.exit(0),
  (err) => {
    console.error(err);
    process.exit(1);
  }
);