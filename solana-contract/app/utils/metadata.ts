



import { Keypair } from '@solana/web3.js';
import * as anchor from '@coral-xyz/anchor';
import * as mpl from "@metaplex-foundation/mpl-token-metadata";

interface TokenParams {
  name: string;
  symbol: string;
  uri: string;
  maxSupply?: anchor.BN;
}

export async function createTokenMetadata(
  provider: anchor.AnchorProvider,
  mint: Keypair,
  params: TokenParams,
): Promise<string> {
  const payer = (provider.wallet as anchor.Wallet).payer;

  const seed1 = Buffer.from(anchor.utils.bytes.utf8.encode("metadata"));
  const seed2 = Buffer.from(mpl.PROGRAM_ID.toBytes());
  const seed3 = Buffer.from(mint.publicKey.toBytes());
  const [metadataPDA] = anchor.web3.PublicKey.findProgramAddressSync(
    [seed1, seed2, seed3],
    mpl.PROGRAM_ID
  );

  const dataV2 = {
    name: params.name,
    symbol: params.symbol,
    uri: params.uri,
    sellerFeeBasisPoints: 0,
    creators: null,
    collection: null,
    decimals: 6,
    uses: null,
  };

  const accounts: mpl.CreateMetadataAccountV3InstructionAccounts = {
    metadata: metadataPDA,
    mint: mint.publicKey,
    mintAuthority: payer.publicKey,
    payer: payer.publicKey,
    updateAuthority: payer.publicKey,
    systemProgram: anchor.web3.SystemProgram.programId,
    rent: anchor.web3.SYSVAR_RENT_PUBKEY,
  };

  const args: mpl.CreateMetadataAccountV3InstructionArgs = {
    createMetadataAccountArgsV3: {
      data: dataV2,
      isMutable: true,
      collectionDetails: null,
    },
  };

  const ix = mpl.createCreateMetadataAccountV3Instruction(accounts, args);
  const mpltx = new anchor.web3.Transaction();
  mpltx.add(ix);

  const metadataTxSignature = await anchor.web3.sendAndConfirmTransaction(
    provider.connection,
    mpltx,
    [payer]
  );

  console.log("Token metadata created:", metadataTxSignature);
  console.log("Token mint address:", mint.publicKey.toString());
  console.log(
    "Explorer link:",
    `https://explorer.solana.com/address/${mint.publicKey.toString()}?cluster=devnet`
  );

  return metadataTxSignature;
}

export async function updateTokenMetadata(
  provider: anchor.AnchorProvider,
  mint: Keypair,
  params: TokenParams,
  updateAuthority?: anchor.web3.PublicKey
): Promise<string> {
  const payer = (provider.wallet as anchor.Wallet).payer;

  const seed1 = Buffer.from(anchor.utils.bytes.utf8.encode("metadata"));
  const seed2 = Buffer.from(mpl.PROGRAM_ID.toBytes());
  const seed3 = Buffer.from(mint.publicKey.toBytes());
  const [metadataPDA] = anchor.web3.PublicKey.findProgramAddressSync(
    [seed1, seed2, seed3],
    mpl.PROGRAM_ID
  );

  const dataV2 = {
    name: params.name,
    symbol: params.symbol,
    uri: params.uri,
    sellerFeeBasisPoints: 0,
    creators: null,
    collection: null,
    decimals: 6,
    uses: null,
  };

  const accounts: mpl.UpdateMetadataAccountV2InstructionAccounts = {
    metadata: metadataPDA,
    updateAuthority: payer.publicKey,
  };

  const args: mpl.UpdateMetadataAccountV2InstructionArgs = {
    updateMetadataAccountArgsV2: {
      data: dataV2,
      isMutable: true,
      updateAuthority: updateAuthority,
      primarySaleHappened: null,
    },
  };

  const ix = mpl.createUpdateMetadataAccountV2Instruction(accounts, args);
  const mpltx = new anchor.web3.Transaction();
  mpltx.add(ix);

  const metadataTxSignature = await anchor.web3.sendAndConfirmTransaction(
    provider.connection,
    mpltx,
    [payer]
  );

  console.log("Token metadata updated:", metadataTxSignature);
  console.log("Token mint address:", mint.publicKey.toString());
  console.log(
    "Explorer link:",
    `https://explorer.solana.com/address/${mint.publicKey.toString()}?cluster=devnet`
  );

  return metadataTxSignature;
}