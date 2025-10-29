import express from 'express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import fs from 'fs/promises';
import multer from 'multer';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// File paths
const EVENTS_FILE = join(__dirname, '../data/events.json');
const TICKETS_FILE = join(__dirname, '../data/tickets.json');
const UPLOADS_DIR = join(__dirname, '../uploads');

// Ensure directories exist
async function ensureDirectories() {
  try {
    await fs.mkdir(join(__dirname, '../data'), { recursive: true });
    await fs.mkdir(UPLOADS_DIR, { recursive: true });
  } catch (error) {
    console.error('Error creating directories:', error);
  }
}

// Initialize files if they don't exist
async function initializeFiles() {
  try {
    await fs.access(EVENTS_FILE);
  } catch {
    await fs.writeFile(EVENTS_FILE, JSON.stringify([], null, 2));
  }
  
  try {
    await fs.access(TICKETS_FILE);
  } catch {
    await fs.writeFile(TICKETS_FILE, JSON.stringify([], null, 2));
  }
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOADS_DIR);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'flyer-' + uniqueSuffix + '.' + file.originalname.split('.').pop());
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// Helper functions
async function readEvents() {
  try {
    const data = await fs.readFile(EVENTS_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    return [];
  }
}

async function writeEvents(events) {
  await fs.writeFile(EVENTS_FILE, JSON.stringify(events, null, 2));
}

async function readTickets() {
  try {
    const data = await fs.readFile(TICKETS_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    return [];
  }
}

async function writeTickets(tickets) {
  await fs.writeFile(TICKETS_FILE, JSON.stringify(tickets, null, 2));
}

// Initialize on startup
ensureDirectories();
initializeFiles();

// Routes

// GET /api/events - Get all events
router.get('/', async (req, res) => {
  try {
    const events = await readEvents();
    res.json(events);
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// GET /api/events/:id - Get specific event
router.get('/:id', async (req, res) => {
  try {
    const events = await readEvents();
    const event = events.find(e => e.id === req.params.id);
    
    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }
    
    res.json(event);
  } catch (error) {
    console.error('Error fetching event:', error);
    res.status(500).json({ error: 'Failed to fetch event' });
  }
});

// POST /api/events - Create new event
router.post('/', upload.single('eventFlyer'), async (req, res) => {
  try {
    const {
      eventName,
      eventDate,
      venue,
      description,
      regularPrice,
      vipPrice,
      vvipPrice
    } = req.body;

    // Validation
    if (!eventName || !eventDate || !venue) {
      return res.status(400).json({ 
        error: 'Event name, date, and venue are required' 
      });
    }

    const events = await readEvents();
    
    const newEvent = {
      id: uuidv4(),
      eventName,
      eventDate,
      venue,
      description: description || '',
      flyerUrl: req.file ? `/uploads/${req.file.filename}` : null,
      pricing: {
        regular: parseFloat(regularPrice) || 0,
        vip: parseFloat(vipPrice) || 0,
        vvip: parseFloat(vvipPrice) || 0
      },
      maxTickets: 500,
      availableTickets: 500,
      status: 'active',
      createdAt: new Date().toISOString(),
      createdBy: req.body.walletAddress || 'anonymous'
    };

    events.push(newEvent);
    await writeEvents(events);

    res.status(201).json(newEvent);
  } catch (error) {
    console.error('Error creating event:', error);
    res.status(500).json({ error: 'Failed to create event' });
  }
});

// PUT /api/events/:id - Update event
router.put('/:id', upload.single('eventFlyer'), async (req, res) => {
  try {
    const events = await readEvents();
    const eventIndex = events.findIndex(e => e.id === req.params.id);
    
    if (eventIndex === -1) {
      return res.status(404).json({ error: 'Event not found' });
    }

    const updatedEvent = {
      ...events[eventIndex],
      ...req.body,
      flyerUrl: req.file ? `/uploads/${req.file.filename}` : events[eventIndex].flyerUrl,
      updatedAt: new Date().toISOString()
    };

    events[eventIndex] = updatedEvent;
    await writeEvents(events);

    res.json(updatedEvent);
  } catch (error) {
    console.error('Error updating event:', error);
    res.status(500).json({ error: 'Failed to update event' });
  }
});

// DELETE /api/events/:id - Delete event
router.delete('/:id', async (req, res) => {
  try {
    const events = await readEvents();
    const filteredEvents = events.filter(e => e.id !== req.params.id);
    
    if (events.length === filteredEvents.length) {
      return res.status(404).json({ error: 'Event not found' });
    }

    await writeEvents(filteredEvents);
    res.json({ message: 'Event deleted successfully' });
  } catch (error) {
    console.error('Error deleting event:', error);
    res.status(500).json({ error: 'Failed to delete event' });
  }
});

// POST /api/events/:id/mint - Record ticket mint
router.post('/:id/mint', async (req, res) => {
  try {
    const { tokenId, ownerAddress, seatNumber, ticketType, price } = req.body;
    
    const events = await readEvents();
    const eventIndex = events.findIndex(e => e.id === req.params.id);
    
    if (eventIndex === -1) {
      return res.status(404).json({ error: 'Event not found' });
    }

    // Update available tickets
    if (events[eventIndex].availableTickets > 0) {
      events[eventIndex].availableTickets -= 1;
      await writeEvents(events);
    }

    // Record ticket
    const tickets = await readTickets();
    const newTicket = {
      id: uuidv4(),
      eventId: req.params.id,
      tokenId,
      ownerAddress,
      seatNumber,
      ticketType,
      price: parseFloat(price),
      mintedAt: new Date().toISOString(),
      status: 'active'
    };

    tickets.push(newTicket);
    await writeTickets(tickets);

    res.status(201).json(newTicket);
  } catch (error) {
    console.error('Error recording ticket mint:', error);
    res.status(500).json({ error: 'Failed to record ticket mint' });
  }
});

export default router;
