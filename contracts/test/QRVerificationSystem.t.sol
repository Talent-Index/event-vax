// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/QRVerificationSystem.sol";

contract QRVerificationSystemTest is Test {
    QRVerificationSystem public qrSystem;
    TicketNFT public ticket;
    address public eventManager;
    address public marketplace;
    
    address public organizer = address(0x1);
    address public attendee = address(0x2);
    uint256 public tokenId;
    
    function setUp() public {
        eventManager = address(new EventManager());
        marketplace = address(new Marketplace(eventManager));
        qrSystem = new QRVerificationSystem();
        ticket = new TicketNFT();
        
        ticket.initialize(
            organizer,
            1,
            block.timestamp + 1 days,
            "Test Event",
            "ipfs://base/",
            marketplace,
            eventManager
        );
        
        vm.prank(organizer);
        tokenId = ticket.mintTicket(attendee, 1 ether, "VIP");
    }
    
    function testVerifyTicket() public {
        bool isValid = qrSystem.verifyTicket(address(ticket), tokenId, attendee);
        assertTrue(isValid);
    }
    
    function testFailVerifyWrongOwner() public {
        qrSystem.verifyTicket(address(ticket), tokenId, address(0x3));
    }
    
    function testCheckInTicket() public {
        vm.prank(organizer);
        qrSystem.checkInTicket(address(ticket), tokenId, attendee);
        
        assertTrue(qrSystem.isCheckedIn(address(ticket), tokenId));
    }
    
    function testFailDoubleCheckIn() public {
        vm.startPrank(organizer);
        qrSystem.checkInTicket(address(ticket), tokenId, attendee);
        qrSystem.checkInTicket(address(ticket), tokenId, attendee);
        vm.stopPrank();
    }
}
