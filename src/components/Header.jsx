import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Power, User } from 'lucide-react';
import { ethers } from 'ethers';

// Avalanche Network Configuration
const AVALANCHE_MAINNET_PARAMS = {
  chainId: '0xA86A',
  chainName: 'Avalanche Mainnet',
  nativeCurrency: {
    name: 'AVAX',
    symbol: 'AVAX',
    decimals: 18
  },
  rpcUrls: ['https://api.avax.network/ext/bc/C/rpc'],
  blockExplorerUrls: ['https://snowtrace.io/']
};

const Header = () => {
  const [walletAddress, setWalletAddress] = useState(null);
  const [isConnecting, setIsConnecting] = useState(false);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
    checkWalletConnection();
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', handleAccountsChanged);
      window.ethereum.on('disconnect', handleDisconnect);
    }
    return () => {
      if (window.ethereum) {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
        window.ethereum.removeListener('disconnect', handleDisconnect);
      }
    };
    // eslint-disable-next-line
  }, []);

  const checkWalletConnection = async () => {
    if (typeof window.ethereum !== "undefined") {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        if (accounts.length > 0) {
          setWalletAddress(accounts[0]);
        }
      } catch (error) {
        console.error("Error checking wallet connection:", error);
      }
    }
  };

  const handleAccountsChanged = (accounts) => {
    if (accounts.length > 0) {
      setWalletAddress(accounts[0]);
    } else {
      setWalletAddress(null);
    }
  };

  const handleDisconnect = () => {
    setWalletAddress(null);
  };

  const connectWallet = async () => {
    if (typeof window.ethereum === "undefined") {
      alert("Please install MetaMask to connect your wallet!");
      return;
    }
    setIsConnecting(true);
    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts'
      });
      if (accounts.length > 0) {
        const signer = await provider.getSigner();
        const address = await signer.getAddress();
        setWalletAddress(address);
        console.log("Connected Address:", address);
      }
    } catch (error) {
      console.error("Error connecting to wallet:", error);
    } finally {
      setIsConnecting(false);
    }
  };

  const disconnectWallet = () => {
    setWalletAddress(null);
  };

  return (
    <nav className={`fixed top-0 w-full z-50 transition-all duration-500 \
      ${isVisible ? 'translate-y-0 opacity-100' : '-translate-y-full opacity-0'}`}>
      <div className="relative">
        <div className="absolute inset-0 bg-black/20 backdrop-blur-sm" />
        <div className="relative max-w-6xl mx-auto py-2">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2 group cursor-pointer">
              <div className="relative w-8 h-8">
                <div className="absolute inset-0 bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg" />
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="text-sm font-bold text-white">E</span>
                </div>
              </div>
              <span className="text-lg font-semibold bg-clip-text text-transparent bg-gradient-to-r \
                from-purple-400 to-blue-400">EventVerse</span>
            </div>
            <div className="flex items-center space-x-4">
              {[
                { name: 'Home', path: '/' },
                { name: 'List', path: '/waiting' },
                { name: 'Mint', path: '/mint' },
              ].map(({ name, path }) => (
                <Link
                  key={name}
                  to={path}
                  className="relative group py-1"
                >
                  <span className="text-sm text-gray-300 group-hover:text-white transition-colors">
                    {name}
                  </span>
                  <span className="absolute bottom-0 left-1/2 w-0 h-0.5 bg-gradient-to-r from-purple-500 to-blue-500 \
                    group-hover:w-full group-hover:left-0 transition-all duration-200" />
                </Link>
              ))}
              {walletAddress && (
                <Link
                  to="/profile"
                  className="relative group py-1"
                >
                  <div className="flex items-center space-x-1">
                    <User className="w-4 h-4 text-gray-300 group-hover:text-white transition-colors" />
                    <span className="text-sm text-gray-300 group-hover:text-white transition-colors">
                      Profile
                    </span>
                  </div>
                  <span className="absolute bottom-0 left-1/2 w-0 h-0.5 bg-gradient-to-r from-purple-500 to-blue-500 \
                    group-hover:w-full group-hover:left-0 transition-all duration-200" />
                </Link>
              )}
              <button
                onClick={walletAddress ? disconnectWallet : connectWallet}
                disabled={isConnecting}
                className="relative px-4 py-2 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 \
                  hover:from-purple-500 hover:to-blue-500 transition-all text-sm"
              >
                <div className="flex items-center gap-1">
                  {isConnecting ? (
                    'Connecting...'
                  ) : walletAddress ? (
                    <>
                      <span>{`${walletAddress.slice(0, 4)}...${walletAddress.slice(-3)}`}</span>
                      <Power className="w-3 h-3" />
                    </>
                  ) : (
                    'Connect'
                  )}
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Header;
