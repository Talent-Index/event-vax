import EventFactoryABI from './EventFactory.json' assert { type: 'json' };
import MarketplaceABI from './Marketplace.json' assert { type: 'json' };
import EventManagerABI from './EventManager.json' assert { type: 'json' };
import QRVerificationABI from './QRVerificationSystem.json' assert { type: 'json' };
import TicketNFTABI from './TicketNFT.json' assert { type: 'json' };
import POAPABI from './POAP.json' assert { type: 'json' };
import EventBadgeABI from './EventBadge.json' assert { type: 'json' };
import MetadataRegistryABI from './MetadataRegistry.json' assert { type: 'json' };

export {
  EventFactoryABI,
  MarketplaceABI,
  EventManagerABI,
  QRVerificationABI,
  TicketNFTABI,
  POAPABI,
  EventBadgeABI,
  MetadataRegistryABI
};

// Extract just the ABI arrays for direct use
export const EventFactory = EventFactoryABI.abi;
export const Marketplace = MarketplaceABI.abi;
export const EventManager = EventManagerABI.abi;
export const QRVerification = QRVerificationABI.abi;
export const TicketNFT = TicketNFTABI.abi;
export const POAP = POAPABI.abi;
export const EventBadge = EventBadgeABI.abi;
export const MetadataRegistry = MetadataRegistryABI.abi;
