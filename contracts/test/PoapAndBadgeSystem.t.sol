// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PoapAndBadgeSystem.sol";

contract POAPTest is Test {
    POAP public poap;
    
    address public organizer = address(0x1);
    address public attendee = address(0x2);
    
    function setUp() public {
        poap = new POAP();
    }
    
    function testMintPOAP() public {
        vm.prank(organizer);
        uint256 tokenId = poap.mintPOAP(
            attendee,
            1,
            "Test Event",
            "ipfs://metadata"
        );
        
        assertEq(poap.ownerOf(tokenId), attendee);
        assertEq(poap.balanceOf(attendee), 1);
    }
    
    function testBatchMintPOAP() public {
        address[] memory recipients = new address[](3);
        recipients[0] = address(0x3);
        recipients[1] = address(0x4);
        recipients[2] = address(0x5);
        
        vm.prank(organizer);
        poap.batchMintPOAP(recipients, 1, "Test Event", "ipfs://metadata");
        
        assertEq(poap.balanceOf(recipients[0]), 1);
        assertEq(poap.balanceOf(recipients[1]), 1);
        assertEq(poap.balanceOf(recipients[2]), 1);
    }
}

contract EventBadgeTest is Test {
    EventBadge public badge;
    
    address public organizer = address(0x1);
    address public attendee = address(0x2);
    
    function setUp() public {
        badge = new EventBadge();
    }
    
    function testMintBadge() public {
        vm.prank(organizer);
        uint256 tokenId = badge.mintBadge(
            attendee,
            1,
            "VIP Badge",
            "ipfs://badge"
        );
        
        assertEq(badge.ownerOf(tokenId), attendee);
    }
    
    function testGetUserBadges() public {
        vm.startPrank(organizer);
        badge.mintBadge(attendee, 1, "Badge 1", "ipfs://1");
        badge.mintBadge(attendee, 1, "Badge 2", "ipfs://2");
        vm.stopPrank();
        
        uint256[] memory badges = badge.getUserBadges(attendee);
        assertEq(badges.length, 2);
    }
}
