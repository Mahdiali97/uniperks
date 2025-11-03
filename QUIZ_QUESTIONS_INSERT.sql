-- ⚡ Quiz Questions - Insert 20 Questions per Module
-- Run this AFTER running SQL_QUICK_SETUP.md

-- ========================================
-- STEP 1: Insert Quiz Modules First
-- ========================================

INSERT INTO quiz_modules (id, title, description, category, icon, active) VALUES
('upsi_history', 'UPSI History', 'Learn about Sultan Idris Educational University''s rich history', 'History', '🏛️', true),
('general_knowledge', 'General Knowledge', 'Test your knowledge on various topics', 'General', '🌍', true),
('university_math', 'University Mathematics', 'Challenge yourself with math problems', 'Mathematics', '📐', true),
('university_english', 'University English', 'Improve your English skills', 'Language', '📚', true)
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- STEP 2: Insert Questions for Each Module
-- ========================================

-- ========================================
-- 1. UPSI HISTORY (20 Questions)
-- ========================================

-- Easy Questions (1 coin each) - 8 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('upsi_history', 'In which year was Sultan Idris Education University (UPSI) established?', '["1922", "1925", "1928", "1930"]', 0, 1),
('upsi_history', 'UPSI is located in which state of Malaysia?', '["Selangor", "Perak", "Pahang", "Negeri Sembilan"]', 1, 1),
('upsi_history', 'What was UPSI originally known as?', '["Sultan Idris Training College", "Teacher Training Institute", "Education Academy", "Perak College"]', 0, 1),
('upsi_history', 'What is the main focus of UPSI?', '["Engineering", "Teacher Education", "Medicine", "Business"]', 1, 1),
('upsi_history', 'UPSI is located in which city?', '["Ipoh", "Kuala Lumpur", "Tanjong Malim", "Shah Alam"]', 2, 1),
('upsi_history', 'Who was Sultan Idris?', '["A Sultan of Perak", "A Sultan of Selangor", "A Prime Minister", "A British Governor"]', 0, 1),
('upsi_history', 'When did UPSI achieve full university status?', '["1997", "2000", "2005", "2010"]', 0, 1),
('upsi_history', 'What is UPSI''s motto?', '["With Knowledge We Serve", "Education for All", "Learning Excellence", "Future Leaders"]', 0, 1);

-- Medium Questions (1 coin each) - 8 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('upsi_history', 'UPSI became a university college in which year?', '["1997", "1999", "2000", "2005"]', 1, 2),
('upsi_history', 'How many faculties does UPSI have?', '["7", "8", "9", "10"]', 2, 2),
('upsi_history', 'What is the campus size of UPSI approximately?', '["500 acres", "700 acres", "1000 acres", "1200 acres"]', 2, 2),
('upsi_history', 'UPSI offers programs up to which level?', '["Bachelor only", "Master only", "PhD", "Diploma only"]', 2, 2),
('upsi_history', 'What is the student population at UPSI approximately?', '["10,000", "15,000", "20,000", "25,000"]', 1, 2),
('upsi_history', 'Which faculty is UPSI most famous for?', '["Engineering", "Education", "Medicine", "Law"]', 1, 2),
('upsi_history', 'UPSI was upgraded from college to university college in what year?', '["1992", "1997", "2000", "2005"]', 1, 2),
('upsi_history', 'The iconic UPSI landmark is?', '["Clock Tower", "Main Library", "Sultan Azlan Shah Gallery", "Sports Complex"]', 2, 2);

-- Hard Questions (2 coins each) - 4 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('upsi_history', 'Who was the first Vice-Chancellor of UPSI when it became a full university?', '["Prof. Dr. Zakaria Kasa", "Prof. Dr. Hassan Said", "Prof. Dr. Aminah Ayob", "Prof. Dr. Mohd Salleh"]', 0, 3),
('upsi_history', 'What significant event happened to UPSI in 2012?', '["New campus opened", "Received autonomy status", "Merged with another university", "Changed name"]', 1, 3),
('upsi_history', 'UPSI is a member of which international education network?', '["ASEAN University Network", "Commonwealth Universities", "European University Association", "Pacific Rim Universities"]', 0, 3),
('upsi_history', 'What was the original capacity of students when UPSI was first established?', '["50 students", "100 students", "200 students", "500 students"]', 1, 3);

-- ========================================
-- 2. GENERAL KNOWLEDGE (20 Questions)
-- ========================================

