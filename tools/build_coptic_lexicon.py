import sqlite3
import os

db_path = 'assets/db/coptic_lexicon.db'

# Ensure directory exists
os.makedirs('assets/db', exist_ok=True)

if os.path.exists(db_path):
    os.remove(db_path)

print("Creating Coptic Lexicon Database...")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute('''
    CREATE TABLE terms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        term TEXT UNIQUE,
        definition TEXT,
        root TEXT,
        language TEXT
    )
''')

# Highly accurate, St-Takla aligned Coptic Orthodox Theological Terms
theological_terms = [
    ("هوموسيوس", "مساوٍ للآب في الجوهر، وهو مصطلح لاهوتي من مجمع نيقية يؤكد ألوهية المسيح المطلقة.", "Homoousios", "Greek"),
    ("الثيؤتوكوس", "والدة الإله، وهو لقب العذراء مريم الدائم البتولية الذي أُقر في مجمع أفسس.", "Theotokos", "Greek"),
    ("الأقنوم", "الكيان الفردي الذاتي الحقيقي. يُطلق في الثالوث القدوس على الآب والابن والروح القدس.", "Hypostasis", "Greek/Syriac"),
    ("البانطوكراتور", "ضابط الكل، صفة الله القادر على كل شيء ومدبر الخليقة.", "Pantocrator", "Greek"),
    ("الإفخارستيا", "سر التناول المقدس، ويعني الشكر. هو جسد ودم المسيح الأقدسين.", "Eucharist", "Greek"),
    ("الميامر", "جمع ميمر، وهي الوعظ والمقالات الروحية أو السير المكتوبة للآباء القديسين.", "Memre", "Syriac"),
    ("السنكسار", "كتاب كنسي يحتوي على سير القديسين وأخبار الشهداء وتذكارات الأعياد مرتبة حسب التقويم القبطي.", "Synaxarium", "Greek/Coptic"),
    ("الأبصلمودية", "كتاب التسبيح الكنسي اليومي (التسبحة).", "Psalmody", "Greek"),
    ("الأغابي", "المحبة الروحية الباذلة غير المشروطة. وتُطلق كنسياً على ولائم المحبة التي تعقب القداس.", "Agape", "Greek"),
    ("الأنافورا", "الجزء الأساسي من القداس الإلهي والذي يبدأ بجملة 'الرب مع جميعكم'. ويعني الصعود أو الارتفاع.", "Anaphora", "Greek"),
    ("الكاثوليكون", "رسائل الكاثوليكون أي الرسائل الجامعة (رسائل بطرس، يعقوب، يوحنا، ويهوذا).", "Catholicon", "Greek"),
    ("الإبركسيس", "سفر أعمال الرسل الذي يُقرأ منه فصل في كل قداس.", "Praxis", "Greek"),
    ("البصخة", "كلمة أصلها آرامي بمعنى 'عُبور'. تُطلق في الكنيسة القبطية على أسبوع الآلام.", "Pascha", "Aramaic"),
    ("الميطانية", "تعني تغيير الفكر أو التوبة. وتُستخدم عملياً للتعبير عن السجود ومطانيات التوبة أو الاحترام.", "Metanoia", "Greek"),
    ("الدسقولية", "تعاليم الرسل وقوانينهم التي تنظم الحياة الكنسية.", "Didascalia", "Greek"),
    ("البارقليط", "الروح القدس المعزي، المحامي والمشير.", "Paraclete", "Greek"),
    ("اللوغوس", "الكلمة، وهو لقب الأقنوم الثاني (الابن) كما جاء في إنجيل يوحنا.", "Logos", "Greek"),
]

print("Inserting terms...")
for term in theological_terms:
    cursor.execute(
        'INSERT INTO terms (term, definition, root, language) VALUES (?, ?, ?, ?)',
        term
    )

conn.commit()
conn.close()

print(f"Coptic Lexicon database successfully created at {db_path} with {len(theological_terms)} core terms!")
