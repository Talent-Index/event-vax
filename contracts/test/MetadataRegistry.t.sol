// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MetadataRegistry.sol";

contract MetadataRegistryTest is Test {
    MetadataRegistry public registry;
    
    address public organizer = address(0x1);
    address public ticketContract = address(0x2);
    
    function setUp() public {
        registry = new MetadataRegistry();
    }
    
    function testRegisterEventMetadata() public {
        vm.prank(organizer);
        registry.registerEventMetadata(
            1,
            "Test Event",
            "Test Description",
            "Test Location",
            block.timestamp + 1 days,
            "ipfs://image"
        );
        
        (string memory name, , , , ) = registry.eventMetadata(1);
        assertEq(name, "Test Event");
    }
    
    function testUpdateEventMetadata() public {
        vm.startPrank(organizer);
        registry.registerEventMetadata(
            1,
            "Test Event",
            "Description",
            "Location",
            block.timestamp + 1 days,
            "ipfs://image"
        );
        
        registry.updateEventMetadata(
            1,
            "Updated Event",
            "New Description",
            "New Location",
            block.timestamp + 2 days,
            "ipfs://new"
        );
        vm.stopPrank();
        
        (string memory name, , , , ) = registry.eventMetadata(1);
        assertEq(name, "Updated Event");
    }
    
    function testRegisterTicketMetadata() public {
        vm.prank(organizer);
        registry.registerTicketMetadata(
            ticketContract,
            1,
            "VIP",
            "ipfs://ticket"
        );
        
        (string memory category, string memory uri) = 
            registry.ticketMetadata(ticketContract, 1);
        assertEq(category, "VIP");
        assertEq(uri, "ipfs://ticket");
    }
}
