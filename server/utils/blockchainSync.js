import { ethers } from 'ethers';
import db from './database.js';

const CONTRACTS = {
    EVENT_FACTORY: '0x53687CccF774FDa60fE2bd4720237fbb8e4fd02c',
    EVENT_MANAGER: '0x1651f730a846eD23411180eC71C9eFbFCD05A871'
};

const RPC_URLS = [
    'https://api.avax-test.network/ext/bc/C/rpc',
    'https://avalanche-fuji-c-chain-rpc.publicnode.com',
    'https://rpc.ankr.com/avalanche_fuji'
];

const EVENT_MANAGER_ABI = [
    'event EventCreated(uint256 indexed eventId, address indexed organizer, string name, uint256 eventDate, uint256 eventEndDate)',
    'function getEvent(uint256 eventId) view returns (tuple(address organizer, string name, uint256 eventDate, uint256 eventEndDate, string baseURI, bool active))'
];

export async function syncEventsFromBlockchain() {
    try {
        console.log('🔄 Starting blockchain sync...');
        
        let provider;
        for (const rpcUrl of RPC_URLS) {
            try {
                provider = new ethers.JsonRpcProvider(rpcUrl, 43113, { staticNetwork: true });
                await provider.getBlockNumber();
                break;
            } catch (err) {
                continue;
            }
        }
        
        if (!provider) {
            throw new Error('All RPC endpoints failed');
        }
        
        const eventManager = new ethers.Contract(CONTRACTS.EVENT_MANAGER, EVENT_MANAGER_ABI, provider);
        
        const filter = eventManager.filters.EventCreated();
        const events = await eventManager.queryFilter(filter, 0, 'latest');
        
        let synced = 0;
        
        for (const event of events) {
            const blockchainEventId = Number(event.args.eventId);
            
            const existing = db.prepare('SELECT id FROM events WHERE blockchain_event_id = ?').get(blockchainEventId);
            
            if (!existing) {
                try {
                    const eventDetails = await eventManager.getEvent(blockchainEventId);
                    
                    db.prepare(`
                        INSERT INTO events (
                            event_name, event_date, venue, creator_address, 
                            blockchain_event_id, blockchain_tx_hash
                        ) VALUES (?, ?, ?, ?, ?, ?)
                    `).run(
                        event.args.name,
                        new Date(Number(event.args.eventDate) * 1000).toISOString(),
                        'Blockchain Event',
                        event.args.organizer,
                        blockchainEventId,
                        event.transactionHash
                    );
                    
                    synced++;
                } catch (err) {
                    console.error(`Failed to sync event ${blockchainEventId}:`, err.message);
                }
            }
        }
        
        console.log(`✅ Blockchain sync complete: ${synced} new events synced`);
    } catch (error) {
        console.error('❌ Blockchain sync failed:', error.message);
    }
}