-- Easy Questions (1 coin each) - 8 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('general_knowledge', 'What is the capital of Malaysia?', '["Kuala Lumpur", "Penang", "Johor Bahru", "Ipoh"]', 0, 1),
('general_knowledge', 'How many states are in Malaysia?', '["11", "13", "14", "16"]', 1, 1),
('general_knowledge', 'What is Malaysia''s national flower?', '["Rose", "Hibiscus", "Orchid", "Jasmine"]', 1, 1),
('general_knowledge', 'Malaysia gained independence in which year?', '["1945", "1957", "1963", "1970"]', 1, 1),
('general_knowledge', 'What is the tallest building in Malaysia?', '["Petronas Twin Towers", "KL Tower", "Merdeka 118", "Exchange 106"]', 2, 1),
('general_knowledge', 'What ocean is to the east of Malaysia?', '["Atlantic Ocean", "Pacific Ocean", "Indian Ocean", "Arctic Ocean"]', 1, 1),
('general_knowledge', 'What is the currency of Malaysia?', '["Dollar", "Ringgit", "Rupiah", "Baht"]', 1, 1),
('general_knowledge', 'Who is the current Yang di-Pertuan Agong (as of 2025)?', '["Sultan Ibrahim", "Sultan Abdullah", "Sultan Nazrin", "Sultan Sharafuddin"]', 0, 1);

-- Medium Questions (1 coin each) - 8 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('general_knowledge', 'Malaysia is divided into how many regions?', '["2 regions", "3 regions", "4 regions", "5 regions"]', 0, 2),
('general_knowledge', 'What is Malaysia''s national animal?', '["Tiger", "Elephant", "Malayan Tiger", "Orangutan"]', 2, 2),
('general_knowledge', 'Which city is known as the Pearl of the Orient?', '["Kuala Lumpur", "Penang", "Malacca", "Kota Kinabalu"]', 1, 2),
('general_knowledge', 'Mount Kinabalu is located in which state?', '["Sabah", "Sarawak", "Pahang", "Perak"]', 0, 2),
('general_knowledge', 'How many federal territories are in Malaysia?', '["1", "2", "3", "4"]', 2, 2),
('general_knowledge', 'What is the longest river in Malaysia?', '["Rajang River", "Pahang River", "Kinabatangan River", "Perak River"]', 0, 2),
('general_knowledge', 'Malaysia''s national anthem is called?', '["Negaraku", "Kebangsaan", "Malaysia Raya", "Tanah Pusaka"]', 0, 2),
('general_knowledge', 'Which Malaysian city was a UNESCO World Heritage Site in 2008?', '["Kuala Lumpur", "Ipoh", "George Town", "Johor Bahru"]', 2, 2);

-- Hard Questions (2 coins each) - 4 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('general_knowledge', 'Who was Malaysia''s first Prime Minister?', '["Tun Abdul Razak", "Tunku Abdul Rahman", "Tun Hussein Onn", "Tun Dr. Mahathir"]', 1, 3),
('general_knowledge', 'In what year did Sabah and Sarawak join the Federation of Malaysia?', '["1957", "1960", "1963", "1965"]', 2, 3),
('general_knowledge', 'What is the total land area of Malaysia approximately?', '["230,000 sq km", "280,000 sq km", "330,000 sq km", "380,000 sq km"]', 2, 3),
('general_knowledge', 'Which agreement formed the Federation of Malaysia?', '["Kuala Lumpur Agreement", "Malaysia Agreement", "Independence Treaty", "Federal Constitution"]', 1, 3);

-- ========================================
-- 3. UNIVERSITY MATHEMATICS (20 Questions)
-- ========================================

-- Easy Questions (1 coin each) - 8 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('university_math', 'What is 15% of 200?', '["20", "25", "30", "35"]', 2, 1),
('university_math', 'Solve: 2x + 6 = 14. What is x?', '["2", "4", "6", "8"]', 1, 1),
('university_math', 'What is the square root of 144?', '["10", "11", "12", "13"]', 2, 1),
('university_math', 'What is 7 × 8?', '["54", "56", "58", "60"]', 1, 1),
('university_math', 'What is the area of a rectangle with length 5 and width 3?', '["8", "12", "15", "18"]', 2, 1),
('university_math', 'What is 25 + 37?', '["60", "62", "64", "66"]', 1, 1),
('university_math', 'What is half of 50?', '["20", "25", "30", "35"]', 1, 1),
('university_math', 'What is 100 - 37?', '["53", "63", "73", "83"]', 1, 1);

-- Medium Questions (1 coin each) - 8 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('university_math', 'If a circle has a diameter of 10, what is its radius?', '["3", "5", "7", "10"]', 1, 2),
('university_math', 'Solve: 3x - 5 = 16. What is x?', '["5", "6", "7", "8"]', 2, 2),
('university_math', 'What is the area of a circle with radius 7? (Use π ≈ 3.14)', '["38.5", "49", "154", "196"]', 2, 2),
('university_math', 'What is 30% of 250?', '["50", "65", "75", "85"]', 2, 2),
('university_math', 'Solve: x² = 49. What is x? (positive value)', '["5", "6", "7", "8"]', 2, 2),
('university_math', 'What is the perimeter of a square with side length 12?', '["36", "40", "48", "60"]', 2, 2),
('university_math', 'Solve: 2(x + 3) = 18. What is x?', '["4", "5", "6", "7"]', 2, 2),
('university_math', 'What is the sum of angles in a triangle?', '["90°", "120°", "180°", "360°"]', 2, 2);

