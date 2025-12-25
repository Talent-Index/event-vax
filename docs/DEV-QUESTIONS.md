// This document is for the developement quiz I have gathered during building

1. In the file TicketNFT.sol

# Logic Error: Wrong Comparison

`if (balance <= used) revert NoUnusedTickets();`

**Problem:** This allows checking in when balance == used, which means no unused tickets.

Example:

User has 2 tickets (balance = 2)

User checked in 2 times (used = 2)

2 <= 2 is true → reverts ✅ Correct

Actually, this logic is correct. If balance <= used, there are no unused tickets.

# No Double Check-In Prevention 🔴 CRITICAL
`usedTickets[user][tierId]++;`

**Problem:** This allows checking in multiple times if user has multiple tickets.

Attack Scenario:

User buys 5 tickets

User checks in 5 times (uses all tickets) ✅

User transfers 1 ticket from another account

User can check in again! 🔴

The Real Issue: No tracking of which specific ticket was used, only a counter.

# Missing Event Timestamp ℹ️
The event doesn't include when the check-in happened:


`
emit TicketCheckedIn(user, tierId);
// Should include: block.timestamp
`

# Summary of Issues:
Issue	Severity	Description
Missing nonReentrant	Low	External call before state change
Logic comparison	✅ Correct	Actually works as intended
Multiple check-ins	Medium	User can check in multiple times if they have multiple tickets
Missing timestamp	Low	Event lacks temporal data
The Biggest Issue:
The function allows multiple check-ins per user if they own multiple tickets. This might be:

✅ Intended: If user bought 5 tickets, they can bring 5 people

🔴 Bug: If each ticket should only allow 1 check-in per person

Depends on your business logic: Is this a ticket for entry (one person, multiple entries) or a ticket representing multiple people?
*/