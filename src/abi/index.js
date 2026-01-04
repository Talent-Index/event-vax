import EventFactoryABI from './EventFactory.json';
import MarketplaceABI from './Marketplace.json';
import EventManagerABI from './EventManager.json';
import QRVerificationABI from './QRVerificationSystem.json';
import TicketNFTABI from './TicketNFT.json';
import POAPABI from './POAP.json';
import EventBadgeABI from './EventBadge.json';
import MetadataRegistryABI from './MetadataRegistry.json';

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
