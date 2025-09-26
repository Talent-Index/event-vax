import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import contractABI from "../abi/Ticket.json";
import { Loader2, Upload, Image, CheckCircle, X, Eye, Ticket } from 'lucide-react';


const contractAddress = '0x256ff3b9d3df415a05ba42beb5f186c28e103b2a'; // Replace with your NFT contract address

const MintNFT = () => {
  const [walletAddress, setWalletAddress] = useState(null);
  const [mintingStatus, setMintingStatus] = useState(null);
  const [tokenURI, setTokenURI] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  const [mintedTicketData, setMintedTicketData] = useState(null);

  // Add new state for metadata
  const [metadata, setMetadata] = useState({
    name: '',
    description: '',
    image: '',
    attributes: []
  });
  const [uploadingToIPFS, setUploadingToIPFS] = useState(false);

  // Pre-defined metadata based on event
  const [eventData] = useState({
    name: "EventVax Summit 2025 - VIP Ticket",
    description: "Official VIP access ticket for EventVax Summit 2025. This NFT grants exclusive access to all VIP areas, networking sessions, and premium content.",
    image: "ipfs://QmPreUploadedEventImage", // Pre-uploaded event image
    attributes: [
      { trait_type: "Event", value: "EventVax Summit 2025" },
      { trait_type: "Ticket Type", value: "VIP" },
      { trait_type: "Date", value: "September 14, 2025" },
      { trait_type: "Venue", value: "Convention Center" }
    ]
  });

  useEffect(() => {
    checkWalletConnection();
    
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', handleAccountsChanged);
      window.ethereum.on('chainChanged', () => window.location.reload());
    }

    return () => {
      if (window.ethereum) {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
      }
    };
  }, []);

  const handleAccountsChanged = (accounts) => {
    if (accounts.length > 0) {
      setWalletAddress(accounts[0]);
    } else {
      setWalletAddress(null);
    }
  };

  const checkWalletConnection = async () => {
    try {
      if (window.ethereum) {
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        if (accounts.length > 0) {
          setWalletAddress(accounts[0]);
        }
      }
    } catch (error) {
      console.error('Error checking wallet connection:', error);
    }
  };

  const connectWallet = async () => {
    setError(null);
    setIsLoading(true);
    
    try {
      if (!window.ethereum) {
        throw new Error('Please install MetaMask to connect your wallet');
      }

      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts'
      });
      
      setWalletAddress(accounts[0]);
    } catch (error) {
      setError(error.message || 'Error connecting wallet');
    } finally {
      setIsLoading(false);
    }
  };

  const uploadToIPFS = async (file) => {
    try {
      setUploadingToIPFS(true);
      
      // Using Pinata (you'll need to sign up for API keys)
      const formData = new FormData();
      formData.append('file', file);
      
      const response = await fetch('https://api.pinata.cloud/pinning/pinFileToIPFS', {
        method: 'POST',
        headers: {
          'pinata_api_key': process.env.REACT_APP_PINATA_API_KEY,
          'pinata_secret_api_key': process.env.REACT_APP_PINATA_SECRET_KEY,
        },
        body: formData,
      });
      
      const result = await response.json();
      return `ipfs://${result.IpfsHash}`;
    } catch (error) {
      console.error('Error uploading to IPFS:', error);
      throw new Error('Failed to upload image to IPFS');
    } finally {
      setUploadingToIPFS(false);
    }
  };

  const uploadMetadataToIPFS = async (metadata) => {
    try {
      const response = await fetch('https://api.pinata.cloud/pinning/pinJSONToIPFS', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'pinata_api_key': process.env.REACT_APP_PINATA_API_KEY,
          'pinata_secret_api_key': process.env.REACT_APP_PINATA_SECRET_KEY,
        },
        body: JSON.stringify(metadata),
      });
      
      const result = await response.json();
      return `ipfs://${result.IpfsHash}`;
    } catch (error) {
      console.error('Error uploading metadata to IPFS:', error);
      throw new Error('Failed to upload metadata to IPFS');
    }
  };

  const handleImageUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    try {
      const imageURI = await uploadToIPFS(file);
      setMetadata(prev => ({ ...prev, image: imageURI }));
    } catch (error) {
      setError(error.message);
    }
  };

  const generateTokenURI = async () => {
    try {
      setIsLoading(true);
      setError(null);
      setMintingStatus('Generating ticket metadata...');

      // Create metadata with user-specific information
      const ticketMetadata = {
        ...eventData,
        attributes: [
          ...eventData.attributes,
          { trait_type: "Owner", value: walletAddress },
          { trait_type: "Mint Date", value: new Date().toISOString() },
          { trait_type: "Ticket ID", value: `TICKET-${Date.now()}` }
        ]
      };

      // For demo purposes, create a mock IPFS URI
      // In production, you would upload to actual IPFS
      const mockIPFSHash = `Qm${Math.random().toString(36).substring(2, 15)}`;
      const tokenURI = `ipfs://${mockIPFSHash}`;
      
      // Simulate IPFS upload delay
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      setTokenURI(tokenURI);
      setMintingStatus('✅ Ticket metadata generated successfully!');
      
      // Store metadata locally for minting
      localStorage.setItem('pendingTicketMetadata', JSON.stringify(ticketMetadata));
      
    } catch (error) {
      console.error("Error generating token URI:", error);
      setError("Failed to generate ticket metadata. Please try again.");
      setMintingStatus(null);
    } finally {
      setIsLoading(false);
    }
  };

  const handleMintNFT = async () => {
    if (!walletAddress) {
      setError('Please connect your wallet first');
      return;
    }

    if (!tokenURI.trim()) {
      setError('Please generate ticket metadata first');
      return;
    }

    setError(null);
    setIsLoading(true);
    setMintingStatus('Initializing minting process...');

    try {
      // Check if we're on the correct network
      if (window.ethereum) {
        const chainId = await window.ethereum.request({ method: 'eth_chainId' });
        if (chainId !== '0xA86A') { // Avalanche mainnet
          setMintingStatus('Please switch to Avalanche network...');
          try {
            await window.ethereum.request({
              method: 'wallet_switchEthereumChain',
              params: [{ chainId: '0xA86A' }],
            });
          } catch (switchError) {
            if (switchError.code === 4902) {
              // Network not added, add it
              await window.ethereum.request({
                method: 'wallet_addEthereumChain',
                params: [{
                  chainId: '0xA86A',
                  chainName: 'Avalanche Mainnet C-Chain',
                  nativeCurrency: {
                    name: 'Avalanche',
                    symbol: 'AVAX',
                    decimals: 18
                  },
                  rpcUrls: ['https://api.avax.network/ext/bc/C/rpc'],
                  blockExplorerUrls: ['https://snowtrace.io/']
                }]
              });
            }
          }
        }
      }

      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      
      // For demo purposes, simulate minting process
      setMintingStatus('Please confirm the transaction in your wallet...');
      
      // Simulate transaction confirmation
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Save minted ticket to localStorage for the Ticket page
      const mintedTicket = {
        eventName: eventData.name,
        eventDate: eventData.attributes.find(attr => attr.trait_type === "Date")?.value || "March 15, 2025",
        eventTime: "2:00 PM - 10:00 PM",
        venue: eventData.attributes.find(attr => attr.trait_type === "Venue")?.value || "Convention Center",
        address: "123 Convention Ave, New York, NY 10001",
        ticketType: eventData.attributes.find(attr => attr.trait_type === "Ticket Type")?.value || "VIP Access",
        seatNumber: `VIP-${Math.floor(Math.random() * 1000)}`,
        price: "0.08 AVAX",
        qrCode: `QR${Math.random().toString(36).substring(2, 15)}`,
        status: "Valid",
        description: eventData.description,
        mintDate: new Date().toISOString(),
        tokenURI: tokenURI,
        tokenId: `TICKET-${Date.now()}`
      };

      // Get existing minted tickets for this wallet
      const existingTickets = localStorage.getItem(`mintedTickets_${walletAddress}`);
      const tickets = existingTickets ? JSON.parse(existingTickets) : [];
      tickets.push(mintedTicket);
      localStorage.setItem(`mintedTickets_${walletAddress}`, JSON.stringify(tickets));
      
      setMintingStatus('🎉 NFT Ticket Minted Successfully!');
      setMintedTicketData(mintedTicket);
      
      // Clear form
      setTokenURI('');
      localStorage.removeItem('pendingTicketMetadata');
      
      // Show success modal instead of browser popup
      setTimeout(() => {
        setShowSuccessModal(true);
      }, 1000);
      
    } catch (error) {
      console.error('Error minting NFT:', error);
      setError(error.message || 'Error minting NFT. Please try again.');
      setMintingStatus(null);
    } finally {
      setIsLoading(false);
    }
  };

  const handleViewTickets = () => {
    setShowSuccessModal(false);
    window.location.href = '/ticket';
  };

  const handleCloseModal = () => {
    setShowSuccessModal(false);
    setMintedTicketData(null);
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-black text-white flex items-center justify-center p-6">
      <div className="max-w-2xl w-full bg-gray-800/50 backdrop-blur-xl p-8 rounded-2xl shadow-xl border border-gray-700">
        <h2 className="text-4xl font-bold text-center mb-8 bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
          Mint Your Event Ticket
        </h2>

        {!walletAddress ? (
          <div className="text-center mb-8">
            <button
              onClick={connectWallet}
              disabled={isLoading}
              className="relative bg-gradient-to-r from-purple-600 to-blue-600 py-3 px-8 rounded-xl
                hover:opacity-90 transition-all duration-300 disabled:opacity-50"
            >
              {isLoading ? (
                <Loader2 className="w-5 h-5 animate-spin inline" />
              ) : (
                'Connect Wallet'
              )}
            </button>
          </div>
        ) : (
          <div className="mb-6 text-center">
            <div className="inline-block px-4 py-2 rounded-lg bg-gray-700/50 border border-gray-600">
              <p className="text-sm text-gray-300">Connected Wallet</p>
              <p className="text-md font-mono">{`${walletAddress.slice(0, 6)}...${walletAddress.slice(-4)}`}</p>
            </div>
          </div>
        )}

        {/* Preview of what will be minted */}
        <div className="mb-8 bg-gray-700/30 p-6 rounded-xl border border-gray-600">
          <h3 className="text-xl font-semibold text-gray-200 mb-4">Ticket Preview</h3>
          <div className="space-y-2">
            <p><span className="text-gray-400">Name:</span> {eventData.name}</p>
            <p><span className="text-gray-400">Description:</span> {eventData.description}</p>
            <div className="grid grid-cols-2 gap-2 mt-4">
              {eventData.attributes.map((attr, index) => (
                <div key={index} className="bg-gray-600/50 p-2 rounded">
                  <p className="text-xs text-gray-400">{attr.trait_type}</p>
                  <p className="text-sm font-medium">{attr.value}</p>
                </div>
              ))}
            </div>
          </div>
        </div>

        <button
          onClick={generateTokenURI}
          disabled={isLoading || !walletAddress}
          className="w-full bg-gradient-to-r from-green-600 to-emerald-600 py-3 px-6 rounded-xl
            hover:opacity-90 transition-all duration-300 disabled:opacity-50 mb-4"
        >
          {isLoading ? <Loader2 className="w-5 h-5 animate-spin inline mr-2" /> : null}
          Generate Ticket
        </button>

        <div className="text-center">
          <button
            onClick={handleMintNFT}
            disabled={isLoading || !walletAddress}
            className="relative bg-gradient-to-r from-purple-600 to-blue-600 py-3 px-8 rounded-xl
              hover:opacity-90 transition-all duration-300 disabled:opacity-50"
          >
            {isLoading ? (
              <Loader2 className="w-5 h-5 animate-spin inline" />
            ) : (
              'Mint NFT'
            )}
          </button>
        </div>

        {error && (
          <div className="mt-6 text-center">
            <p className="text-red-400 bg-red-400/10 px-4 py-2 rounded-lg">{error}</p>
          </div>
        )}

        {mintingStatus && (
          <div className="mt-6 text-center">
            <p className="text-green-400 bg-green-400/10 px-4 py-2 rounded-lg">{mintingStatus}</p>
          </div>
        )}
      </div>

      {/* Success Modal */}
      {showSuccessModal && mintedTicketData && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-gray-800/95 backdrop-blur-xl rounded-2xl border border-purple-500/30 max-w-md w-full mx-4 overflow-hidden">
            {/* Modal Header */}
            <div className="relative bg-gradient-to-r from-purple-600/20 to-blue-600/20 p-6 text-center">
              <button
                onClick={handleCloseModal}
                className="absolute top-4 right-4 text-gray-400 hover:text-white transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
              <div className="w-16 h-16 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-2xl font-bold text-white mb-2">Ticket Minted Successfully!</h3>
              <p className="text-gray-300">Your NFT ticket has been created and saved to your wallet.</p>
            </div>

            {/* Ticket Preview */}
            <div className="p-6">
              <div className="bg-gray-700/50 rounded-xl p-4 mb-6">
                <div className="flex items-center space-x-3 mb-3">
                  <Ticket className="w-5 h-5 text-purple-400" />
                  <h4 className="font-semibold text-white">Ticket Details</h4>
                </div>
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-gray-400">Event:</span>
                    <span className="text-white">{mintedTicketData.eventName}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-400">Type:</span>
                    <span className="text-purple-400">{mintedTicketData.ticketType}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-400">Seat:</span>
                    <span className="text-white">{mintedTicketData.seatNumber}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-400">Token ID:</span>
                    <span className="text-green-400 font-mono text-xs">{mintedTicketData.tokenId}</span>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="space-y-3">
                <button
                  onClick={handleViewTickets}
                  className="w-full bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 text-white py-3 px-6 rounded-xl transition-colors duration-300 flex items-center justify-center space-x-2"
                >
                  <Eye className="w-5 h-5" />
                  <span>View My Tickets</span>
                </button>
                <button
                  onClick={handleCloseModal}
                  className="w-full bg-gray-600 hover:bg-gray-500 text-white py-3 px-6 rounded-xl transition-colors duration-300"
                >
                  Continue Minting
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default MintNFT;
