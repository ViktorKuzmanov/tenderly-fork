// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BeaconProxy} from "../proxy/BeaconProxy.sol";
import {IAccount} from "../interface/core/IAccount.sol";
import {IAccountFactory} from "../interface/core/IAccountFactory.sol";

/**
    @title Account Factory
    @notice Factory that creates Account as a beacon proxy
*/
contract AccountFactory is IAccountFactory {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Address of account beacon
    address public beacon;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _beacon address of account beacon
    */
    constructor (address _beacon) {
        beacon = _beacon;
    }

    /* -------------------------------------------------------------------------- */
    /*                             EXTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Account creator
        @param accountManager Address of account manager
        @dev Emits AccountCreated(account, accountManager) event
        @return account Address of account created
    */
    // a: vaa funkcija kreira nov Account kako beacon proxy
    // a: Namesto da se kreira nov Account, se kreira nov BeaconProxy contract cijasno admin e accountManager adresata
    // so a predavas kaa argument a beacon adresata e postavena kaa beacon
    function create(address accountManager)
        external
        returns (address account)
    {
        account = address(new BeaconProxy(beacon, accountManager));
        emit AccountCreated(account, accountManager);
    }
}
