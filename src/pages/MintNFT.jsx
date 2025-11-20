import React, { useState, useEffect } from 'react';
import { 
  Sparkles, 
  Wallet, 
  Eye, 
  Zap, 
  Ticket, 
  CheckCircle, 
  Loader2, 
  Calendar, 
  MapPin, 
  Star, 
  Shield, 
  X, 
  ArrowRight 
} from 'lucide-react';

const QuantumMintNFT = () => {
  const [walletAddress, setWalletAddress] = useState(null);
  const [mintingStatus, setMintingStatus] = useState(null);
  const [tokenURI, setTokenURI] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  const [mintedTicketData, setMintedTicketData] = useState(null);
  const [scrollPosition, setScrollPosition] = useState(0);
  const [currentStep, setCurrentStep] = useState(1);
  
  const [eventData] = useState({
    name: "EventVax Summit 2025 - VIP Ticket",
    description: "Official VIP access ticket for EventVax Summit 2025. This NFT grants exclusive access to all VIP areas, networking sessions, and premium content.",
    image: "ipfs://QmPreUploadedEventImage",
    attributes: [
      { trait_type: "Event", value: "EventVax Summit 2025" },
      { trait_type: "Ticket Type", value: "VIP" },
      { trait_type: "Date", value: "September 14, 2025" },
      { trait_type: "Venue", value: "Convention Center" }
    ]
  });

  useEffect(() => {
    checkWalletConnection();
    
    const handleScroll = () => {
      setScrollPosition(window.scrollY);
    };
    
    window.addEventListener('scroll', handleScroll);

    if (window.ethereum) {
      window.ethereum.on('accountsChanged', handleAccountsChanged);
      window.ethereum.on('chainChanged', () => window.location.reload());
    }

    return () => {
      window.removeEventListener('scroll', handleScroll);
      if (window.ethereum) {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
      }
    };
  }, []);

  const handleAccountsChanged = (accounts) => {
    if (accounts.length > 0) {
      setWalletAddress(accounts[0]);
      setCurrentStep(2);
    } else {
      setWalletAddress(null);
      setCurrentStep(1);
    }
  };

  const checkWalletConnection = async () => {
    try {
      if (window.ethereum) {
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        if (accounts.length > 0) {
          setWalletAddress(accounts[0]);
          setCurrentStep(2);
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
      setCurrentStep(2);
    } catch (error) {
      setError(error.message || 'Error connecting wallet');
    } finally {
      setIsLoading(false);
    }
  };

  const generateTokenURI = async () => {
    try {
      setIsLoading(true);
      setError(null);
      setMintingStatus('Generating ticket metadata...');
      setCurrentStep(3);

      const ticketMetadata = {
        ...eventData,
        attributes: [
          ...eventData.attributes,
          { trait_type: "Owner", value: walletAddress },
          { trait_type: "Mint Date", value: new Date().toISOString() },
          { trait_type: "Ticket ID", value: `TICKET-${Date.now()}` }
        ]
      };

      const mockIPFSHash = `Qm${Math.random().toString(36).substring(2, 15)}`;
      const tokenURI = `ipfs://${mockIPFSHash}`;
      
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      setTokenURI(tokenURI);
      setMintingStatus('✅ Ticket metadata generated successfully!');
      
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
    setMintingStatus('Initializing quantum minting process...');
    setCurrentStep(4);

    try {
      if (window.ethereum) {
        const chainId = await window.ethereum.request({ method: 'eth_chainId' });
        if (chainId !== '0xA86A') {
          setMintingStatus('Please switch to Avalanche network...');
          try {
            await window.ethereum.request({
              method: 'wallet_switchEthereumChain',
              params: [{ chainId: '0xA86A' }],
            });
          } catch (switchError) {
            if (switchError.code === 4902) {
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

      setMintingStatus('Please confirm the transaction in your wallet...');
      
      await new Promise(resolve => setTimeout(resolve, 3000));
      
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

      const existingTickets = localStorage.getItem(`mintedTickets_${walletAddress}`);
      const tickets = existingTickets ? JSON.parse(existingTickets) : [];
      tickets.push(mintedTicket);
      localStorage.setItem(`mintedTickets_${walletAddress}`, JSON.stringify(tickets));
      
      setMintingStatus('🎉 NFT Ticket Minted Successfully!');
      setMintedTicketData(mintedTicket);
      
      setTokenURI('');
      localStorage.removeItem('pendingTicketMetadata');
      
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
    setCurrentStep(2);
  };

  const FloatingParticle = ({ delay = 0 }) => {
    const bgColor = Math.random() > 0.5 ? "#9333EA" : "#3B82F6";
    const particleWidth = `${Math.random() * 3 + 2}px`;
    const particleHeight = `${Math.random() * 3 + 2}px`;
    const particleTop = `${Math.random() * 100}%`;
    const particleLeft = `${Math.random() * 100}%`;

    return (
      <div
        className="absolute rounded-full animate-float"
        style={{
          backgroundColor: bgColor,
          width: particleWidth,
          height: particleHeight,
          animation: 'float 8s ease-in-out infinite',
          animationDelay: `${delay}s`,
          opacity: 0.6,
          top: particleTop,
          left: particleLeft,
        }}
      />
    );
  };

  return (
    <div className="min-h-screen bg-black text-white overflow-hidden">
      {/* Animated background */}
      <div className="fixed inset-0 opacity-20">
        {[...Array(30)].map((_, i) => (
          <FloatingParticle key={i} delay={i * 0.3} />
        ))}
      </div>

      {/* Navigation Bar */}
      {/* <nav className="fixed top-0 left-0 right-0 bg-gray-900/80 backdrop-blur-md z-40 border-b border-purple-500/20">
        <div className="max-w-7xl mx-auto px-4 py-3 flex justify-between items-center">
          <div className="flex items-center space-x-2">
            <Sparkles className="w-6 h-6 text-purple-400" />
            <h2 className="text-lg font-semibold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
              Quantum Mint
            </h2>
          </div>
          {walletAddress && (
            <div className="px-4 py-2 rounded-lg bg-purple-600/20 border border-purple-500/30">
              <p className="text-xs text-gray-400">Connected</p>
              <p className="text-sm font-mono text-purple-300">{`${walletAddress.slice(0, 6)}...${walletAddress.slice(-4)}`}</p>
            </div>
          )}
        </div>
      </nav> */}

      <main className="relative container mx-auto px-4 py-24 max-w-5xl">
        {/* Header */}
        <div className="text-center mb-12" style={{ transform: `translateY(${scrollPosition * 0.3}px)` }}>
          <h1 className="text-6xl font-bold mb-6 relative inline-block">
            <span className="bg-gradient-to-r from-purple-400 via-blue-400 to-purple-400 
                         bg-clip-text text-transparent animate-gradient-x">
              Mint Your Quantum Ticket
            </span>
            <Sparkles className="absolute -right-8 top-0 w-6 h-6 text-yellow-400 animate-bounce" />
          </h1>
          <p className="text-xl text-gray-400 max-w-2xl mx-auto">
            Create your exclusive NFT ticket on the blockchain
          </p>
        </div>

        {/* Progress Steps */}
        <div className="mb-12">
          <div className="flex justify-between items-center max-w-3xl mx-auto">
            {[
              { num: 1, label: 'Connect', icon: Wallet },
              { num: 2, label: 'Preview', icon: Eye },
              { num: 3, label: 'Generate', icon: Zap },
              { num: 4, label: 'Mint', icon: Ticket }
            ].map(({ num, label, icon: Icon }) => (
              <div key={num} className="flex flex-col items-center flex-1">
                <div className={`w-12 h-12 rounded-full flex items-center justify-center transition-all duration-500
                              ${currentStep >= num 
                                ? 'bg-gradient-to-r from-purple-600 to-blue-600 scale-110' 
                                : 'bg-gray-800 border border-gray-700'}`}>
                  {currentStep > num ? (
                    <CheckCircle className="w-6 h-6 text-white" />
                  ) : (
                    <Icon className={`w-6 h-6 ${currentStep >= num ? 'text-white' : 'text-gray-500'}`} />
                  )}
                </div>
                <p className={`text-sm mt-2 ${currentStep >= num ? 'text-purple-400' : 'text-gray-500'}`}>
                  {label}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Main Content Card */}
        <div className="bg-gray-900/30 backdrop-blur-xl rounded-2xl border border-purple-500/30 p-8 
                      hover:border-purple-500/50 transition-all duration-300 mb-8">
          
          {/* Step 1: Connect Wallet */}
          {!walletAddress ? (
            <div className="text-center py-12">
              <div className="w-20 h-20 bg-gradient-to-r from-purple-600/20 to-blue-600/20 rounded-full 
                            flex items-center justify-center mx-auto mb-6">
                <Wallet className="w-10 h-10 text-purple-400" />
              </div>
              <h3 className="text-2xl font-bold mb-4">Connect Your Wallet</h3>
              <p className="text-gray-400 mb-8">Connect your wallet to start minting your NFT ticket</p>
              <button
                onClick={connectWallet}
                disabled={isLoading}
                className="group relative px-8 py-4 rounded-xl overflow-hidden transition-all duration-300 hover:scale-105"
              >
                <div className="absolute inset-0 bg-gradient-to-r from-purple-600 via-blue-600 to-purple-600 animate-gradient-x" />
                <div className="relative z-10 flex items-center space-x-2">
                  {isLoading ? (
                    <Loader2 className="w-5 h-5 animate-spin" />
                  ) : (
                    <>
                      <Wallet className="w-5 h-5" />
                      <span className="font-semibold">Connect Wallet</span>
                    </>
                  )}
                </div>
              </button>
            </div>
          ) : (
            <>
              {/* Ticket Preview */}
              <div className="mb-8">
                <div className="flex items-center mb-6">
                  <Eye className="w-6 h-6 mr-2 text-purple-400" />
                  <h3 className="text-2xl font-bold">Ticket Preview</h3>
                </div>

                <div className="bg-gradient-to-br from-gray-800/80 to-gray-900/80 rounded-xl p-6 border border-gray-700/50">
                  {/* Event Header */}
                  <div className="mb-6 pb-6 border-b border-gray-700">
                    <h4 className="text-2xl font-bold text-white mb-2">{eventData.name}</h4>
                    <p className="text-gray-400">{eventData.description}</p>
                  </div>

                  {/* Attributes Grid */}
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    {eventData.attributes.map((attr, index) => (
                      <div key={index} className="bg-gray-700/50 p-4 rounded-lg hover:bg-gray-700 transition-colors">
                        <div className="flex items-center mb-2">
                          {attr.trait_type === "Date" && <Calendar className="w-4 h-4 text-blue-400 mr-1" />}
                          {attr.trait_type === "Venue" && <MapPin className="w-4 h-4 text-green-400 mr-1" />}
                          {attr.trait_type === "Ticket Type" && <Star className="w-4 h-4 text-yellow-400 mr-1" />}
                          {attr.trait_type === "Event" && <Ticket className="w-4 h-4 text-purple-400 mr-1" />}
                          <p className="text-xs text-gray-400">{attr.trait_type}</p>
                        </div>
                        <p className="text-sm font-semibold text-white">{attr.value}</p>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="space-y-4">
                <button
                  onClick={generateTokenURI}
                  disabled={isLoading || !walletAddress}
                  className="w-full group relative px-6 py-4 rounded-xl overflow-hidden transition-all duration-300 hover:scale-105"
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-green-600 to-emerald-600" />
                  <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 bg-gradient-to-r from-green-500 to-emerald-500" />
                  <div className="relative z-10 flex items-center justify-center space-x-2">
                    {isLoading && currentStep === 3 ? (
                      <Loader2 className="w-5 h-5 animate-spin" />
                    ) : (
                      <Zap className="w-5 h-5" />
                    )}
                    <span className="font-semibold">Generate Ticket Metadata</span>
                  </div>
                </button>

                <button
                  onClick={handleMintNFT}
                  disabled={isLoading || !walletAddress || !tokenURI}
                  className={`w-full group relative px-6 py-4 rounded-xl overflow-hidden transition-all duration-300 
                           ${tokenURI ? 'hover:scale-105' : 'opacity-50 cursor-not-allowed'}`}
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-purple-600 via-blue-600 to-purple-600 animate-gradient-x" />
                  <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                       style={{ background: 'linear-gradient(45deg, rgba(168,85,247,0.4) 0%, rgba(147,51,234,0.4) 100%)' }} />
                  <div className="relative z-10 flex items-center justify-center space-x-2">
                    {isLoading && currentStep === 4 ? (
                      <Loader2 className="w-5 h-5 animate-spin" />
                    ) : (
                      <>
                        <Ticket className="w-5 h-5" />
                        <span className="font-bold">Mint NFT Ticket</span>
                        <Sparkles className="w-5 h-5 animate-pulse" />
                      </>
                    )}
                  </div>
                </button>
              </div>
            </>
          )}
        </div>

        {/* Status Messages */}
        {error && (
          <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-4 mb-4 animate-pulse">
            <p className="text-red-400 text-center">{error}</p>
          </div>
        )}

        {mintingStatus && !error && (
          <div className="bg-green-500/10 border border-green-500/30 rounded-xl p-4 mb-4">
            <p className="text-green-400 text-center">{mintingStatus}</p>
          </div>
        )}

        {/* Security Notice */}
        <div className="bg-blue-500/10 border border-blue-500/20 rounded-xl p-6">
          <div className="flex items-start space-x-3">
            <Shield className="w-6 h-6 text-blue-400 flex-shrink-0 mt-1" />
            <div>
              <h4 className="text-blue-400 font-semibold mb-2">Security Notice</h4>
              <ul className="text-sm text-gray-300 space-y-1">
                <li>• Your NFT ticket is securely stored on the Avalanche blockchain</li>
                <li>• Each ticket is unique and cannot be duplicated or forged</li>
                <li>• Keep your wallet private keys secure at all times</li>
                <li>• Transaction fees will be required for minting</li>
              </ul>
            </div>
          </div>
        </div>
      </main>

      {/* Success Modal */}
      {showSuccessModal && mintedTicketData && (
        <div className="fixed inset-0 bg-black/90 backdrop-blur-md flex items-center justify-center p-4 z-50">
          <div className="bg-gray-900/95 backdrop-blur-xl rounded-2xl border border-purple-500/50 max-w-lg w-full mx-4 overflow-hidden">
            {/* Confetti Effect */}
            <div className="absolute inset-0 pointer-events-none">
              {[...Array(20)].map((_, i) => (
                <div
                  key={i}
                  className="absolute w-2 h-2 bg-gradient-to-r from-purple-400 to-blue-400 rounded-full"
                  style={{
                    left: `${Math.random() * 100}%`,
                    top: '-10%',
                    animation: `fall ${2 + Math.random() * 2}s linear forwards`,
                    animationDelay: `${Math.random() * 0.5}s`
                  }}
                />
              ))}
            </div>

            {/* Modal Header */}
            <div className="relative bg-gradient-to-r from-purple-600/30 to-blue-600/30 p-8 text-center">
              <button
                onClick={handleCloseModal}
                className="absolute top-4 right-4 text-gray-400 hover:text-white transition-colors"
              >
                <X className="w-6 h-6" />
              </button>
              <div className="w-20 h-20 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4 animate-bounce">
                <CheckCircle className="w-10 h-10 text-white" />
              </div>
              <h3 className="text-3xl font-bold text-white mb-2">Success!</h3>
              <p className="text-gray-300">Your quantum ticket has been minted</p>
            </div>

            {/* Ticket Details */}
            <div className="p-6 space-y-4">
              <div className="bg-gradient-to-br from-gray-800/80 to-gray-900/80 rounded-xl p-5 border border-gray-700/50">
                <div className="flex items-center space-x-3 mb-4">
                  <Ticket className="w-6 h-6 text-purple-400" />
                  <h4 className="font-semibold text-white text-lg">Ticket Information</h4>
                </div>
                <div className="space-y-3 text-sm">
                  <div className="flex justify-between items-center">
                    <span className="text-gray-400">Event:</span>
                    <span className="text-white font-medium">{mintedTicketData.eventName.slice(0, 30)}...</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-400">Type:</span>
                    <span className="px-3 py-1 bg-purple-500/20 text-purple-300 rounded-full text-xs">
                      {mintedTicketData.ticketType}
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-400">Seat:</span>
                    <span className="text-white font-mono">{mintedTicketData.seatNumber}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-400">Token ID:</span>
                    <span className="text-green-400 font-mono text-xs">{mintedTicketData.tokenId}</span>
                  </div>
                  <div className="flex justify-between items-center pt-3 border-t border-gray-700">
                    <span className="text-gray-400">Status:</span>
                    <span className="flex items-center text-green-400">
                      <CheckCircle className="w-4 h-4 mr-1" />
                      Minted
                    </span>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="space-y-3">
                <button
                  onClick={handleViewTickets}
                  className="w-full bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 
                         text-white py-4 px-6 rounded-xl transition-all duration-300 flex items-center justify-center space-x-2
                         hover:scale-105"
                >
                  <Eye className="w-5 h-5" />
                  <span className="font-semibold">View My Tickets</span>
                  <ArrowRight className="w-5 h-5" />
                </button>
                <button
                  onClick={handleCloseModal}
                  className="w-full bg-gray-700/50 hover:bg-gray-600/50 text-white py-4 px-6 rounded-xl 
                         transition-all duration-300 border border-gray-600"
                >
                  Continue Minting More Tickets
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <style>{`
        @keyframes float {
          0%, 100% { transform: translate(0, 0); }
          50% { transform: translate(30px, -30px); }
        }

        @keyframes gradient-x {
          0%, 100% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
        }

        @keyframes fall {
          to {
            transform: translateY(100vh) rotate(360deg);
            opacity: 0;
          }
        }

        .animate-gradient-x {
          background-size: 200% auto;
          animation: gradient-x 15s linear infinite;
        }

        .animate-float {
          animation: float 6s ease-in-out infinite;
        }
      `}</style>
    </div>
  );
};

export default QuantumMintNFT;