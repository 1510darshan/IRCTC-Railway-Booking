
# IRCTC Railway Booking System

A full-stack web application for railway ticket booking, built with React, Node.js, Express, and Microsoft SQL Server.

## Features

- User Authentication & Authorization
- Train Search with Station Auto-suggestions
- Real-time Seat Availability
- Smart Seat Selection System
- PNR Status Tracking
- Multiple Payment Options
- Waiting List Management
- Alternative Train Suggestions
- Live Train Status Updates
- Responsive Design

## Tech Stack

### Frontend
- React.js
- React Router DOM
- CSS3
- Responsive Design

### Backend
- Node.js
- Express.js
- JWT Authentication
- MS SQL Server
- RESTful API Architecture

## Installation

1. Clone the repository:
```bash
git clone [repository-url]
```

2. Install backend dependencies:
```bash
npm install
```

3. Install frontend dependencies:
```bash
cd frontend
npm install
```

4. Create a `.env` file in the Backend directory with the following variables:
```env
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_SERVER=your_db_server
DB_DATABASE=your_db_name
JWT_SECRET=your_jwt_secret
```

5. Set up the database:
- Execute the SQL scripts in the Database folder:
  - `Railway.sql` (Main schema)
  - `database.sql` (Initial data)

## Running the Application

1. Start the backend server:
```bash
npm start
```

2. Start the frontend development server:
```bash
cd frontend
npm start
```

## Project Structure

```
├── Backend/
│   ├── config/         # Database configuration
│   ├── controllers/    # Request handlers
│   ├── middleware/     # Authentication & error handling
│   ├── routes/         # API routes
│   ├── utils/          # Utility functions
│   └── server.js       # Main server file
├── Database/
│   ├── Railway.sql     # Database schema
│   └── database.sql    # Initial data
└── frontend/
    ├── public/         # Static files
    └── src/
        ├── components/ # React components
        └── styles/     # CSS styles
```

## API Endpoints

- `/api/users` - User management
- `/api/trains` - Train information
- `/api/bookings` - Booking management
- `/api/payments` - Payment processing
- `/api/live-status` - Live train status
- `/api/stations` - Station information
- `/api/seats` - Seat management

## Features in Detail

### Booking System
- Smart seat allocation
- Multiple coach types (1A, 2A, 3A, SL, CC)
- Automatic waiting list management
- Alternative train suggestions

### User Management
- Secure authentication
- Profile management
- Booking history
- PNR status tracking

### Train Search
- Station auto-suggestions
- Real-time availability check
- Multiple filter options
- Smart sorting algorithms

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

