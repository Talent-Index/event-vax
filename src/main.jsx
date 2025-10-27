import React from 'react';
import ReactDOM from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { ChakraProvider } from '@chakra-ui/react';
import Home from './pages/Home';
import Discover from './pages/Discover';
import Testimonials from './pages/Testimonials';
import Hero from './pages/Hero';
import EventList from './pages/EventList';
import EventDetails from './pages/EventDetails';
import Qrcode from './pages/Qrcode';
import Chatbit from './pages/Chatbit';
import Footer from './components/Footer';
import Ticketsell from './pages/Ticketsell';
import MintNFT from './pages/MintNFT';
import Ticket from './pages/Ticket';
import Teams from './pages/Teams';
import Layout from './Layout';
import Myevent from './pages/Myevent';
import './index.css';
import WaitlistPage from './pages/WaitingList';
import QuantumTicketResale from './pages/QuantamTicketResale';

const router = createBrowserRouter([
  {
    path: "/",
    element: <Layout><Home /></Layout>,
  },
  {
    path: "discover",
    element: <Layout><Discover /></Layout>,
  },
  {
    path: "testimonials",
    element: <Layout><Testimonials /></Layout>,
  },
  {
    path: "qrcode",
    element: <Layout><Qrcode /></Layout>,
  },
  {
    path: "ticket",
    element: <Layout><Ticket /></Layout>,
  },
  {
    path: "teams",
    element: <Layout><Teams /></Layout>,
  },
  {
    path: "ticketsell",
    element: <Layout><Ticketsell /></Layout>
  },
  {
    path: "hero",
    element: <Layout><Hero /></Layout>,
  },
  {
    path: "event",
    element: <Layout><EventList /></Layout>,
  },
  {
    path: "mint",
    element: <Layout><MintNFT /></Layout>,
  },
  
  {
    path: "event-details",
    element: <Layout><EventDetails /></Layout>,
  },
  {
    path: "Myevent",
    element: <Layout><Myevent /></Layout>,
  },
  {
    path: "chatbit",
    element: <Chatbit />,
  },

  {
    path: "waiting",
    element: <Layout><WaitlistPage /></Layout>
  },

  {
    path: "resell",
    element: <Layout><QuantumTicketResale /></Layout>
  },

  {
    path: "*",
    element: <Footer />,
  },
]);

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
        <RouterProvider router={router} />
  </React.StrictMode>
);