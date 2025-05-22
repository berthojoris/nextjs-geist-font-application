# Supabase Setup Guide

## 1. Create a Supabase Project

1. Go to [Supabase](https://supabase.com) and sign up/login
2. Click "New Project" and fill in:
   - Organization (create if needed)
   - Project name: "survey-app"
   - Database password: (save this securely)
   - Region: (choose closest to your users)
   - Pricing plan: Free tier

## 2. Get Project Credentials

1. Once project is created, go to Project Settings
2. In the API section, copy:
   - Project URL
   - anon/public key
3. Create a new file `lib/config/supabase_config.dart`:
   ```dart
   class SupabaseConfig {
     static const String url = 'YOUR_PROJECT_URL';
     static const String anonKey = 'YOUR_ANON_KEY';
   }
   ```

## 3. Set Up Database Table

1. Go to SQL Editor in Supabase Dashboard
2. Run this SQL to create the survey_responses table:

```sql
-- Create enum for question types
CREATE TYPE question_type AS ENUM ('text', 'radio', 'checkbox', 'dropdown');

-- Create questions table
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    text TEXT NOT NULL,
    type question_type NOT NULL,
    options JSONB,
    required BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create responses table
CREATE TABLE survey_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID REFERENCES questions(id),
    answer JSONB NOT NULL,
    device_id TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    synced BOOLEAN DEFAULT true
);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_questions_updated_at
    BEFORE UPDATE ON questions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create RLS policies
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE survey_responses ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read access to questions
CREATE POLICY "Allow anonymous read access to questions"
ON questions FOR SELECT
TO anon
USING (true);

-- Allow anonymous insert access to survey_responses
CREATE POLICY "Allow anonymous insert access to survey_responses"
ON survey_responses FOR INSERT
TO anon
WITH CHECK (true);

-- Allow anonymous read access to own device responses
CREATE POLICY "Allow anonymous read access to own device responses"
ON survey_responses FOR SELECT
TO anon
USING (device_id = current_setting('app.device_id')::TEXT);
```

## 4. Enable Real-time

1. Go to Database → Replication
2. Enable real-time for:
   - questions
   - survey_responses

## 5. Set up Storage (for offline sync)

1. Go to Storage → Create new bucket
2. Create bucket named "survey-responses"
3. Set bucket public/private according to your needs
4. Update bucket policies as needed

## 6. Testing the Setup

1. Insert a test question:
```sql
INSERT INTO questions (text, type, options)
VALUES (
    'How satisfied are you with the event?',
    'radio',
    '["Very Satisfied", "Satisfied", "Neutral", "Dissatisfied", "Very Dissatisfied"]'
);
```

2. Test query in SQL Editor:
```sql
SELECT * FROM questions;
SELECT * FROM survey_responses;
```

## Security Considerations

1. **Row Level Security (RLS)**: Already configured in the setup SQL
2. **API Key**: Only use anon key in client app
3. **Data Validation**: Implemented in the app
4. **Rate Limiting**: Consider adding if needed

## Monitoring

1. Go to Database → API
2. Monitor:
   - Request rate
   - Response times
   - Error rates

## Backup

1. Go to Database → Backups
2. Enable Point in Time Recovery if needed
3. Schedule regular backups
