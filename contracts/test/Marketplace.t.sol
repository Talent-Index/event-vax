// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Marketplace.sol";

contract MarketplaceTest is Test {
    Marketplace public marketplace;
    TicketNFT public ticket;
    address public eventManager;
    
    address public organizer = address(0x1);
    address public seller = address(0x2);
    address public buyer = address(0x3);
    uint256 public tokenId;
    
    function setUp() public {
        eventManager = address(new EventManager());
        marketplace = new Marketplace(eventManager);
        ticket = new TicketNFT();
        
        ticket.initialize(
            organizer,
            1,
            block.timestamp + 1 days,
            "Test Event",
            "ipfs://base/",
            address(marketplace),
            eventManager
        );
        
        vm.prank(organizer);
        tokenId = ticket.mintTicket(seller, 1 ether, "VIP");
    }
    
    function testListTicket() public {
        vm.startPrank(seller);
        ticket.approve(address(marketplace), tokenId);
        marketplace.listTicket(address(ticket), tokenId, 1.5 ether);
        vm.stopPrank();
        
        (address lister, uint256 price, bool active) = marketplace.listings(address(ticket), tokenId);
        assertEq(lister, seller);
        assertEq(price, 1.5 ether);
        assertTrue(active);
    }
    
    function testBuyTicket() public {
        vm.startPrank(seller);
        ticket.approve(address(marketplace), tokenId);
        marketplace.listTicket(address(ticket), tokenId, 1 ether);
        vm.stopPrank();
        
        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        marketplace.buyTicket{value: 1 ether}(address(ticket), tokenId);
        
        assertEq(ticket.ownerOf(tokenId), buyer);
    }
    
    function testCancelListing() public {
        vm.startPrank(seller);
        ticket.approve(address(marketplace), tokenId);
        marketplace.listTicket(address(ticket), tokenId, 1 ether);
        marketplace.cancelListing(address(ticket), tokenId);
        vm.stopPrank();
        
        (, , bool active) = marketplace.listings(address(ticket), tokenId);
        assertFalse(active);
    }
}
