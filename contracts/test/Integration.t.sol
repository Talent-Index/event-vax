// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EventFactory.sol";

contract IntegrationTest is Test {
    EventFactory public factory;
    
    address public organizer = address(0x1);
    address public buyer = address(0x2);
    address public treasury = address(0x3);
    
    function setUp() public {
        // Deploy all contracts
        TicketNFT ticketImpl = new TicketNFT();
        EventManager eventManager = new EventManager();
        Marketplace marketplace = new Marketplace(address(eventManager));
        
        factory = new EventFactory(
            address(ticketImpl),
            treasury,
            address(eventManager),
            address(marketplace)
        );
    }
    
    function testFullWorkflow() public {
        // 1. Create event
        vm.prank(organizer);
        uint256 eventId = factory.createEvent(
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Test Concert",
            "ipfs://test-metadata"
        );
        
        assertEq(eventId, 1);
        address ticketContract = factory.eventTicket(eventId);
        assertTrue(ticketContract != address(0));
        
        // 2. Mint tickets
        vm.prank(organizer);
        TicketNFT ticket = TicketNFT(ticketContract);
        uint256 tokenId = ticket.mintTicket(buyer, 1 ether, "VIP");
        
        assertEq(ticket.ownerOf(tokenId), buyer);
        assertEq(ticket.totalSupply(), 1);
        
        // 3. Verify ticket ownership
        assertTrue(ticket.ownerOf(tokenId) == buyer);
        
        console.log("Event created with ID:", eventId);
        console.log("Ticket contract deployed at:", ticketContract);
        console.log("Ticket minted with ID:", tokenId);
        console.log("Ticket owner:", ticket.ownerOf(tokenId));
    }
    
    function testEventCreationLimits() public {
        // Test past date rejection
        vm.prank(organizer);
        vm.expectRevert();
        factory.createEvent(
            block.timestamp - 1 days,
            block.timestamp + 1 days,
            "Past Event",
            "ipfs://past"
        );
        
        // Test invalid duration
        vm.prank(organizer);
        vm.expectRevert();
        factory.createEvent(
            block.timestamp + 2 days,
            block.timestamp + 1 days,
            "Invalid Duration",
            "ipfs://invalid"
        );
        
        console.log("Event validation works correctly");
    }
    
    function testTicketMinting() public {
        // Create event first
        vm.prank(organizer);
        uint256 eventId = factory.createEvent(
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Mint Test",
            "ipfs://mint"
        );
        
        TicketNFT ticket = TicketNFT(factory.eventTicket(eventId));
        
        // Test unauthorized minting
        vm.prank(buyer);
        vm.expectRevert();
        ticket.mintTicket(buyer, 1 ether, "Unauthorized");
        
        // Test authorized minting
        vm.prank(organizer);
        uint256 tokenId = ticket.mintTicket(buyer, 1 ether, "General");
        
        assertEq(ticket.ownerOf(tokenId), buyer);
        
        console.log("Ticket minting authorization works");
    }
    
    function testMarketplaceListing() public {
        // Setup
        vm.prank(organizer);
        uint256 eventId = factory.createEvent(
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Market Test",
            "ipfs://market"
        );
        
        TicketNFT ticket = TicketNFT(factory.eventTicket(eventId));
        Marketplace marketplace = Marketplace(payable(ticket.marketplace()));
        
        vm.prank(organizer);
        uint256 tokenId = ticket.mintTicket(buyer, 1 ether, "Resale");
        
        // List ticket for resale
        vm.startPrank(buyer);
        ticket.approve(address(marketplace), tokenId);
        marketplace.listTicket(address(ticket), tokenId, 1.5 ether);
        vm.stopPrank();
        
        (address lister, uint256 price, bool active) = marketplace.listings(address(ticket), tokenId);
        assertEq(lister, buyer);
        assertEq(price, 1.5 ether);
        assertTrue(active);
        
        console.log("Marketplace listing works");
        console.log("   Listed by:", lister);
        console.log("   Price:", price);
    }
}