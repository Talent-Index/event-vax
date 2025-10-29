const API_BASE_URL = 'http://localhost:8080/api';

class EventService {
  // Create a new event
  async createEvent(eventData, flyerFile) {
    const formData = new FormData();
    
    // Add event data to form
    Object.keys(eventData).forEach(key => {
      if (eventData[key] !== null && eventData[key] !== '') {
        formData.append(key, eventData[key]);
      }
    });
    
    // Add flyer file if provided
    if (flyerFile) {
      formData.append('eventFlyer', flyerFile);
    }

    const response = await fetch(`${API_BASE_URL}/events`, {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Failed to create event');
    }

    return response.json();
  }

  // Get all events
  async getAllEvents() {
    const response = await fetch(`${API_BASE_URL}/events`);
    
    if (!response.ok) {
      throw new Error('Failed to fetch events');
    }

    return response.json();
  }

  // Get specific event by ID
  async getEventById(eventId) {
    const response = await fetch(`${API_BASE_URL}/events/${eventId}`);
    
    if (!response.ok) {
      if (response.status === 404) {
        throw new Error('Event not found');
      }
      throw new Error('Failed to fetch event');
    }

    return response.json();
  }

  // Update an event
  async updateEvent(eventId, eventData, flyerFile) {
    const formData = new FormData();
    
    Object.keys(eventData).forEach(key => {
      if (eventData[key] !== null && eventData[key] !== '') {
        formData.append(key, eventData[key]);
      }
    });
    
    if (flyerFile) {
      formData.append('eventFlyer', flyerFile);
    }

    const response = await fetch(`${API_BASE_URL}/events/${eventId}`, {
      method: 'PUT',
      body: formData,
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Failed to update event');
    }

    return response.json();
  }

  // Delete an event
  async deleteEvent(eventId) {
    const response = await fetch(`${API_BASE_URL}/events/${eventId}`, {
      method: 'DELETE',
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Failed to delete event');
    }

    return response.json();
  }

  // Record a ticket mint
  async recordTicketMint(eventId, ticketData) {
    const response = await fetch(`${API_BASE_URL}/events/${eventId}/mint`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(ticketData),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Failed to record ticket mint');
    }

    return response.json();
  }

  // Get flyer URL (helper method)
  getFlyerUrl(flyerPath) {
    if (!flyerPath) return null;
    return `http://localhost:8080${flyerPath}`;
  }
}

export default new EventService();
