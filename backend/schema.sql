-- Database Schema for Smart Intercom Demo
-- PostgreSQL / Supabase

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    apartment_number VARCHAR(10) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Door logs table
CREATE TABLE IF NOT EXISTS door_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Video cameras table (optional, for managing multiple cameras)
CREATE TABLE IF NOT EXISTS video_cameras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    rtsp_url TEXT NOT NULL,
    location VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_door_logs_user_id ON door_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_door_logs_timestamp ON door_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);

-- Insert test data
-- Password: demo123 (in production, use bcrypt hash)
INSERT INTO users (phone, password_hash, apartment_number) VALUES
    ('+996771102429', 'demo123', '42'),
    ('+996555123456', 'test123', '15')
ON CONFLICT (phone) DO NOTHING;

-- Insert test cameras
INSERT INTO video_cameras (name, rtsp_url, location) VALUES
    ('Главный вход', 'rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4', 'Главный вход'),
    ('Двор', 'rtsp://rtsp.stream/pattern', 'Территория двора')
ON CONFLICT DO NOTHING;

-- Create a function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for users table
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions (adjust based on your setup)
-- For Supabase, you might need to configure RLS (Row Level Security)

COMMENT ON TABLE users IS 'Registered users/residents of the building';
COMMENT ON TABLE door_logs IS 'Log of all door opening actions';
COMMENT ON TABLE video_cameras IS 'Configuration for RTSP video cameras';
