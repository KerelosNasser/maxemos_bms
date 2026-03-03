import urllib.request
import json
import sqlite3
import os

db_path = 'assets/db/bible_ar_vd.db'

# Ensure directory exists
os.makedirs('assets/db', exist_ok=True)

if os.path.exists(db_path):
    os.remove(db_path)

print("Downloading Arabic SV Bible...")
url = "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/ar_svd.json"
response = urllib.request.urlopen(url)
data = json.loads(response.read())

print("Creating database...")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute('''
    CREATE TABLE verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book TEXT,
        chapter INTEGER,
        verse INTEGER,
        text TEXT
    )
''')

print("Inserting verses...")
for book in data:
    book_name = book['name']
    chapters = book['chapters']
    
    for c_idx, chapter_verses in enumerate(chapters):
        chapter_num = c_idx + 1
        
        for v_idx, verse_text in enumerate(chapter_verses):
            verse_num = v_idx + 1
            cursor.execute(
                'INSERT INTO verses (book, chapter, verse, text) VALUES (?, ?, ?, ?)',
                (book_name, chapter_num, verse_num, verse_text)
            )

conn.commit()
conn.close()

print(f"Database successfully created at {db_path} with {len(data)} books!")