-- Hard Questions (2 coins each) - 4 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('university_math', 'Solve the quadratic equation: x² - 5x + 6 = 0. What are the values of x?', '["x = 1, 6", "x = 2, 3", "x = 3, 4", "x = 4, 5"]', 1, 3),
('university_math', 'What is the derivative of f(x) = 3x² + 2x?', '["3x + 2", "6x + 2", "6x² + 2x", "9x + 2"]', 1, 3),
('university_math', 'If sin θ = 0.5, what is θ in degrees? (0° < θ < 90°)', '["15°", "30°", "45°", "60°"]', 1, 3),
('university_math', 'What is the integral of ∫2x dx?', '["2x", "x²", "x² + C", "2x² + C"]', 2, 3);

-- ========================================
-- 4. UNIVERSITY ENGLISH (20 Questions)
-- ========================================

-- Easy Questions (1 coin each) - 8 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('university_english', 'Which word is a synonym for "happy"?', '["Sad", "Joyful", "Angry", "Tired"]', 1, 1),
('university_english', 'What is the plural of "child"?', '["Childs", "Children", "Childrens", "Childes"]', 1, 1),
('university_english', 'Which sentence is grammatically correct?', '["She go to school", "She goes to school", "She going to school", "She gone to school"]', 1, 1),
('university_english', 'What is the past tense of "run"?', '["Runned", "Run", "Ran", "Running"]', 2, 1),
('university_english', 'Which is a noun?', '["Quickly", "Beautiful", "Table", "Running"]', 2, 1),
('university_english', 'What is the opposite of "hot"?', '["Warm", "Cool", "Cold", "Freezing"]', 2, 1),
('university_english', 'Which word is spelled correctly?', '["Recieve", "Receive", "Recive", "Receeve"]', 1, 1),
('university_english', 'What does "library" mean?', '["A place to eat", "A place to read books", "A place to sleep", "A place to exercise"]', 1, 1);

-- Medium Questions (1 coin each) - 8 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('university_english', 'Identify the adjective: "The beautiful sunset was breathtaking."', '["sunset", "beautiful", "was", "breathtaking"]', 1, 2),
('university_english', 'What type of sentence is this? "Please close the door."', '["Declarative", "Imperative", "Interrogative", "Exclamatory"]', 1, 2),
('university_english', 'Which is the correct usage of "their"?', '["Their going home", "They are their", "Their house is big", "Their very happy"]', 2, 2),
('university_english', 'What is a synonym for "difficult"?', '["Easy", "Simple", "Hard", "Soft"]', 2, 2),
('university_english', 'Which sentence uses the passive voice?', '["John wrote the letter", "The letter was written by John", "John is writing", "John will write"]', 1, 2),
('university_english', 'What is the superlative form of "good"?', '["Gooder", "Goodest", "Better", "Best"]', 3, 2),
('university_english', 'Identify the verb: "She quickly ran to the store."', '["quickly", "ran", "store", "she"]', 1, 2),
('university_english', 'Which word is an adverb?', '["Quick", "Quickly", "Quickness", "Quicken"]', 1, 2);

-- Hard Questions (2 coins each) - 4 questions
INSERT INTO quiz_questions (module_id, question, answers, correct_answer, difficulty) VALUES
('university_english', 'What literary device is this? "The world is a stage."', '["Simile", "Metaphor", "Personification", "Alliteration"]', 1, 3),
('university_english', 'Which is an example of a complex sentence?', '["I went home.", "I went home, and I slept.", "Although I was tired, I went home.", "I went home; I slept."]', 2, 3),
('university_english', 'What is the correct form? "Neither of the students ___ their homework."', '["have completed", "has completed", "are completing", "were completed"]', 1, 3),
('university_english', 'Identify the gerund: "Swimming is my favorite activity."', '["Swimming", "is", "favorite", "activity"]', 0, 3);

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Successfully inserted 80 quiz questions (20 per module)!';
  RAISE NOTICE 'UPSI History: 8 easy, 8 medium, 4 hard';
  RAISE NOTICE 'General Knowledge: 8 easy, 8 medium, 4 hard';
  RAISE NOTICE 'University Math: 8 easy, 8 medium, 4 hard';
  RAISE NOTICE 'University English: 8 easy, 8 medium, 4 hard';
END $$;
