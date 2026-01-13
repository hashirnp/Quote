-- Supabase Database Setup for Quote App
-- Run this SQL in your Supabase SQL Editor

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create quotes table
CREATE TABLE IF NOT EXISTS quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  author TEXT NOT NULL,
  category_id UUID REFERENCES categories(id),
  likes INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create collections table
CREATE TABLE IF NOT EXISTS collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, name)
);

-- Create user_favorites table
CREATE TABLE IF NOT EXISTS user_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  quote_text TEXT NOT NULL,
  quote_author TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, quote_id)
);

-- Create collection_quotes table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS collection_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  quote_text TEXT NOT NULL,
  quote_author TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(collection_id, quote_id)
);

-- Create quote_likes table
CREATE TABLE IF NOT EXISTS quote_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id TEXT NOT NULL,
  quote_text TEXT NOT NULL,
  quote_author TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, quote_id)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_quotes_category ON quotes(category_id);
CREATE INDEX IF NOT EXISTS idx_quotes_author ON quotes(author);
CREATE INDEX IF NOT EXISTS idx_quotes_created_at ON quotes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_quotes_text_search ON quotes USING gin(to_tsvector('english', text));

CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_quote_id ON user_favorites(quote_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_created_at ON user_favorites(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_collections_user_id ON collections(user_id);
CREATE INDEX IF NOT EXISTS idx_collections_created_at ON collections(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_collection_quotes_collection_id ON collection_quotes(collection_id);
CREATE INDEX IF NOT EXISTS idx_collection_quotes_quote_id ON collection_quotes(quote_id);

CREATE INDEX IF NOT EXISTS idx_quote_likes_user_id ON quote_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_quote_likes_quote_id ON quote_likes(quote_id);

-- Insert categories
INSERT INTO categories (name, description, icon) VALUES
  ('Motivation', 'Inspirational quotes to motivate and energize', '⚡'),
  ('Love', 'Quotes about love, relationships, and connection', '❤️'),
  ('Success', 'Quotes about achievement, goals, and success', '📈'),
  ('Wisdom', 'Thoughtful quotes with deep meaning', '📖'),
  ('Humor', 'Funny and lighthearted quotes', '😊')
ON CONFLICT (name) DO NOTHING;

-- Sample quotes (you should add 100+ quotes)
-- Category IDs will be generated, so we'll use subqueries
INSERT INTO quotes (text, author, category_id) VALUES
  ('The only way to do great work is to love what you do.', 'Steve Jobs', (SELECT id FROM categories WHERE name = 'Motivation')),
  ('Energy and persistence conquer all things.', 'Benjamin Franklin', (SELECT id FROM categories WHERE name = 'Motivation')),
  ('Ambition is the path to success. Persistence is the vehicle you arrive in.', 'Bill Bradley', (SELECT id FROM categories WHERE name = 'Success')),
  ('Great works are performed not by strength but by perseverance.', 'Samuel Johnson', (SELECT id FROM categories WHERE name = 'Success')),
  ('Nature does not hurry, yet everything is accomplished.', 'Lao Tzu', (SELECT id FROM categories WHERE name = 'Wisdom')),
  ('Simplicity is the ultimate sophistication.', 'Leonardo da Vinci', (SELECT id FROM categories WHERE name = 'Wisdom')),
  ('Love is composed of a single soul inhabiting two bodies.', 'Aristotle', (SELECT id FROM categories WHERE name = 'Love')),
  ('The best thing to hold onto in life is each other.', 'Audrey Hepburn', (SELECT id FROM categories WHERE name = 'Love')),
  ('A day without laughter is a day wasted.', 'Charlie Chaplin', (SELECT id FROM categories WHERE name = 'Humor')),
  ('I am so clever that sometimes I don''t understand a single word of what I am saying.', 'Oscar Wilde', (SELECT id FROM categories WHERE name = 'Humor'))
ON CONFLICT DO NOTHING;

-- Enable Row Level Security (RLS)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE collection_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quote_likes ENABLE ROW LEVEL SECURITY;

-- Create policies to allow public read access on categories and quotes
CREATE POLICY "Allow public read access on categories" ON categories
  FOR SELECT USING (true);

CREATE POLICY "Allow public read access on quotes" ON quotes
  FOR SELECT USING (true);

-- Create policies for user_favorites (users can only see their own favorites)
CREATE POLICY "Users can view their own favorites" ON user_favorites
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own favorites" ON user_favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own favorites" ON user_favorites
  FOR DELETE USING (auth.uid() = user_id);

-- Create policies for collections (users can only see their own collections)
CREATE POLICY "Users can view their own collections" ON collections
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own collections" ON collections
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own collections" ON collections
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own collections" ON collections
  FOR DELETE USING (auth.uid() = user_id);

-- Create policies for collection_quotes
CREATE POLICY "Users can view quotes in their collections" ON collection_quotes
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert quotes in their collections" ON collection_quotes
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete quotes from their collections" ON collection_quotes
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
    )
  );

-- Create policies for quote_likes
CREATE POLICY "Users can view their own likes" ON quote_likes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own likes" ON quote_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own likes" ON quote_likes
  FOR DELETE USING (auth.uid() = user_id);

-- Create function to increment quote likes
CREATE OR REPLACE FUNCTION increment_quote_likes(quote_id_param UUID)
RETURNS void AS $$
BEGIN
    UPDATE quotes SET likes = COALESCE(likes, 0) + 1 WHERE id = quote_id_param;
END;
$$ LANGUAGE plpgsql;

-- Create function to decrement quote likes
CREATE OR REPLACE FUNCTION decrement_quote_likes(quote_id_param UUID)
RETURNS void AS $$
BEGIN
    UPDATE quotes SET likes = GREATEST(COALESCE(likes, 0) - 1, 0) WHERE id = quote_id_param;
END;
$$ LANGUAGE plpgsql;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to update updated_at on collections
CREATE TRIGGER update_collections_updated_at BEFORE UPDATE ON collections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
