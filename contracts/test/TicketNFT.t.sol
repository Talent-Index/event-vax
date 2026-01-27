// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TicketNFT.sol";

contract TicketNFTTest is Test {
    TicketNFT public ticket;
    address public eventManager;
    address public marketplace;
    
    address public organizer = address(0x1);
    address public buyer = address(0x2);
    uint256 public eventId = 1;
    
    function setUp() public {
        eventManager = address(new EventManager());
        marketplace = address(new Marketplace(eventManager));
        ticket = new TicketNFT();
        
        ticket.initialize(
            organizer,
            eventId,
            block.timestamp + 1 days,
            "Test Event",
            "ipfs://base/",
            marketplace,
            eventManager
        );
    }
    
    function testMintTicket() public {
        vm.prank(organizer);
        uint256 tokenId = ticket.mintTicket(buyer, 1 ether, "VIP");
        
        assertEq(ticket.ownerOf(tokenId), buyer);
        assertEq(ticket.totalSupply(), 1);
    }
    
    function testFailMintUnauthorized() public {
        vm.prank(buyer);
        ticket.mintTicket(buyer, 1 ether, "VIP");
    }
    
    function testBatchMint() public {
        address[] memory recipients = new address[](3);
        recipients[0] = address(0x3);
        recipients[1] = address(0x4);
        recipients[2] = address(0x5);
        
        vm.prank(organizer);
        ticket.batchMint(recipients, 1 ether, "General");
        
        assertEq(ticket.totalSupply(), 3);
    }
}
