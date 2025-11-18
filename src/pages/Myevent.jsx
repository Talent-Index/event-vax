import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { Calendar, MapPin, Ticket, Sparkles, Wallet, Plus, DollarSign, Users, Clock, Star, Zap } from "lucide-react";

const QuantumEventCreator = () => {
  const [isLoading, setIsLoading] = useState(true);
  const [scrollPosition, setScrollPosition] = useState(0);
  const [formData, setFormData] = useState({
    eventName: '',
    eventDate: '',
    venue: '',
    regularPrice: '',
    vipPrice: '',
    vvipPrice: '',
    description: ''
  });
  const [focusedField, setFocusedField] = useState(null);

  useEffect(() => {
    setTimeout(() => setIsLoading(false), 1500);
  }, []);

  useEffect(() => {
    const handleScroll = () => {
      setScrollPosition(window.scrollY);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Event Created:', formData);
    // Handle event creation logic here
  };

  const FloatingParticle = ({ delay = 0 }) => (
    <div
      className="absolute rounded-full animate-float"
      style={{
        backgroundColor: Math.random() > 0.5 ? "#9333EA" : "#3B82F6",
        width: `${Math.random() * 3 + 2}px`,
        height: `${Math.random() * 3 + 2}px`,
        animation: `float 8s infinite ${delay}s ease-in-out`,
        opacity: 0.6,
        top: `${Math.random() * 100}%`,
        left: `${Math.random() * 100}%`,
      }}
    />
  );
  const PriceCard = ({ tier, icon: Icon, price, color, features }) => (
    <div className={`relative overflow-hidden rounded-xl p-6 transition-all duration-500 hover:scale-105
                    bg-gradient-to-br from-gray-900/80 to-gray-800/80 backdrop-blur-lg
                    border-2 ${color} hover:shadow-lg hover:shadow-${color}/20`}>
      <div className={`absolute inset-0 bg-gradient-to-r ${color.replace('border', 'from')}/10 to-transparent
                      opacity-0 hover:opacity-100 transition-opacity duration-500`} />
      
      <div className="relative z-10">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-2">
            <Icon className={`w-6 h-6 ${color.replace('border', 'text')}`} />
            <h3 className="text-xl font-bold text-white">{tier}</h3>
          </div>
          {tier === "VVIP" && (
            <Star className="w-5 h-5 text-yellow-400 animate-pulse" />
          )}
        </div>
        
        <input
          type="number"
          name={`${tier.toLowerCase()}Price`}
          value={price}
          onChange={handleInputChange}
          onFocus={() => setFocusedField(`${tier}Price`)}
          onBlur={() => setFocusedField(null)}
          placeholder="0.00"
          className={`w-full bg-gray-800/50 border ${
            focusedField === `${tier}Price` ? color : 'border-gray-700'
          } rounded-lg px-4 py-3 text-white placeholder-gray-500 focus:outline-none transition-all duration-300`}
        />
        
        <ul className="mt-4 space-y-2 text-sm text-gray-400">
          {features.map((feature, idx) => (
            <li key={idx} className="flex items-start">
              <Zap className={`w-4 h-4 mr-2 mt-0.5 ${color.replace('border', 'text')}`} />
              {feature}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );

  PriceCard.propTypes = {
    tier: PropTypes.string.isRequired,
    icon: PropTypes.elementType.isRequired,
    price: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    color: PropTypes.string,
    features: PropTypes.arrayOf(PropTypes.string)
  };

  return (
    <div className="min-h-screen bg-black text-white overflow-hidden">
      {/* Background effects */}
      <div className="fixed inset-0 opacity-20">
        {[...Array(30)].map((_, i) => (
          <FloatingParticle key={i} delay={i * 0.3} />
        ))}
      </div>

      {/* Loading overlay */}
      <div className={`fixed inset-0 bg-black z-50 transition-opacity duration-1000
                    flex items-center justify-center
                    ${isLoading ? 'opacity-100' : 'opacity-0 pointer-events-none'}`}>
        <div className="flex flex-col items-center">
          <Sparkles className="w-12 h-12 text-purple-500 animate-spin" />
          <p className="mt-4 text-purple-400 animate-pulse">Initializing Event Creator...</p>
        </div>
      </div>

      {/* Navigation Bar */}
      {/* <nav className="fixed top-0 left-0 right-0 bg-gray-900/80 backdrop-blur-md z-40 border-b border-purple-500/20">
        <div className="max-w-7xl mx-auto px-4 py-3 flex justify-between items-center">
          <div className="flex items-center space-x-8">
            <h2 className="text-lg font-semibold bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
              Quantum Events
            </h2>
            <div className="hidden md:flex space-x-4">
              <a href="#" className="text-gray-300 hover:text-white transition-colors">Dashboard</a>
              <a href="#" className="text-gray-300 hover:text-white transition-colors">My Events</a>
              <a href="#" className="text-gray-300 hover:text-white transition-colors">Analytics</a>
            </div>
          </div>
          <button className="px-4 py-2 rounded-lg bg-purple-600/80 hover:bg-purple-500 transition-all duration-300 flex items-center space-x-2 text-sm">
            <Wallet className="w-4 h-4" />
            <span>Connect</span>
          </button>
        </div>
      </nav> */}

      <main className="relative container mx-auto px-4 py-24 max-w-7xl">
        {/* Header section */}
        <div className="text-center mb-16" style={{ transform: `translateY(${scrollPosition * 0.3}px)` }}>
          <h1 className="text-6xl font-bold mb-6 relative inline-block">
            <span className="bg-gradient-to-r from-purple-400 via-blue-400 to-purple-400 
                         bg-clip-text text-transparent animate-gradient-x">
              Create Your Quantum Event
            </span>
            <Sparkles className="absolute -right-8 top-0 w-6 h-6 text-yellow-400 animate-bounce" />
          </h1>
          <p className="text-xl text-gray-400 max-w-2xl mx-auto">
            Transform your vision into reality with blockchain-powered ticketing
          </p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-12">
          <div className="bg-gradient-to-br from-purple-600/20 to-purple-900/20 rounded-xl p-6 backdrop-blur-sm border border-purple-500/30 hover:scale-105 transition-transform duration-300">
            <Users className="w-8 h-8 text-purple-400 mb-2" />
            <p className="text-2xl font-bold text-white">10k+</p>
            <p className="text-sm text-gray-400">Active Users</p>
          </div>
          <div className="bg-gradient-to-br from-blue-600/20 to-blue-900/20 rounded-xl p-6 backdrop-blur-sm border border-blue-500/30 hover:scale-105 transition-transform duration-300">
            <Ticket className="w-8 h-8 text-blue-400 mb-2" />
            <p className="text-2xl font-bold text-white">500+</p>
            <p className="text-sm text-gray-400">Events Created</p>
          </div>
          <div className="bg-gradient-to-br from-green-600/20 to-green-900/20 rounded-xl p-6 backdrop-blur-sm border border-green-500/30 hover:scale-105 transition-transform duration-300">
            <DollarSign className="w-8 h-8 text-green-400 mb-2" />
            <p className="text-2xl font-bold text-white">$2M+</p>
            <p className="text-sm text-gray-400">Total Volume</p>
          </div>
        </div>

        {/* Main Form */}
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Basic Information Card */}
          <div className="bg-gray-900/30 backdrop-blur-xl rounded-2xl border border-purple-500/30 p-8 hover:border-purple-500/50 transition-all duration-300">
            <h2 className="text-2xl font-bold mb-6 flex items-center">
              <Sparkles className="w-6 h-6 mr-2 text-purple-400" />
              Event Details
            </h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              {/* Event Name */}
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Event Name *
                </label>
                <div className="relative">
                  <input
                    type="text"
                    name="eventName"
                    value={formData.eventName}
                    onChange={handleInputChange}
                    onFocus={() => setFocusedField('eventName')}
                    onBlur={() => setFocusedField(null)}
                    placeholder="Enter your event name"
                    className={`w-full bg-gray-800/50 border ${
                      focusedField === 'eventName' ? 'border-purple-500' : 'border-gray-700'
                    } rounded-lg px-4 py-3 text-white placeholder-gray-500 focus:outline-none transition-all duration-300`}
                    required
                  />
                  {focusedField === 'eventName' && (
                    <div className="absolute inset-0 rounded-lg bg-purple-500/10 -z-10 animate-pulse" />
                  )}
                </div>
              </div>

              {/* Event Date */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2 flex items-center">
                  <Calendar className="w-4 h-4 mr-2 text-blue-400" />
                  Event Date *
                </label>
                <input
                  type="datetime-local"
                  name="eventDate"
                  value={formData.eventDate}
                  onChange={handleInputChange}
                  onFocus={() => setFocusedField('eventDate')}
                  onBlur={() => setFocusedField(null)}
                  className={`w-full bg-gray-800/50 border ${
                    focusedField === 'eventDate' ? 'border-blue-500' : 'border-gray-700'
                  } rounded-lg px-4 py-3 text-white focus:outline-none transition-all duration-300`}
                  required
                />
              </div>

              {/* Venue */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2 flex items-center">
                  <MapPin className="w-4 h-4 mr-2 text-green-400" />
                  Venue *
                </label>
                <input
                  type="text"
                  name="venue"
                  value={formData.venue}
                  onChange={handleInputChange}
                  onFocus={() => setFocusedField('venue')}
                  onBlur={() => setFocusedField(null)}
                  placeholder="Enter venue location"
                  className={`w-full bg-gray-800/50 border ${
                    focusedField === 'venue' ? 'border-green-500' : 'border-gray-700'
                  } rounded-lg px-4 py-3 text-white placeholder-gray-500 focus:outline-none transition-all duration-300`}
                  required
                />
              </div>

              {/* Description */}
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Event Description
                </label>
                <textarea
                  name="description"
                  value={formData.description}
                  onChange={handleInputChange}
                  onFocus={() => setFocusedField('description')}
                  onBlur={() => setFocusedField(null)}
                  placeholder="Describe your event..."
                  rows="4"
                  className={`w-full bg-gray-800/50 border ${
                    focusedField === 'description' ? 'border-purple-500' : 'border-gray-700'
                  } rounded-lg px-4 py-3 text-white placeholder-gray-500 focus:outline-none transition-all duration-300 resize-none`}
                />
              </div>
            </div>
          </div>

          {/* Pricing Tiers Card */}
          <div className="bg-gray-900/30 backdrop-blur-xl rounded-2xl border border-purple-500/30 p-8 hover:border-purple-500/50 transition-all duration-300">
            <h2 className="text-2xl font-bold mb-6 flex items-center">
              <DollarSign className="w-6 h-6 mr-2 text-purple-400" />
              Ticket Pricing (AVAX)
            </h2>
            
            <div className="grid md:grid-cols-3 gap-6">
              <PriceCard
                tier="Regular"
                icon={Ticket}
                price={formData.regularPrice}
                color="border-green-500"
                features={["Standard entry", "Event access", "Digital ticket"]}
              />
              <PriceCard
                tier="VIP"
                icon={Star}
                price={formData.vipPrice}
                color="border-blue-500"
                features={["Priority entry", "VIP lounge access", "Premium seating", "Meet & greet"]}
              />
              <PriceCard
                tier="VVIP"
                icon={Zap}
                price={formData.vvipPrice}
                color="border-yellow-500"
                features={["Exclusive access", "Backstage pass", "Private area", "Gift package", "Photo opportunity"]}
              />
            </div>
          </div>

          {/* Submit Button */}
          <div className="flex justify-center">
            <button
              type="submit"
              className="group relative px-12 py-4 rounded-xl overflow-hidden transition-all duration-300 hover:scale-105"
            >
              <div className="absolute inset-0 bg-gradient-to-r from-purple-600 via-blue-600 to-purple-600 animate-gradient-x" />
              <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                   style={{ background: 'linear-gradient(45deg, rgba(168,85,247,0.4) 0%, rgba(147,51,234,0.4) 100%)' }} />
              <div className="relative z-10 flex items-center space-x-3">
                <Plus className="w-5 h-5" />
                <span className="font-bold text-lg">Create Event</span>
                <Sparkles className="w-5 h-5 animate-pulse" />
              </div>
            </button>
          </div>
        </form>

        {/* Info Banner */}
        <div className="mt-12 bg-purple-500/10 border border-purple-500/20 rounded-lg p-6">
          <div className="flex items-start space-x-3">
            <Clock className="w-5 h-5 text-purple-400 flex-shrink-0 mt-0.5" />
            <div>
              <h3 className="text-purple-400 font-medium mb-2">Event Creation Tips</h3>
              <ul className="text-sm text-gray-300 space-y-1">
                <li>• Ensure all event details are accurate before publishing</li>
                <li>• Set competitive pricing based on your event type and venue</li>
                <li>• Your event will be minted as NFTs on the blockchain</li>
                <li>• You can edit event details up to 24 hours before the event date</li>
              </ul>
            </div>
          </div>
        </div>
      </main>

      <style>{`
        @keyframes float {
          0%, 100% { transform: translate(0, 0); }
          50% { transform: translate(30px, -30px); }
        }

        @keyframes gradient-x {
          0%, 100% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
        }

        .animate-gradient-x {
          background-size: 200% auto;
          animation: gradient-x 15s linear infinite;
        }

        .animate-float {
          animation: float 6s ease-in-out infinite;
        }

        /* Custom scrollbar */
        ::-webkit-scrollbar {
          width: 10px;
        }

        ::-webkit-scrollbar-track {
          background: #1a1a1a;
        }

        ::-webkit-scrollbar-thumb {
          background: #9333EA;
          border-radius: 5px;
        }

        ::-webkit-scrollbar-thumb:hover {
          background: #a855f7;
        }
      `}</style>
    </div>
  );
};

export default QuantumEventCreator;