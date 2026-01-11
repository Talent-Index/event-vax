// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EventManager.sol";

contract EventManagerTest is Test {
    EventManager public eventManager;
    
    address public organizer = address(0x1);
    address public ticketContract = address(0x2);
    
    function setUp() public {
        eventManager = new EventManager();
    }
    
    function testRegisterEvent() public {
        eventManager.registerEvent(
            1,
            organizer,
            ticketContract,
            block.timestamp + 1 days,
            block.timestamp + 2 days
        );
        
        (address org, address ticket, uint256 start, uint256 end, bool active) = 
            eventManager.events(1);
        
        assertEq(org, organizer);
        assertEq(ticket, ticketContract);
        assertTrue(active);
    }
    
    function testCheckInAttendee() public {
        eventManager.registerEvent(
            1,
            organizer,
            ticketContract,
            block.timestamp + 1 days,
            block.timestamp + 2 days
        );
        
        vm.prank(organizer);
        eventManager.checkInAttendee(1, address(0x3));
        
        assertTrue(eventManager.hasCheckedIn(1, address(0x3)));
    }
    
    function testGetEventAttendees() public {
        eventManager.registerEvent(
            1,
            organizer,
            ticketContract,
            block.timestamp + 1 days,
            block.timestamp + 2 days
        );
        
        vm.startPrank(organizer);
        eventManager.checkInAttendee(1, address(0x3));
        eventManager.checkInAttendee(1, address(0x4));
        vm.stopPrank();
        
        address[] memory attendees = eventManager.getEventAttendees(1);
        assertEq(attendees.length, 2);
    }
}
