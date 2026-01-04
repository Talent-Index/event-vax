// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TicketNFT} from "../src/TicketNFT.sol";
import {EventFactory} from "../src/EventFactory.sol";
import {EventManager} from "../src/EventManager.sol";
import {Marketplace} from "../src/Marketplace.sol";

/**
 * @title DeployCore
 * @notice Deploys only core contracts for testing
 */
contract DeployCore is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying core contracts...");
        console.log("Deployer:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy core contracts
        TicketNFT ticketImpl = new TicketNFT();
        EventManager eventManager = new EventManager();
        Marketplace marketplace = new Marketplace(deployer);
        EventFactory factory = new EventFactory(
            address(ticketImpl),
            deployer,
            address(eventManager),
            address(marketplace)
        );

        // Grant roles
        eventManager.grantRole(eventManager.EVENT_ADMIN(), address(factory));

        vm.stopBroadcast();

        console.log("\n=== Core Deployment Complete ===");
        console.log("TicketNFT Implementation:", address(ticketImpl));
        console.log("EventManager:", address(eventManager));
        console.log("Marketplace:", address(marketplace));
        console.log("EventFactory:", address(factory));
    }
}
