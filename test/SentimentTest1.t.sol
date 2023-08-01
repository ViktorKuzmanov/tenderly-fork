// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
// import "../interfaces/IAccount.sol";
import "../src/interface/core/IAccount.sol";

// This SentimentTest1 test does Typical Borrowing Flow:
    // Borrower opens an account and deposits collateral.
    // Assets are borrowed against the collateral and transferred to the account.
    // Borrower deploys the borrowed assets to various contracts in DeFi

contract SentimentTest1 is Test {

    address public lusdtContract = 0x4c8e1656E042A206EEf7e8fcff99BaC667E4623e;
    address public accountManagerAddress = 0x62c5AA8277E49B3EAd43dC67453ec91DC6826403;
    address public registryContractAddress = 0x17B07cfBAB33C0024040e7C299f8048F4a49679B;
    address public riskEngineContractAddress = 0xc0ac97A0eA320Aa1E32e9DEd16fb580Ef3C078Da; 

    address public usdcLtokenTokenizedVaultAddress = 0x0dDB1eA478F8eF0E22C7706D2903a41E94B1299B;

    // vaa adresa 0xE68Ee8A12c611fd043fB05d65E1548dC1383f2b9 u via block 112421711 ima 12eth i 23m usdc 
    address public impersonatedWalletAddress = 0xE68Ee8A12c611fd043fB05d65E1548dC1383f2b9;

    uint arbitrumForkId;
    uint public forkBlockNumber = 112_421_711;

    function setUp() public {
        arbitrumForkId = vm.createFork("https://rpc.tenderly.co/fork/9bc75b3e-798d-4770-876d-139db0affe50", forkBlockNumber);
    }

    function interactWithLUSDT() internal {
        (bool success, bytes memory dataReturned) = address(lusdtContract).call{gas: 100000}
        (
            abi.encodeWithSignature("getAdmin()")
        );
        require(success, "v-2: the call failed miserably");
        // this should return this address which is the admin of the LUSDT contract 0x92f473ef0cd07080824f5e6b0859ac49b3aeb215 
        emit log_named_bytes("admin of the LUSDT contract", dataReturned);
    }

    function testBorrowingFlow() public {
        vm.selectFork(arbitrumForkId);
        assertEq(block.number, forkBlockNumber); 
        // duri i da ne napravam startprank, pak owner na Account-ot kje mi bide impersonatedWalletAddress oti go predavam impersonatedWalletAddress kako argument na openAccount 
        vm.startPrank(impersonatedWalletAddress);

        (bool success, bytes memory dataReturned) = address(accountManagerAddress).call
        (
            abi.encodeWithSignature("openAccount(address)", impersonatedWalletAddress)
        );
        require(success, "v-3: the call failed miserably");
        emit log_named_bytes("returned newly created Account address func =", dataReturned); // 0x000000000000000000000000f0603d8484dffe67dc8413190854985ad636fa14 aka newlyOpenedAccountAddress
        address newlyOpenedAccountAddress = 0xF0603D8484DFfe67dc8413190854985AD636fA14;

        uint a = IAccount(newlyOpenedAccountAddress).activationBlock();
        console.log("activationBlock na Account-ot = %s", a);

        // Deposit ETH as collateral into my newly created Account
        (bool success1, bytes memory dataReturned1) = address(accountManagerAddress).call{value: 10000000000000000000}(abi.encodeWithSignature("depositEth(address)", newlyOpenedAccountAddress));
        require(success1, "v-4: the call failed miserably");
        emit log_named_bytes("... =", dataReturned1);

        // Check if my account is healthy after depositing ETH as collateral
        // (bool success2, bytes memory dataReturned2) = address(riskEngineContractAddress).call(abi.encodeWithSignature("isAccountHealthy(address)", newlyOpenedAccountAddress));
        // require(success2, "v-5: the call failed miserably");
        // emit log_named_bytes("is my account healty after depositing eth as collateral =", dataReturned2);

        // getBorrowBalance getBorrowRatePerSecond riskEngine.isBorrowAllowed
        
        // Check if the borrow I want to make is allowed. Ja mislam $1897 e cena na 1 eth na arbitrum u vreme na forkot, arno ama on kaa da go racuna deka e povekje kaa da e $1900 mi dava da borrow
        // bridgedusdc aka tokenot so go borrow 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8
        // Spored vaa tx 0xa7c6ac5aa8cb2612d772c1193dd1e54a0dcf1ce388a53685c0c689a39ada7ac8 u blockot koj so mi e forknata arbitrum ether imal cena $1,897.93 / ETH
        // (bool success3, bytes memory dataReturned3) = address(riskEngineContractAddress).call(abi.encodeWithSignature("isBorrowAllowed(address,address,uint256)", newlyOpenedAccountAddress, 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8, 95000000000));
        // require(success3, "v-6: the call failed miserably");
        // emit log_named_bytes("isBorrowAllowed =", dataReturned3);

        // Napraj actual borrow
        (bool success5, bytes memory dataReturned5) = address(accountManagerAddress).call(abi.encodeWithSignature("borrow(address,address,uint256)", newlyOpenedAccountAddress, 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8, 93000000000));
        require(success5, "v-7: the call failed miserably");
        emit log_named_bytes("napraviv borrow =", dataReturned5);

        // // imam $92.907 USDC t.e. 92907000000
        // (bool success6, bytes memory dataReturned6) = address(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8).call(abi.encodeWithSignature("balanceOf(address)", newlyOpenedAccountAddress));
        // require(success6, "v-9: the call failed miserably");
        // emit log_named_bytes("balance of my account of USDC  =", dataReturned6);

        address(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8).call(abi.encodeWithSignature("approve(address,uint256)", usdcLtokenTokenizedVaultAddress, 900000000));

        address(usdcLtokenTokenizedVaultAddress).call(abi.encodeWithSignature("deposit(uint256,address)", 500000000, newlyOpenedAccountAddress));
        // require(success7, "v-10: the call failed miserably");
        // emit log_named_bytes("dataReturned7 =", dataReturned7);

        (bool s2, bytes memory d2) = address(usdcLtokenTokenizedVaultAddress).call(abi.encodeWithSignature("balanceOf(address)", newlyOpenedAccountAddress));
        require(s2, "v-10: the call failed miserably");
        emit log_named_bytes("number of interest bearing tokens t.e. shares minted after deposit into t. vault = ", d2); // 475834594  400 000 000

        // vm.roll(block.number + 1000);

        // (bool s3, bytes memory d3) = address(usdcLtokenTokenizedVaultAddress).call(abi.encodeWithSignature("balanceOf(address)", newlyOpenedAccountAddress));
        // require(s3, "v-10: the call failed miserably");
        // emit log_named_bytes("number of shares posle 1000 blocks =", d3);

        // (bool s5, bytes memory d5) = address(usdcLtokenTokenizedVaultAddress).call(abi.encodeWithSignature("maxRedeem(address)", newlyOpenedAccountAddress));
        // require(s5, "v-10: the call failed miserably");
        // emit log_named_bytes("max redeem  =", d5);// 475834594 400000000

        // (bool s4, bytes memory d4) = address(usdcLtokenTokenizedVaultAddress).call(abi.encodeWithSignature("redeem(uint256,address,address)", 400000000, newlyOpenedAccountAddress, newlyOpenedAccountAddress));
        // require(s4, "v-10: the call failed miserably");
        // emit log_named_bytes("redeem  =", d4);

        // (bool success0, bytes memory dataReturned0) = address(riskEngineContractAddress).call(abi.encodeWithSignature("getBalance(address)", newlyOpenedAccountAddress));
        // require(success0, "v-8: the call failed miserably");
        // emit log_named_bytes("balance of my account aka getBalance() =", dataReturned0);

        vm.stopPrank();
    }
}