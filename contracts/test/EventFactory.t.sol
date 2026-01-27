// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EventFactory.sol";

contract EventFactoryTest is Test {
    EventFactory public factory;
    address public ticketImpl;
    address public eventManager;
    address public marketplace;
    
    address public treasury = address(0x1);
    address public organizer = address(0x2);
    
    function setUp() public {
        eventManager = address(new EventManager());
        marketplace = address(new Marketplace(eventManager));
        ticketImpl = address(new TicketNFT());
        factory = new EventFactory(
            ticketImpl,
            treasury,
            eventManager,
            marketplace
        );
    }
    
    function testCreateEvent() public {
        vm.prank(organizer);
        uint256 eventId = factory.createEvent(
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Test Event",
            "ipfs://test"
        );
        
        assertEq(eventId, 1);
        assertEq(factory.organizerEventCount(organizer), 1);
        assertTrue(factory.eventTicket(eventId) != address(0));
    }
    
    function testFailCreateEventInPast() public {
        vm.prank(organizer);
        factory.createEvent(
            block.timestamp - 1 days,
            block.timestamp + 1 days,
            "Test Event",
            "ipfs://test"
        );
    }
    
    function testSetPlatformFee() public {
        factory.setPlatformFee(500);
        assertEq(factory.platformFeeBps(), 500);
    }
    
    function testFailSetPlatformFeeTooHigh() public {
        factory.setPlatformFee(1001);
    }
}
