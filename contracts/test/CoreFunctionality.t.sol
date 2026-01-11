// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EventFactory.sol";

contract CoreFunctionalityTest is Test {
    EventFactory public factory;
    TicketNFT public ticketImpl;
    EventManager public eventManager;
    Marketplace public marketplace;
    
    address public organizer = makeAddr("organizer");
    address public buyer = makeAddr("buyer");
    address public treasury = makeAddr("treasury");
    
    event EventCreated(uint256 indexed eventId, address indexed organizer, address ticketContract, uint256 eventDate);
    
    function setUp() public {
        ticketImpl = new TicketNFT();
        eventManager = new EventManager();
        marketplace = new Marketplace(address(eventManager));
        factory = new EventFactory(
            address(ticketImpl),
            treasury,
            address(eventManager),
            address(marketplace)
        );
    }
    
    function test_CreateEvent_Success() public {
        uint256 eventDate = block.timestamp + 1 days;
        uint256 endDate = block.timestamp + 2 days;
        
        vm.expectEmit(true, true, false, true);
        emit EventCreated(1, organizer, address(0), eventDate); // address will be different
        
        vm.prank(organizer);
        uint256 eventId = factory.createEvent(
            eventDate,
            endDate,
            "Test Event",
            "ipfs://test"
        );
        
        assertEq(eventId, 1);
        assertEq(factory.organizerEventCount(organizer), 1);
        assertTrue(factory.eventTicket(eventId) != address(0));
        
        console.log("Event created successfully");
        console.log("   Event ID:", eventId);
        console.log("   Organizer event count:", factory.organizerEventCount(organizer));
    }
    
    function test_CreateEvent_RevertPastDate() public {
        vm.prank(organizer);
        vm.expectRevert();
        factory.createEvent(
            block.timestamp - 1 days,
            block.timestamp + 1 days,
            "Past Event",
            "ipfs://past"
        );
        
        console.log("Past date validation works");
    }
    
    function test_MintTicket_Success() public {
        // Create event
        vm.prank(organizer);
        uint256 eventId = factory.createEvent(
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Mint Test",
            "ipfs://mint"
        );
        
        TicketNFT ticket = TicketNFT(factory.eventTicket(eventId));
        
        // Mint ticket
        vm.prank(organizer);
        uint256 tokenId = ticket.mintTicket(buyer, 1 ether, "VIP");
        
        assertEq(ticket.ownerOf(tokenId), buyer);
        assertEq(ticket.totalSupply(), 1);
        
        console.log("Ticket minted successfully");
        console.log("   Token ID:", tokenId);
        console.log("   Owner:", ticket.ownerOf(tokenId));
        console.log("   Total supply:", ticket.totalSupply());
    }
    
    function test_BatchMint_Success() public {
        vm.prank(organizer);
        uint256 eventId = factory.createEvent(
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Batch Test",
            "ipfs://batch"
        );
        
        TicketNFT ticket = TicketNFT(factory.eventTicket(eventId));
        
        address[] memory recipients = new address[](3);
        recipients[0] = makeAddr("buyer1");
        recipients[1] = makeAddr("buyer2");
        recipients[2] = makeAddr("buyer3");
        
        vm.prank(organizer);
        ticket.batchMint(recipients, 1 ether, "General");
        
        assertEq(ticket.totalSupply(), 3);
        assertEq(ticket.ownerOf(1), recipients[0]);
        assertEq(ticket.ownerOf(2), recipients[1]);
        assertEq(ticket.ownerOf(3), recipients[2]);
        
        console.log("Batch minting successful");
        console.log("   Total minted:", ticket.totalSupply());
    }
    
    function test_PlatformFee_Update() public {
        uint256 newFee = 500; // 5%
        
        factory.setPlatformFee(newFee);
        assertEq(factory.platformFeeBps(), newFee);
        
        // Test fee too high
        vm.expectRevert();
        factory.setPlatformFee(1001); // > 10%
        


        console.log("Platform fee management works");
        console.log("   New fee:", factory.platformFeeBps(), "bps");
    }
    
    function test_EventManager_Registration() public {
        vm.prank(organizer);
        uint256 eventId = factory.createEvent(
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "Manager Test",
            "ipfs://manager"
        );
        
        (address org, address ticketContract, uint256 startTime, uint256 endTime, bool active) = 
            eventManager.events(eventId);
        
        assertEq(org, organizer);
        assertTrue(ticketContract != address(0));
        assertTrue(active);
        
        console.log("Event registered with EventManager");
        console.log("   Organizer:", org);
        console.log("   Active:", active);
    }
}