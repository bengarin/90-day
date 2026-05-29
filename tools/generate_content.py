#!/usr/bin/env python3
"""
Content generator for the "English Coach 90" app.

Produces assets/data/*.json with REAL content for all 90 days:
  - days.json      90 days across 3 phases / 13 weeks
  - words.json     ~2000 words (~22 per day), Oxford 3000 priority
  - sentences.json ~1000 sentences (~11 per day)
  - tasks.json     540 tasks (6 per day) with Arabic labels & instructions
  - phases.json    3 phases

Run from repo root:
    python3 tools/generate_content.py
"""

import json
import os
import random
from pathlib import Path

random.seed(42)

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "data"
OUT.mkdir(parents=True, exist_ok=True)

# ------------------------------------------------------------------
# Phases (3) & week→topic plan (13 weeks)
# ------------------------------------------------------------------
PHASES = [
    {"id": 1, "name_ar": "المرحلة الأساسية", "day_start": 1,  "day_end": 30,
     "description": "تأسيس قوي: تحية، تعريف، أرقام، عائلة، روتين، بيت."},
    {"id": 2, "name_ar": "مرحلة التطوير",   "day_start": 31, "day_end": 60,
     "description": "توسيع: طعام، تسوّق، اتجاهات، صحة، عمل، مواصلات."},
    {"id": 3, "name_ar": "مرحلة الطلاقة",   "day_start": 61, "day_end": 90,
     "description": "طلاقة: سفر، مقابلة عمل، آراء، قصص، خطط مستقبلية."},
]

# Each entry = (week_no, phase_id, days, topic_key, topic_en, topic_ar_pretty)
WEEKS = [
    (1,  1, range(1,  8),  "greetings",   "Greetings & Introductions", "التحية والتعريف بالنفس"),
    (2,  1, range(8,  15), "numbers",     "Numbers, Time & Days",       "الأرقام والوقت والأيام"),
    (3,  1, range(15, 22), "family",      "Family & People",            "العائلة والأشخاص"),
    (4,  1, range(22, 29), "routine",     "Daily Routine",              "الروتين اليومي"),
    (5,  1, range(29, 31), "home_a",      "Home & Rooms",               "البيت والغرف"),    # 2 days end of phase 1
    (5,  2, range(31, 36), "home_b",      "Home & Furniture",           "البيت والأثاث"),   # 5 days start of phase 2
    (6,  2, range(36, 43), "food",        "Food & Restaurant",          "الطعام والمطعم"),
    (7,  2, range(43, 50), "shopping",    "Shopping & Clothes",         "التسوق والملابس"),
    (8,  2, range(50, 57), "directions",  "Directions & City",          "الاتجاهات والمدينة"),
    (9,  2, range(57, 61), "health_a",    "Health & Body",              "الصحة والجسم"),    # end phase 2
    (9,  3, range(61, 64), "health_b",    "At the Doctor",              "عند الطبيب"),      # start phase 3
    (10, 3, range(64, 71), "work",        "Work & Office",              "العمل والمكتب"),
    (11, 3, range(71, 78), "communication","Phone, Email & Interview",  "الهاتف والبريد والمقابلة"),
    (12, 3, range(78, 85), "opinions",    "Opinions & Past Stories",    "الآراء وقصص الماضي"),
    (13, 3, range(85, 91), "future",      "Future Plans & Review",      "خطط المستقبل والمراجعة"),
]

# ------------------------------------------------------------------
# Per-topic word banks
# Each word tuple = (word_en, ipa, meaning_ar)
# Hand-curated; IPA uses approximate broad transcription.
# ------------------------------------------------------------------

TOPIC_WORDS = {
"greetings": [
    ("hello","həˈloʊ","مرحباً"),("hi","haɪ","مرحباً (غير رسمي)"),("hey","heɪ","يا (نداء)"),
    ("good","gʊd","جيد"),("morning","ˈmɔːrnɪŋ","صباح"),("afternoon","ˌæftərˈnuːn","بعد الظهر"),
    ("evening","ˈiːvnɪŋ","مساء"),("night","naɪt","ليلة"),("welcome","ˈwelkəm","أهلاً وسهلاً"),
    ("name","neɪm","اسم"),("my","maɪ","ـي (ملكي)"),("your","jɔːr","ـك (ملكي)"),
    ("his","hɪz","ـه"),("her","hɜːr","ـها"),("our","ˈaʊər","ـنا"),
    ("their","ðeər","ـهم"),("nice","naɪs","لطيف"),("meet","miːt","يقابل"),
    ("you","juː","أنت"),("I","aɪ","أنا"),("am","æm","أكون"),
    ("are","ɑːr","تكون/يكونون"),("is","ɪz","يكون/تكون"),("how","haʊ","كيف"),
    ("what","wɒt","ماذا"),("where","weər","أين"),("when","wen","متى"),
    ("from","frɒm","من"),("country","ˈkʌntri","بلد"),("city","ˈsɪti","مدينة"),
    ("Morocco","məˈrɒkəʊ","المغرب"),("Moroccan","məˈrɒkən","مغربي"),("language","ˈlæŋɡwɪdʒ","لغة"),
    ("English","ˈɪŋɡlɪʃ","الإنجليزية"),("Arabic","ˈærəbɪk","العربية"),("French","frentʃ","الفرنسية"),
    ("speak","spiːk","يتحدث"),("understand","ˌʌndərˈstænd","يفهم"),("yes","jes","نعم"),
    ("no","nəʊ","لا"),("please","pliːz","من فضلك"),("thanks","θæŋks","شكراً"),
    ("thank","θæŋk","يشكر"),("sorry","ˈsɒri","آسف"),("excuse","ɪkˈskjuːz","المعذرة"),
    ("friend","frend","صديق"),("teacher","ˈtiːtʃər","معلم"),("student","ˈstuːdənt","طالب"),
    ("person","ˈpɜːrsən","شخص"),("Mr","ˈmɪstər","السيد"),("Mrs","ˈmɪsɪz","السيدة"),
    ("how are you","haʊ ɑːr juː","كيف حالك"),("fine","faɪn","بخير"),("great","ɡreɪt","عظيم"),
    ("okay","ˈoʊˈkeɪ","حسناً"),("bad","bæd","سيء"),("tired","ˈtaɪərd","متعب"),
    ("happy","ˈhæpi","سعيد"),("sad","sæd","حزين"),("see","siː","يرى"),
    ("later","ˈleɪtər","لاحقاً"),("goodbye","ɡʊdˈbaɪ","وداعاً"),("bye","baɪ","مع السلامة"),
    ("again","əˈɡen","مرة أخرى"),("hello there","həˈloʊ ðeər","أهلاً هناك"),
    ("greet","ɡriːt","يحيي"),("introduce","ˌɪntrəˈduːs","يقدم/يعرّف"),
    ("polite","pəˈlaɪt","مهذب"),("formal","ˈfɔːrməl","رسمي"),("informal","ɪnˈfɔːrməl","غير رسمي"),
    ("address","əˈdres","عنوان"),("phone","foʊn","هاتف"),("email","ˈiːmeɪl","بريد إلكتروني"),
    ("nationality","ˌnæʃəˈnæləti","جنسية"),("native","ˈneɪtɪv","ابن البلد/الأصلي"),
    ("foreign","ˈfɒrən","أجنبي"),("born","bɔːrn","مولود"),("live","lɪv","يعيش"),
    ("study","ˈstʌdi","يدرس"),("work","wɜːrk","يعمل"),("today","təˈdeɪ","اليوم"),
    ("here","hɪər","هنا"),("there","ðeər","هناك"),("very","ˈveri","جداً"),
    ("really","ˈriːəli","حقاً"),("too","tuː","أيضاً"),("also","ˈɔːlsoʊ","كذلك"),
    ("everyone","ˈevriwʌn","كل واحد"),("everybody","ˈevribɒdi","كل شخص"),
    ("class","klɑːs","صف/درس"),("school","skuːl","مدرسة"),("hi everyone","haɪ ˈevriwʌn","مرحباً بالجميع"),
    ("first","fɜːrst","الأول"),("last","læst","الأخير"),("nickname","ˈnɪkneɪm","لقب"),
    ("call","kɔːl","ينادي/يتصل"),("repeat","rɪˈpiːt","يكرر"),("slowly","ˈsloʊli","ببطء"),
    ("loud","laʊd","بصوت عالٍ"),("clear","klɪər","واضح"),("listen","ˈlɪsən","يستمع"),
    ("ask","æsk","يسأل"),("answer","ˈænsər","يجيب"),("question","ˈkwestʃən","سؤال"),
    ("about","əˈbaʊt","عن"),("with","wɪð","مع"),("for","fɔːr","لـ"),
    ("to","tuː","إلى"),("of","ɒv","من/لـ"),("in","ɪn","في"),
    ("on","ɒn","على"),("at","æt","عند/في"),("be","biː","يكون"),
    ("do","duː","يفعل"),("have","hæv","يملك"),("can","kæn","يستطيع"),
    ("want","wɒnt","يريد"),("need","niːd","يحتاج"),("like","laɪk","يحب/مثل"),
    ("know","noʊ","يعرف"),("think","θɪŋk","يعتقد"),("say","seɪ","يقول"),
    ("tell","tel","يخبر"),("learn","lɜːrn","يتعلم"),("practice","ˈpræktɪs","يتدرب"),
    ("hour","ˈaʊər","ساعة"),("minute","ˈmɪnɪt","دقيقة"),("now","naʊ","الآن"),
    ("welcome back","ˈwelkəm bæk","أهلاً بعودتك"),("see you","siː juː","أراك لاحقاً"),
    ("take care","teɪk keər","اعتنِ بنفسك"),("good luck","gʊd lʌk","حظاً موفقاً"),
],

"numbers": [
    ("zero","ˈzɪəroʊ","صفر"),("one","wʌn","واحد"),("two","tuː","اثنان"),("three","θriː","ثلاثة"),
    ("four","fɔːr","أربعة"),("five","faɪv","خمسة"),("six","sɪks","ستة"),("seven","ˈsevən","سبعة"),
    ("eight","eɪt","ثمانية"),("nine","naɪn","تسعة"),("ten","ten","عشرة"),
    ("eleven","ɪˈlevən","أحد عشر"),("twelve","twelv","اثنا عشر"),("thirteen","ˌθɜːrˈtiːn","ثلاثة عشر"),
    ("fourteen","ˌfɔːrˈtiːn","أربعة عشر"),("fifteen","ˌfɪfˈtiːn","خمسة عشر"),
    ("sixteen","ˌsɪksˈtiːn","ستة عشر"),("seventeen","ˌsevənˈtiːn","سبعة عشر"),
    ("eighteen","ˌeɪˈtiːn","ثمانية عشر"),("nineteen","ˌnaɪnˈtiːn","تسعة عشر"),
    ("twenty","ˈtwenti","عشرون"),("thirty","ˈθɜːrti","ثلاثون"),("forty","ˈfɔːrti","أربعون"),
    ("fifty","ˈfɪfti","خمسون"),("sixty","ˈsɪksti","ستون"),("seventy","ˈsevənti","سبعون"),
    ("eighty","ˈeɪti","ثمانون"),("ninety","ˈnaɪnti","تسعون"),("hundred","ˈhʌndrəd","مئة"),
    ("thousand","ˈθaʊzənd","ألف"),("million","ˈmɪljən","مليون"),
    ("first","fɜːrst","الأول"),("second","ˈsekənd","الثاني/ثانية"),("third","θɜːrd","الثالث"),
    ("fourth","fɔːrθ","الرابع"),("fifth","fɪfθ","الخامس"),("number","ˈnʌmbər","رقم"),
    ("digit","ˈdɪdʒɪt","رقم خانة"),("count","kaʊnt","يعد"),("plus","plʌs","زائد"),
    ("minus","ˈmaɪnəs","ناقص"),("times","taɪmz","ضرب"),("equal","ˈiːkwəl","يساوي"),
    ("half","hɑːf","نصف"),("quarter","ˈkwɔːrtər","ربع"),
    ("Monday","ˈmʌndeɪ","الإثنين"),("Tuesday","ˈtuːzdeɪ","الثلاثاء"),
    ("Wednesday","ˈwenzdeɪ","الأربعاء"),("Thursday","ˈθɜːrzdeɪ","الخميس"),
    ("Friday","ˈfraɪdeɪ","الجمعة"),("Saturday","ˈsætərdeɪ","السبت"),("Sunday","ˈsʌndeɪ","الأحد"),
    ("week","wiːk","أسبوع"),("weekend","ˈwiːkend","عطلة نهاية الأسبوع"),
    ("weekday","ˈwiːkdeɪ","يوم عمل"),("today","təˈdeɪ","اليوم"),("tomorrow","təˈmɒroʊ","غداً"),
    ("yesterday","ˈjestərdeɪ","أمس"),("day","deɪ","يوم"),("night","naɪt","ليلة"),
    ("morning","ˈmɔːrnɪŋ","صباح"),("noon","nuːn","الظهيرة"),("evening","ˈiːvnɪŋ","مساء"),
    ("midnight","ˈmɪdnaɪt","منتصف الليل"),
    ("January","ˈdʒænjueri","يناير"),("February","ˈfebrueri","فبراير"),("March","mɑːrtʃ","مارس"),
    ("April","ˈeɪprəl","أبريل"),("May","meɪ","مايو"),("June","dʒuːn","يونيو"),
    ("July","dʒʊˈlaɪ","يوليو"),("August","ˈɔːɡəst","أغسطس"),("September","sepˈtembər","سبتمبر"),
    ("October","ɒkˈtoʊbər","أكتوبر"),("November","noʊˈvembər","نوفمبر"),("December","dɪˈsembər","ديسمبر"),
    ("month","mʌnθ","شهر"),("year","jɪər","سنة"),("season","ˈsiːzən","فصل"),
    ("spring","sprɪŋ","الربيع"),("summer","ˈsʌmər","الصيف"),("autumn","ˈɔːtəm","الخريف"),
    ("winter","ˈwɪntər","الشتاء"),("hour","ˈaʊər","ساعة"),("minute","ˈmɪnɪt","دقيقة"),
    ("second","ˈsekənd","ثانية"),("time","taɪm","وقت"),("clock","klɒk","ساعة جدارية"),
    ("watch","wɒtʃ","ساعة يد"),("calendar","ˈkælɪndər","تقويم"),("date","deɪt","تاريخ"),
    ("birthday","ˈbɜːrθdeɪ","عيد ميلاد"),("age","eɪdʒ","عمر"),("old","oʊld","قديم/مسن"),
    ("young","jʌŋ","صغير السن"),("early","ˈɜːrli","مبكر"),("late","leɪt","متأخر"),
    ("on time","ɒn taɪm","في الموعد"),("o'clock","əˈklɒk","تمام الساعة"),
    ("a.m.","eɪ em","صباحاً"),("p.m.","piː em","مساءً"),("noon time","nuːn taɪm","وقت الظهر"),
    ("schedule","ˈʃedʒuːl","جدول"),("daily","ˈdeɪli","يومي"),("weekly","ˈwiːkli","أسبوعي"),
    ("monthly","ˈmʌnθli","شهري"),("yearly","ˈjɪərli","سنوي"),("often","ˈɒfən","غالباً"),
    ("sometimes","ˈsʌmtaɪmz","أحياناً"),("never","ˈnevər","أبداً"),("always","ˈɔːlweɪz","دائماً"),
    ("usually","ˈjuːʒəli","عادةً"),("rarely","ˈreərli","نادراً"),
    ("before","bɪˈfɔːr","قبل"),("after","ˈæftər","بعد"),("during","ˈdjʊərɪŋ","خلال"),
    ("until","ʌnˈtɪl","حتى"),("since","sɪns","منذ"),("ago","əˈɡoʊ","مضى"),
    ("soon","suːn","قريباً"),("now","naʊ","الآن"),("then","ðen","حينها"),
    ("next","nekst","التالي"),("last week","læst wiːk","الأسبوع الماضي"),
    ("next week","nekst wiːk","الأسبوع القادم"),("each","iːtʃ","كل (واحد)"),
    ("every","ˈevri","كل"),("any","ˈeni","أي"),
    ("how many","haʊ ˈmeni","كم عدد"),("how much","haʊ mʌtʃ","كم (للكمية)"),
    ("price","praɪs","سعر"),("cost","kɒst","يكلف"),
    ("money","ˈmʌni","نقود"),("dollar","ˈdɒlər","دولار"),("euro","ˈjʊəroʊ","يورو"),
    ("dirham","ˈdɪərhæm","درهم"),("change","tʃeɪndʒ","فكة/يغير"),("bill","bɪl","فاتورة/ورقة نقدية"),
    ("coin","kɔɪn","قطعة نقدية"),("free","friː","مجاني/حر"),("cheap","tʃiːp","رخيص"),
    ("expensive","ɪkˈspensɪv","غالٍ"),
],

"family": [
    ("family","ˈfæməli","عائلة"),("parent","ˈpeərənt","والد/والدة"),("father","ˈfɑːðər","الأب"),
    ("dad","dæd","بابا"),("mother","ˈmʌðər","الأم"),("mom","mɒm","ماما"),
    ("brother","ˈbrʌðər","الأخ"),("sister","ˈsɪstər","الأخت"),("son","sʌn","الابن"),
    ("daughter","ˈdɔːtər","الابنة"),("child","tʃaɪld","طفل"),("children","ˈtʃɪldrən","أطفال"),
    ("baby","ˈbeɪbi","رضيع"),("kid","kɪd","طفل"),("husband","ˈhʌzbənd","الزوج"),
    ("wife","waɪf","الزوجة"),("married","ˈmærid","متزوج"),("single","ˈsɪŋɡəl","أعزب"),
    ("engaged","ɪnˈɡeɪdʒd","مخطوب"),("wedding","ˈwedɪŋ","حفل زفاف"),
    ("uncle","ˈʌŋkəl","العم/الخال"),("aunt","ɑːnt","العمة/الخالة"),
    ("cousin","ˈkʌzən","ابن العم/الخال"),("nephew","ˈnefjuː","ابن الأخ"),
    ("niece","niːs","ابنة الأخ"),("grandfather","ˈɡrænfɑːðər","الجد"),
    ("grandmother","ˈɡrænmʌðər","الجدة"),("grandson","ˈɡrænsʌn","الحفيد"),
    ("granddaughter","ˈɡrændɔːtər","الحفيدة"),("grandparent","ˈɡrænpeərənt","الجد/الجدة"),
    ("relative","ˈrelətɪv","قريب"),("man","mæn","رجل"),("woman","ˈwʊmən","امرأة"),
    ("boy","bɔɪ","ولد"),("girl","ɡɜːrl","فتاة"),("guy","ɡaɪ","شاب"),
    ("lady","ˈleɪdi","سيدة"),("gentleman","ˈdʒentəlmən","رجل محترم"),
    ("neighbor","ˈneɪbər","الجار"),("friend","frend","صديق"),("best friend","best frend","أعز صديق"),
    ("girlfriend","ˈɡɜːrlfrend","الصديقة"),("boyfriend","ˈbɔɪfrend","الصديق"),
    ("partner","ˈpɑːrtnər","الشريك"),("twin","twɪn","توأم"),("older","ˈoʊldər","أكبر سناً"),
    ("younger","ˈjʌŋɡər","أصغر سناً"),("oldest","ˈoʊldɪst","الأكبر"),("youngest","ˈjʌŋɡɪst","الأصغر"),
    ("middle","ˈmɪdəl","الأوسط"),("only child","ˈoʊnli tʃaɪld","الطفل الوحيد"),
    ("look like","lʊk laɪk","يشبه"),("tall","tɔːl","طويل"),("short","ʃɔːrt","قصير"),
    ("kind","kaɪnd","لطيف"),("strict","strɪkt","صارم"),("funny","ˈfʌni","مضحك"),
    ("serious","ˈsɪəriəs","جاد"),("clever","ˈklevər","ذكي"),("smart","smɑːrt","ذكي"),
    ("polite","pəˈlaɪt","مهذب"),("rude","ruːd","وقح"),("shy","ʃaɪ","خجول"),
    ("brave","breɪv","شجاع"),("calm","kɑːm","هادئ"),("nervous","ˈnɜːrvəs","قلِق"),
    ("love","lʌv","يحب/حب"),("care","keər","يهتم"),("help","help","يساعد"),
    ("share","ʃeər","يشارك"),("trust","trʌst","يثق"),("hug","hʌɡ","عناق"),
    ("kiss","kɪs","قبلة"),("visit","ˈvɪzɪt","يزور"),("stay","steɪ","يبقى"),
    ("argue","ˈɑːrɡjuː","يجادل"),("agree","əˈɡriː","يوافق"),("disagree","ˌdɪsəˈɡriː","لا يوافق"),
    ("home","hoʊm","المنزل"),("house","haʊs","بيت"),("apartment","əˈpɑːrtmənt","شقة"),
    ("village","ˈvɪlɪdʒ","قرية"),("town","taʊn","بلدة"),("city","ˈsɪti","مدينة"),
    ("country","ˈkʌntri","بلد"),("flag","flæɡ","علم"),("name day","neɪm deɪ","عيد الاسم"),
    ("party","ˈpɑːrti","حفلة"),("guest","ɡest","ضيف"),("invite","ɪnˈvaɪt","يدعو"),
    ("celebrate","ˈseləbreɪt","يحتفل"),("birthday party","ˈbɜːrθdeɪ ˈpɑːrti","حفلة عيد ميلاد"),
    ("photo","ˈfoʊtoʊ","صورة"),("album","ˈælbəm","ألبوم"),
    ("history","ˈhɪstəri","تاريخ"),("memory","ˈmeməri","ذكرى"),("childhood","ˈtʃaɪldhʊd","الطفولة"),
    ("youth","juːθ","الشباب"),("adult","ˈædʌlt","بالغ"),("teenager","ˈtiːneɪdʒər","مراهق"),
    ("retire","rɪˈtaɪər","يتقاعد"),("be born","biː bɔːrn","يولد"),
    ("grow up","ɡroʊ ʌp","يكبر"),("get married","ɡet ˈmærid","يتزوج"),
    ("have a child","hæv ə tʃaɪld","يرزق بطفل"),
    ("daughter-in-law","ˈdɔːtər ɪn lɔː","الكنّة"),("son-in-law","sʌn ɪn lɔː","الصِّهر"),
    ("mother-in-law","ˈmʌðər ɪn lɔː","حماة"),("father-in-law","ˈfɑːðər ɪn lɔː","حمو"),
    ("close family","kloʊs ˈfæməli","عائلة قريبة"),("far family","fɑːr ˈfæməli","عائلة بعيدة"),
    ("religion","rɪˈlɪdʒən","دين"),("culture","ˈkʌltʃər","ثقافة"),("tradition","trəˈdɪʃən","تقليد"),
    ("relative visit","ˈrelətɪv ˈvɪzɪt","زيارة الأقارب"),("cook together","kʊk təˈɡeðər","نطبخ معاً"),
],

"routine": [
    ("wake up","weɪk ʌp","يستيقظ"),("get up","ɡet ʌp","ينهض"),("sleep","sliːp","ينام"),
    ("dream","driːm","يحلم"),("alarm","əˈlɑːrm","المنبه"),("snooze","snuːz","يؤجل المنبه"),
    ("bed","bed","سرير"),("pillow","ˈpɪloʊ","وسادة"),("blanket","ˈblæŋkɪt","بطانية"),
    ("shower","ˈʃaʊər","يستحم/دش"),("bath","bɑːθ","حمام"),("brush","brʌʃ","يفرشي"),
    ("teeth","tiːθ","الأسنان"),("toothbrush","ˈtuːθbrʌʃ","فرشاة أسنان"),
    ("toothpaste","ˈtuːθpeɪst","معجون أسنان"),("soap","soʊp","صابون"),("towel","ˈtaʊəl","منشفة"),
    ("face","feɪs","الوجه"),("hair","heər","الشعر"),("comb","koʊm","مشط"),
    ("dress","dres","يلبس/فستان"),("clothes","kloʊðz","ملابس"),("shirt","ʃɜːrt","قميص"),
    ("trousers","ˈtraʊzərz","بنطلون"),("shoes","ʃuːz","حذاء"),("socks","sɒks","جوارب"),
    ("breakfast","ˈbrekfəst","فطور"),("lunch","lʌntʃ","غداء"),("dinner","ˈdɪnər","عشاء"),
    ("eat","iːt","يأكل"),("drink","drɪŋk","يشرب"),("coffee","ˈkɒfi","قهوة"),
    ("tea","tiː","شاي"),("milk","mɪlk","حليب"),("water","ˈwɔːtər","ماء"),
    ("bread","bred","خبز"),("egg","eɡ","بيضة"),("yogurt","ˈjɒɡərt","لبن زبادي"),
    ("leave","liːv","يغادر"),("go","ɡoʊ","يذهب"),("come","kʌm","يأتي"),
    ("arrive","əˈraɪv","يصل"),("travel","ˈtrævəl","يسافر"),("walk","wɔːk","يمشي"),
    ("run","rʌn","يجري"),("drive","draɪv","يقود"),("ride","raɪd","يركب"),
    ("bike","baɪk","دراجة"),("car","kɑːr","سيارة"),("bus","bʌs","حافلة"),
    ("train","treɪn","قطار"),("taxi","ˈtæksi","سيارة أجرة"),("metro","ˈmetroʊ","مترو"),
    ("work","wɜːrk","يعمل"),("study","ˈstʌdi","يدرس"),("read","riːd","يقرأ"),
    ("write","raɪt","يكتب"),("listen","ˈlɪsən","يستمع"),("watch","wɒtʃ","يشاهد"),
    ("TV","ˌtiːˈviː","تلفاز"),("phone","foʊn","هاتف"),("call","kɔːl","يتصل"),
    ("text","tekst","رسالة نصية"),("message","ˈmesɪdʒ","رسالة"),("email","ˈiːmeɪl","بريد"),
    ("internet","ˈɪntərnet","إنترنت"),("computer","kəmˈpjuːtər","حاسوب"),("laptop","ˈlæptɒp","لابتوب"),
    ("homework","ˈhoʊmwɜːrk","واجب منزلي"),("exercise","ˈeksərsaɪz","يتمرّن/تمرين"),
    ("gym","dʒɪm","نادي رياضي"),("rest","rest","يرتاح"),("nap","næp","قيلولة"),
    ("relax","rɪˈlæks","يرتاح ذهنياً"),("cook","kʊk","يطبخ"),("clean","kliːn","ينظف"),
    ("wash","wɒʃ","يغسل"),("iron","ˈaɪərn","يكوي"),("shop","ʃɒp","يتسوّق"),
    ("market","ˈmɑːrkɪt","سوق"),("store","stɔːr","متجر"),("supermarket","ˈsuːpərmɑːrkɪt","سوبرماركت"),
    ("buy","baɪ","يشتري"),("pay","peɪ","يدفع"),("spend","spend","يقضي/ينفق"),
    ("save","seɪv","يدّخر/يحفظ"),("plan","plæn","يخطط/خطة"),("schedule","ˈʃedʒuːl","جدول"),
    ("morning routine","ˈmɔːrnɪŋ ruːˈtiːn","روتين الصباح"),("night routine","naɪt ruːˈtiːn","روتين الليل"),
    ("usually","ˈjuːʒəli","عادة"),("often","ˈɒfən","غالباً"),("sometimes","ˈsʌmtaɪmz","أحياناً"),
    ("never","ˈnevər","أبداً"),("always","ˈɔːlweɪz","دائماً"),
    ("hurry","ˈhɜːri","يستعجل"),("ready","ˈredi","جاهز"),("late","leɪt","متأخر"),
    ("early","ˈɜːrli","مبكر"),("tired","ˈtaɪərd","متعب"),("hungry","ˈhʌŋɡri","جائع"),
    ("thirsty","ˈθɜːrsti","عطشان"),("busy","ˈbɪzi","مشغول"),("free time","friː taɪm","وقت فراغ"),
    ("hobby","ˈhɒbi","هواية"),("music","ˈmjuːzɪk","موسيقى"),("song","sɒŋ","أغنية"),
    ("play","pleɪ","يلعب"),("game","ɡeɪm","لعبة"),("video","ˈvɪdioʊ","فيديو"),
    ("movie","ˈmuːvi","فيلم"),("book","bʊk","كتاب"),("newspaper","ˈnuːzpeɪpər","جريدة"),
    ("magazine","ˌmæɡəˈziːn","مجلة"),("notebook","ˈnoʊtbʊk","دفتر"),("pen","pen","قلم"),
    ("paper","ˈpeɪpər","ورق"),("pray","preɪ","يصلي"),("mosque","mɒsk","مسجد"),
    ("call mom","kɔːl mɒm","يتصل بأمه"),("see friends","siː frendz","يرى أصدقاءه"),
    ("daily","ˈdeɪli","يومي"),("habit","ˈhæbɪt","عادة"),("change a habit","tʃeɪndʒ ə ˈhæbɪt","يغير عادة"),
],

"home_a": [
    ("home","hoʊm","المنزل"),("house","haʊs","بيت"),("apartment","əˈpɑːrtmənt","شقة"),
    ("flat","flæt","شقة (بريطانية)"),("building","ˈbɪldɪŋ","مبنى"),("floor","flɔːr","طابق"),
    ("ground floor","ɡraʊnd flɔːr","الطابق الأرضي"),("upstairs","ˌʌpˈsteərz","الطابق العلوي"),
    ("downstairs","ˌdaʊnˈsteərz","الطابق السفلي"),
    ("room","ruːm","غرفة"),("living room","ˈlɪvɪŋ ruːm","غرفة المعيشة"),
    ("bedroom","ˈbedruːm","غرفة النوم"),("kitchen","ˈkɪtʃən","المطبخ"),
    ("bathroom","ˈbɑːθruːm","الحمام"),("toilet","ˈtɔɪlət","المرحاض"),
    ("garage","ˈɡærɑːʒ","الكراج"),("garden","ˈɡɑːrdən","الحديقة"),("balcony","ˈbælkəni","الشرفة"),
    ("door","dɔːr","باب"),("window","ˈwɪndoʊ","نافذة"),("wall","wɔːl","حائط"),
    ("ceiling","ˈsiːlɪŋ","سقف"),("roof","ruːf","سطح"),("stairs","steərz","درج"),
    ("elevator","ˈeləveɪtər","مصعد"),("key","kiː","مفتاح"),("lock","lɒk","قفل"),
    ("light","laɪt","ضوء"),("lamp","læmp","مصباح"),("switch","swɪtʃ","مفتاح كهرباء"),
    ("plug","plʌɡ","قابس"),("socket","ˈsɒkɪt","مقبس"),("electricity","ɪˌlekˈtrɪsəti","كهرباء"),
],

"home_b": [
    ("furniture","ˈfɜːrnɪtʃər","أثاث"),("bed","bed","سرير"),("pillow","ˈpɪloʊ","وسادة"),
    ("sheet","ʃiːt","شرشف"),("blanket","ˈblæŋkɪt","بطانية"),("mattress","ˈmætrəs","مرتبة"),
    ("wardrobe","ˈwɔːrdroʊb","خزانة ملابس"),("closet","ˈklɒzɪt","خزانة"),("drawer","drɔːr","درج"),
    ("shelf","ʃelf","رف"),("desk","desk","مكتب"),("chair","tʃeər","كرسي"),
    ("armchair","ˈɑːrmtʃeər","كرسي مريح"),("sofa","ˈsoʊfə","أريكة"),("table","ˈteɪbəl","طاولة"),
    ("dining table","ˈdaɪnɪŋ ˈteɪbəl","طاولة الطعام"),("carpet","ˈkɑːrpɪt","سجادة"),
    ("rug","rʌɡ","بساط"),("curtain","ˈkɜːrtən","ستارة"),("mirror","ˈmɪrər","مرآة"),
    ("clock","klɒk","ساعة"),("picture","ˈpɪktʃər","صورة"),("frame","freɪm","إطار"),
    ("fridge","frɪdʒ","ثلاجة"),("freezer","ˈfriːzər","فريزر"),("oven","ˈʌvən","فرن"),
    ("microwave","ˈmaɪkrəweɪv","مايكرويف"),("stove","stoʊv","موقد"),("sink","sɪŋk","حوض"),
    ("tap","tæp","صنبور"),("kettle","ˈketəl","غلاية"),("toaster","ˈtoʊstər","محمصة"),
    ("dishwasher","ˈdɪʃwɒʃər","غسالة صحون"),("washing machine","ˈwɒʃɪŋ məˈʃiːn","غسالة"),
    ("vacuum","ˈvækjuːm","مكنسة كهربائية"),("broom","bruːm","مكنسة"),("mop","mɒp","ممسحة"),
    ("dustbin","ˈdʌstbɪn","سلة قمامة"),("plate","pleɪt","صحن"),("bowl","boʊl","سلطانية"),
    ("cup","kʌp","كوب"),("glass","ɡlɑːs","قدح زجاج"),("fork","fɔːrk","شوكة"),
    ("knife","naɪf","سكين"),("spoon","spuːn","ملعقة"),("pot","pɒt","قدر"),
    ("pan","pæn","مقلاة"),("kitchen towel","ˈkɪtʃən ˈtaʊəl","فوطة المطبخ"),
    ("soap","soʊp","صابون"),("shampoo","ʃæmˈpuː","شامبو"),("toilet paper","ˈtɔɪlət ˈpeɪpər","ورق تواليت"),
    ("clean","kliːn","ينظف"),("dirty","ˈdɜːrti","متسخ"),("tidy","ˈtaɪdi","مرتب"),
    ("messy","ˈmesi","فوضوي"),("rent","rent","يستأجر/إيجار"),("own","oʊn","يمتلك"),
    ("buy a house","baɪ ə haʊs","يشتري بيتاً"),("move","muːv","ينتقل"),
],

"food": [
    ("food","fuːd","طعام"),("breakfast","ˈbrekfəst","فطور"),("lunch","lʌntʃ","غداء"),
    ("dinner","ˈdɪnər","عشاء"),("meal","miːl","وجبة"),("snack","snæk","وجبة خفيفة"),
    ("dessert","dɪˈzɜːrt","حلوى"),("menu","ˈmenjuː","قائمة"),("restaurant","ˈrestərɑːnt","مطعم"),
    ("cafe","ˈkæfeɪ","مقهى"),("waiter","ˈweɪtər","نادل"),("waitress","ˈweɪtrəs","نادلة"),
    ("chef","ʃef","طاهٍ"),("kitchen","ˈkɪtʃən","مطبخ"),("table","ˈteɪbəl","طاولة"),
    ("order","ˈɔːrdər","يطلب"),("bill","bɪl","فاتورة"),("tip","tɪp","بقشيش"),
    ("reservation","ˌrezərˈveɪʃən","حجز"),("delivery","dɪˈlɪvəri","توصيل"),
    ("takeaway","ˈteɪkəweɪ","سفري"),
    ("bread","bred","خبز"),("rice","raɪs","أرز"),("pasta","ˈpɑːstə","معكرونة"),
    ("noodle","ˈnuːdəl","نودلز"),("salad","ˈsæləd","سلطة"),("soup","suːp","شوربة"),
    ("sandwich","ˈsænwɪdʒ","سندويش"),("pizza","ˈpiːtsə","بيتزا"),("burger","ˈbɜːrɡər","برغر"),
    ("egg","eɡ","بيض"),("cheese","tʃiːz","جبن"),("butter","ˈbʌtər","زبدة"),
    ("yogurt","ˈjɒɡərt","زبادي"),("milk","mɪlk","حليب"),("juice","dʒuːs","عصير"),
    ("water","ˈwɔːtər","ماء"),("tea","tiː","شاي"),("coffee","ˈkɒfi","قهوة"),
    ("soda","ˈsoʊdə","صودا"),("sugar","ˈʃʊɡər","سكر"),("salt","sɔːlt","ملح"),
    ("pepper","ˈpepər","فلفل"),("oil","ɔɪl","زيت"),("vinegar","ˈvɪnɪɡər","خل"),
    ("chicken","ˈtʃɪkɪn","دجاج"),("beef","biːf","لحم بقر"),("lamb","læm","لحم خروف"),
    ("fish","fɪʃ","سمك"),("shrimp","ʃrɪmp","جمبري"),("meat","miːt","لحم"),
    ("vegetable","ˈvedʒtəbəl","خضار"),("tomato","təˈmeɪtoʊ","طماطم"),("potato","pəˈteɪtoʊ","بطاطس"),
    ("onion","ˈʌnjən","بصل"),("garlic","ˈɡɑːrlɪk","ثوم"),("carrot","ˈkærət","جزر"),
    ("cucumber","ˈkjuːkʌmbər","خيار"),("lettuce","ˈletɪs","خس"),("pepper veg","ˈpepər vedʒ","فلفل أخضر"),
    ("fruit","fruːt","فاكهة"),("apple","ˈæpəl","تفاح"),("banana","bəˈnɑːnə","موز"),
    ("orange","ˈɒrɪndʒ","برتقال"),("lemon","ˈlemən","ليمون"),("grape","ɡreɪp","عنب"),
    ("strawberry","ˈstrɔːbəri","فراولة"),("watermelon","ˈwɔːtərmelən","بطيخ"),
    ("hot","hɒt","حار/ساخن"),("cold","koʊld","بارد"),("sweet","swiːt","حلو"),
    ("sour","ˈsaʊər","حامض"),("spicy","ˈspaɪsi","حار توابل"),("salty","ˈsɔːlti","مالح"),
    ("delicious","dɪˈlɪʃəs","لذيذ"),("tasty","ˈteɪsti","شهي"),("fresh","freʃ","طازج"),
    ("frozen","ˈfroʊzən","مجمد"),("cooked","kʊkt","مطبوخ"),("raw","rɔː","نيء"),
    ("hungry","ˈhʌŋɡri","جائع"),("thirsty","ˈθɜːrsti","عطشان"),("full","fʊl","شبعان"),
    ("try","traɪ","يجرب"),("taste","teɪst","يتذوّق"),("recipe","ˈresɪpi","وصفة"),
    ("ingredient","ɪnˈɡriːdiənt","مكوّن"),("portion","ˈpɔːrʃən","حصة"),("serve","sɜːrv","يقدم"),
    ("eat out","iːt aʊt","يأكل في الخارج"),("home cooking","hoʊm ˈkʊkɪŋ","طبخ بيتي"),
    ("vegetarian","ˌvedʒəˈteəriən","نباتي"),("vegan","ˈviːɡən","فيغان"),
    ("allergy","ˈælərdʒi","حساسية"),("nuts","nʌts","مكسرات"),("seafood","ˈsiːfuːd","طعام بحري"),
    ("dish","dɪʃ","طبق"),("starter","ˈstɑːrtər","المقبلات"),("main course","meɪn kɔːrs","الطبق الرئيسي"),
    ("can I have","kæn aɪ hæv","هل يمكنني الحصول على"),("the bill please","ðə bɪl pliːz","الفاتورة من فضلك"),
    ("for here","fɔːr hɪər","هنا"),("to go","tuː ɡoʊ","سفري"),
],

"shopping": [
    ("shop","ʃɒp","يتسوّق/متجر"),("shopping","ˈʃɒpɪŋ","تسوّق"),("store","stɔːr","متجر"),
    ("mall","mɔːl","مركز تسوق"),("market","ˈmɑːrkɪt","سوق"),("supermarket","ˈsuːpərmɑːrkɪt","سوبرماركت"),
    ("price","praɪs","سعر"),("cost","kɒst","يكلف"),("cheap","tʃiːp","رخيص"),
    ("expensive","ɪkˈspensɪv","غالٍ"),("discount","ˈdɪskaʊnt","خصم"),("sale","seɪl","تخفيضات"),
    ("offer","ˈɒfər","عرض"),("free","friː","مجاني"),("buy","baɪ","يشتري"),
    ("sell","sel","يبيع"),("pay","peɪ","يدفع"),("cash","kæʃ","نقد"),
    ("card","kɑːrd","بطاقة"),("credit card","ˈkredɪt kɑːrd","بطاقة ائتمان"),
    ("debit card","ˈdebɪt kɑːrd","بطاقة سحب"),("change","tʃeɪndʒ","فكة"),
    ("receipt","rɪˈsiːt","إيصال"),("bag","bæɡ","كيس"),("basket","ˈbɑːskɪt","سلة"),
    ("trolley","ˈtrɒli","عربة تسوّق"),("aisle","aɪl","ممر"),("queue","kjuː","طابور"),
    ("line","laɪn","صف"),("customer","ˈkʌstəmər","زبون"),("seller","ˈselər","بائع"),
    ("size","saɪz","مقاس"),("small","smɔːl","صغير"),("medium","ˈmiːdiəm","وسط"),
    ("large","lɑːrdʒ","كبير"),("extra large","ˈekstrə lɑːrdʒ","كبير جداً"),
    ("color","ˈkʌlər","لون"),("red","red","أحمر"),("blue","bluː","أزرق"),
    ("green","ɡriːn","أخضر"),("yellow","ˈjeloʊ","أصفر"),("black","blæk","أسود"),
    ("white","waɪt","أبيض"),("pink","pɪŋk","وردي"),("orange color","ˈɒrɪndʒ ˈkʌlər","برتقالي"),
    ("brown","braʊn","بني"),("grey","ɡreɪ","رمادي"),
    ("clothes","kloʊðz","ملابس"),("shirt","ʃɜːrt","قميص"),("t-shirt","ˈtiː ʃɜːrt","تي شيرت"),
    ("dress","dres","فستان"),("skirt","skɜːrt","تنورة"),("trousers","ˈtraʊzərz","بنطلون"),
    ("jeans","dʒiːnz","جينز"),("shorts","ʃɔːrts","شورت"),("jacket","ˈdʒækɪt","جاكيت"),
    ("coat","koʊt","معطف"),("sweater","ˈswetər","كنزة"),("hoodie","ˈhʊdi","هودي"),
    ("scarf","skɑːrf","وشاح"),("hat","hæt","قبعة"),("cap","kæp","كاب"),
    ("belt","belt","حزام"),("tie","taɪ","ربطة عنق"),("glove","ɡlʌv","قفاز"),
    ("sock","sɒk","جورب"),("shoe","ʃuː","حذاء"),("boot","buːt","حذاء طويل"),
    ("sandal","ˈsændəl","صندل"),("slipper","ˈslɪpər","شبشب"),("trainer","ˈtreɪnər","حذاء رياضي"),
    ("bag","bæɡ","حقيبة"),("backpack","ˈbækpæk","حقيبة ظهر"),("wallet","ˈwɒlɪt","محفظة"),
    ("watch","wɒtʃ","ساعة يد"),("glasses","ˈɡlɑːsɪz","نظارة"),("ring","rɪŋ","خاتم"),
    ("necklace","ˈnekləs","عقد"),("bracelet","ˈbreɪslət","سوار"),
    ("try on","traɪ ɒn","يجرب الملابس"),("fit","fɪt","يناسب"),("look","lʊk","يبدو"),
    ("nice","naɪs","لطيف"),("ugly","ˈʌɡli","قبيح"),("beautiful","ˈbjuːtəfəl","جميل"),
    ("brand","brænd","ماركة"),("quality","ˈkwɒləti","جودة"),("style","staɪl","أسلوب"),
    ("fashion","ˈfæʃən","موضة"),("new","njuː","جديد"),("old","oʊld","قديم"),
    ("return","rɪˈtɜːrn","يعيد"),("exchange","ɪksˈtʃeɪndʒ","يستبدل"),("refund","ˈriːfʌnd","استرجاع"),
    ("how much","haʊ mʌtʃ","بكم"),("any","ˈeni","أي"),("some","sʌm","بعض"),
    ("none","nʌn","لا شيء"),("only","ˈoʊnli","فقط"),
],

"directions": [
    ("street","striːt","شارع"),("road","roʊd","طريق"),("avenue","ˈævənjuː","جادة"),
    ("path","pɑːθ","ممر"),("corner","ˈkɔːrnər","زاوية"),("crossroad","ˈkrɒsroʊd","تقاطع"),
    ("traffic light","ˈtræfɪk laɪt","إشارة مرور"),("zebra crossing","ˈziːbrə ˈkrɒsɪŋ","ممر مشاة"),
    ("bridge","brɪdʒ","جسر"),("tunnel","ˈtʌnəl","نفق"),("roundabout","ˈraʊndəbaʊt","دوّار"),
    ("sidewalk","ˈsaɪdwɔːk","رصيف"),("park","pɑːrk","حديقة عامة"),("square","skweər","ساحة"),
    ("map","mæp","خريطة"),("GPS","ˌdʒiː piː ˈes","نظام تحديد المواقع"),
    ("direction","dɪˈrekʃən","اتجاه"),("north","nɔːrθ","شمال"),("south","saʊθ","جنوب"),
    ("east","iːst","شرق"),("west","west","غرب"),("right","raɪt","يمين"),
    ("left","left","يسار"),("straight","streɪt","مستقيم"),("ahead","əˈhed","للأمام"),
    ("back","bæk","للخلف"),("turn","tɜːrn","يدور/يلتفت"),("cross","krɒs","يعبر"),
    ("stop","stɒp","يقف"),("go","ɡoʊ","يذهب"),("come","kʌm","يأتي"),
    ("arrive","əˈraɪv","يصل"),("leave","liːv","يغادر"),("walk","wɔːk","يمشي"),
    ("near","nɪər","قريب"),("far","fɑːr","بعيد"),("next to","nekst tuː","بجانب"),
    ("opposite","ˈɒpəzɪt","مقابل"),("between","bɪˈtwiːn","بين"),("in front of","ɪn frʌnt əv","أمام"),
    ("behind","bɪˈhaɪnd","خلف"),("around","əˈraʊnd","حول"),("inside","ɪnˈsaɪd","داخل"),
    ("outside","ˌaʊtˈsaɪd","خارج"),("above","əˈbʌv","فوق"),("below","bɪˈloʊ","تحت"),
    ("city","ˈsɪti","مدينة"),("town","taʊn","بلدة"),("village","ˈvɪlɪdʒ","قرية"),
    ("downtown","ˈdaʊntaʊn","وسط البلد"),("center","ˈsentər","مركز"),("area","ˈeəriə","منطقة"),
    ("neighborhood","ˈneɪbərhʊd","حي"),("address","əˈdres","عنوان"),
    ("bank","bæŋk","بنك"),("post office","poʊst ˈɒfɪs","مكتب البريد"),("hospital","ˈhɒspɪtəl","مستشفى"),
    ("pharmacy","ˈfɑːrməsi","صيدلية"),("school","skuːl","مدرسة"),("university","ˌjuːnɪˈvɜːrsəti","جامعة"),
    ("library","ˈlaɪbreri","مكتبة"),("museum","mjuːˈziːəm","متحف"),("church","tʃɜːrtʃ","كنيسة"),
    ("mosque","mɒsk","مسجد"),("station","ˈsteɪʃən","محطة"),("airport","ˈeərpɔːrt","مطار"),
    ("bus stop","bʌs stɒp","موقف الحافلة"),("train station","treɪn ˈsteɪʃən","محطة قطار"),
    ("port","pɔːrt","ميناء"),("parking","ˈpɑːrkɪŋ","موقف سيارات"),
    ("car","kɑːr","سيارة"),("bus","bʌs","حافلة"),("train","treɪn","قطار"),
    ("taxi","ˈtæksi","سيارة أجرة"),("bike","baɪk","دراجة"),("motorcycle","ˈmoʊtərsaɪkəl","دراجة نارية"),
    ("boat","boʊt","قارب"),("plane","pleɪn","طائرة"),("ticket","ˈtɪkɪt","تذكرة"),
    ("driver","ˈdraɪvər","سائق"),("passenger","ˈpæsɪndʒər","راكب"),
    ("excuse me","ɪkˈskjuːz miː","عذراً"),("where is","weər ɪz","أين يقع"),
    ("how do I get","haʊ duː aɪ ɡet","كيف أصل"),("can you help","kæn juː help","هل يمكنك المساعدة"),
    ("lost","lɒst","تائه"),("find","faɪnd","يجد"),("look for","lʊk fɔːr","يبحث عن"),
],

"health_a": [
    ("body","ˈbɒdi","جسم"),("head","hed","رأس"),("hair","heər","شعر"),
    ("face","feɪs","وجه"),("eye","aɪ","عين"),("nose","noʊz","أنف"),
    ("mouth","maʊθ","فم"),("ear","ɪər","أذن"),("tooth","tuːθ","سن"),
    ("tongue","tʌŋ","لسان"),("lip","lɪp","شفة"),("neck","nek","رقبة"),
    ("shoulder","ˈʃoʊldər","كتف"),("arm","ɑːrm","ذراع"),("hand","hænd","يد"),
    ("finger","ˈfɪŋɡər","إصبع"),("leg","leɡ","رجل"),("knee","niː","ركبة"),
    ("foot","fʊt","قدم"),("back","bæk","ظهر"),("chest","tʃest","صدر"),
    ("stomach","ˈstʌmək","معدة"),("heart","hɑːrt","قلب"),("lung","lʌŋ","رئة"),
    ("skin","skɪn","جلد"),("bone","boʊn","عظم"),("blood","blʌd","دم"),
    ("brain","breɪn","دماغ"),("health","helθ","صحة"),("healthy","ˈhelθi","صحي"),
    ("sick","sɪk","مريض"),("ill","ɪl","معتل"),("pain","peɪn","ألم"),
    ("hurt","hɜːrt","يؤلم"),("ache","eɪk","وجع"),("headache","ˈhedeɪk","صداع"),
    ("toothache","ˈtuːθeɪk","ألم أسنان"),("stomachache","ˈstʌməkeɪk","ألم بطن"),
    ("fever","ˈfiːvər","حمى"),("cold","koʊld","زكام"),("cough","kɒf","سعال"),
    ("flu","fluː","إنفلونزا"),("allergy","ˈælərdʒi","حساسية"),
],

"health_b": [
    ("doctor","ˈdɒktər","طبيب"),("nurse","nɜːrs","ممرض"),("hospital","ˈhɒspɪtəl","مستشفى"),
    ("clinic","ˈklɪnɪk","عيادة"),("appointment","əˈpɔɪntmənt","موعد"),("checkup","ˈtʃekʌp","فحص"),
    ("symptom","ˈsɪmptəm","عرض"),("diagnose","ˌdaɪəɡˈnoʊz","يشخّص"),
    ("medicine","ˈmedɪsən","دواء"),("pill","pɪl","حبة دواء"),("syrup","ˈsɪrəp","شراب دواء"),
    ("cream","kriːm","مرهم"),("injection","ɪnˈdʒekʃən","حقنة"),("vaccine","vækˈsiːn","لقاح"),
    ("prescription","prɪˈskrɪpʃən","وصفة طبية"),("pharmacy","ˈfɑːrməsi","صيدلية"),
    ("emergency","ɪˈmɜːrdʒənsi","طوارئ"),("ambulance","ˈæmbjələns","إسعاف"),
    ("break a bone","breɪk ə boʊn","يكسر عظمة"),("bandage","ˈbændɪdʒ","ضمادة"),
    ("test","test","فحص"),("blood test","blʌd test","فحص دم"),("scan","skæn","سكان"),
    ("xray","ˈeks reɪ","أشعة"),("operation","ˌɒpəˈreɪʃən","عملية"),("surgery","ˈsɜːrdʒəri","جراحة"),
    ("recover","rɪˈkʌvər","يتعافى"),("rest","rest","يرتاح"),("sleep","sliːp","ينام"),
    ("hydrate","ˈhaɪdreɪt","يشرب الماء"),("diet","ˈdaɪət","حمية"),("calorie","ˈkæləri","سعرة حرارية"),
    ("exercise","ˈeksərsaɪz","تمرين"),("walk daily","wɔːk ˈdeɪli","يمشي يومياً"),
    ("smoke","smoʊk","يدخّن"),("quit","kwɪt","يقلع"),("alcohol","ˈælkəhɒl","كحول"),
    ("stress","stres","توتر"),("anxiety","æŋˈzaɪəti","قلق"),("depression","dɪˈpreʃən","اكتئاب"),
    ("mental health","ˈmentəl helθ","الصحة النفسية"),("dentist","ˈdentɪst","طبيب أسنان"),
    ("eye doctor","aɪ ˈdɒktər","طبيب عيون"),("optician","ɒpˈtɪʃən","نظاراتي"),
    ("specialist","ˈspeʃəlɪst","أخصائي"),("general practitioner","ˈdʒenərəl prækˈtɪʃənər","طبيب عام"),
    ("insurance","ɪnˈʃʊərəns","تأمين"),("urgent","ˈɜːrdʒənt","عاجل"),
    ("feel better","fiːl ˈbetər","يشعر بتحسن"),("get well","ɡet wel","يتحسن"),
    ("vital signs","ˈvaɪtəl saɪnz","العلامات الحيوية"),("blood pressure","blʌd ˈpreʃər","ضغط الدم"),
    ("sugar level","ˈʃʊɡər ˈlevəl","مستوى السكر"),("infection","ɪnˈfekʃən","عدوى"),
],

"work": [
    ("work","wɜːrk","عمل"),("job","dʒɒb","وظيفة"),("career","kəˈrɪər","مسيرة مهنية"),
    ("office","ˈɒfɪs","مكتب"),("company","ˈkʌmpəni","شركة"),("business","ˈbɪznəs","عمل تجاري"),
    ("boss","bɒs","المدير"),("manager","ˈmænɪdʒər","مدير"),("colleague","ˈkɒliːɡ","زميل"),
    ("team","tiːm","فريق"),("employee","ɪmˈplɔɪiː","موظف"),("employer","ɪmˈplɔɪər","صاحب عمل"),
    ("client","ˈklaɪənt","عميل"),("customer","ˈkʌstəmər","زبون"),
    ("salary","ˈsæləri","راتب"),("wage","weɪdʒ","أجر"),("bonus","ˈboʊnəs","علاوة"),
    ("contract","ˈkɒntrækt","عقد"),("position","pəˈzɪʃən","منصب"),("role","roʊl","دور"),
    ("task","tæsk","مهمة"),("project","ˈprɒdʒekt","مشروع"),("deadline","ˈdedlaɪn","موعد نهائي"),
    ("meeting","ˈmiːtɪŋ","اجتماع"),("appointment","əˈpɔɪntmənt","موعد"),
    ("schedule","ˈʃedʒuːl","جدول"),("hours","ˈaʊərz","ساعات"),("shift","ʃɪft","ورديّة"),
    ("part-time","pɑːrt taɪm","دوام جزئي"),("full-time","fʊl taɪm","دوام كامل"),
    ("overtime","ˈoʊvərtaɪm","إضافي"),("break","breɪk","استراحة"),("lunch break","lʌntʃ breɪk","استراحة الغداء"),
    ("vacation","veɪˈkeɪʃən","إجازة"),("leave","liːv","إجازة"),("sick leave","sɪk liːv","إجازة مرضية"),
    ("email","ˈiːmeɪl","بريد إلكتروني"),("phone call","foʊn kɔːl","مكالمة هاتفية"),
    ("computer","kəmˈpjuːtər","كمبيوتر"),("laptop","ˈlæptɒp","لابتوب"),("printer","ˈprɪntər","طابعة"),
    ("desk","desk","مكتب"),("chair","tʃeər","كرسي"),("file","faɪl","ملف"),
    ("folder","ˈfoʊldər","مجلد"),("document","ˈdɒkjəmənt","مستند"),("report","rɪˈpɔːrt","تقرير"),
    ("presentation","ˌprezənˈteɪʃən","عرض تقديمي"),("slide","slaɪd","شريحة"),
    ("note","noʊt","ملاحظة"),("plan","plæn","يخطط/خطة"),("idea","aɪˈdiːə","فكرة"),
    ("decide","dɪˈsaɪd","يقرر"),("decision","dɪˈsɪʒən","قرار"),("solve","sɒlv","يحل"),
    ("problem","ˈprɒbləm","مشكلة"),("solution","səˈluːʃən","حل"),("goal","ɡoʊl","هدف"),
    ("result","rɪˈzʌlt","نتيجة"),("success","səkˈses","نجاح"),("fail","feɪl","يفشل"),
    ("manage","ˈmænɪdʒ","يدير"),("lead","liːd","يقود"),("follow","ˈfɒloʊ","يتبع"),
    ("organize","ˈɔːrɡənaɪz","ينظم"),("prepare","prɪˈpeər","يحضّر"),("deliver","dɪˈlɪvər","يسلّم"),
    ("send","send","يرسل"),("receive","rɪˈsiːv","يستلم"),("answer","ˈænsər","يرد"),
    ("ask","æsk","يسأل"),("explain","ɪkˈspleɪn","يشرح"),("discuss","dɪˈskʌs","يناقش"),
    ("agree","əˈɡriː","يتفق"),("disagree","ˌdɪsəˈɡriː","يختلف"),("listen","ˈlɪsən","يستمع"),
    ("speak","spiːk","يتكلم"),("write","raɪt","يكتب"),("type","taɪp","يطبع"),
    ("save","seɪv","يحفظ"),("share","ʃeər","يشارك"),("copy","ˈkɒpi","ينسخ"),
    ("paste","peɪst","يلصق"),("delete","dɪˈliːt","يحذف"),
    ("teacher","ˈtiːtʃər","معلم"),("engineer","ˌendʒɪˈnɪər","مهندس"),("doctor","ˈdɒktər","طبيب"),
    ("nurse","nɜːrs","ممرض"),("lawyer","ˈlɔːjər","محامٍ"),("accountant","əˈkaʊntənt","محاسب"),
    ("driver","ˈdraɪvər","سائق"),("waiter","ˈweɪtər","نادل"),("cook","kʊk","طاهٍ"),
    ("seller","ˈselər","بائع"),("manager job","ˈmænɪdʒər dʒɒb","وظيفة مدير"),
    ("designer","dɪˈzaɪnər","مصمم"),("developer","dɪˈveləpər","مطور"),("programmer","ˈproʊɡræmər","مبرمج"),
    ("artist","ˈɑːrtɪst","فنان"),("writer","ˈraɪtər","كاتب"),("journalist","ˈdʒɜːrnəlɪst","صحفي"),
    ("apply","əˈplaɪ","يقدم طلباً"),("hire","ˈhaɪər","يوظّف"),("fire","ˈfaɪər","يطرد"),
    ("promote","prəˈmoʊt","يرقّي"),("retire","rɪˈtaɪər","يتقاعد"),("resign","rɪˈzaɪn","يستقيل"),
    ("CV","ˌsiː viː","سيرة ذاتية"),("interview","ˈɪntərvjuː","مقابلة"),("skill","skɪl","مهارة"),
    ("experience","ɪkˈspɪəriəns","خبرة"),("training","ˈtreɪnɪŋ","تدريب"),
    ("learn","lɜːrn","يتعلم"),("teach","tiːtʃ","يعلّم"),("explain task","ɪkˈspleɪn tæsk","يشرح المهمة"),
],

"communication": [
    ("phone","foʊn","هاتف"),("mobile","ˈmoʊbaɪl","جوال"),("smartphone","ˈsmɑːrtfoʊn","هاتف ذكي"),
    ("number","ˈnʌmbər","رقم"),("dial","ˈdaɪəl","يطلب رقماً"),("call","kɔːl","يتصل"),
    ("answer","ˈænsər","يرد"),("hang up","hæŋ ʌp","يغلق المكالمة"),("ring","rɪŋ","يرن"),
    ("voicemail","ˈvɔɪsmeɪl","بريد صوتي"),("message","ˈmesɪdʒ","رسالة"),("text","tekst","رسالة نصية"),
    ("send","send","يرسل"),("receive","rɪˈsiːv","يستلم"),("contact","ˈkɒntækt","جهة اتصال"),
    ("speak with","spiːk wɪð","يتحدث مع"),("talk to","tɔːk tuː","يكلم"),
    ("introduce yourself","ˌɪntrəˈduːs jɔːrˈself","يقدم نفسه"),("hold on","hoʊld ɒn","انتظر"),
    ("can I speak to","kæn aɪ spiːk tuː","هل يمكنني التحدث إلى"),
    ("who is calling","huː ɪz ˈkɔːlɪŋ","من المتصل"),("wrong number","rɒŋ ˈnʌmbər","رقم خطأ"),
    ("speak up","spiːk ʌp","ارفع صوتك"),("loud","laʊd","عالٍ"),("clear","klɪər","واضح"),
    ("email","ˈiːmeɪl","بريد إلكتروني"),("subject","ˈsʌbdʒɪkt","الموضوع"),("body","ˈbɒdi","المحتوى"),
    ("attach","əˈtætʃ","يرفق"),("attachment","əˈtætʃmənt","مرفق"),("reply","rɪˈplaɪ","يرد"),
    ("forward","ˈfɔːrwərd","يحوّل"),("inbox","ˈɪnbɒks","علبة الوارد"),("spam","spæm","سبام"),
    ("draft","drɑːft","مسودة"),("send to","send tuː","يرسل إلى"),("dear","dɪər","عزيزي"),
    ("regards","rɪˈɡɑːrdz","تحياتي"),("sincerely","sɪnˈsɪərli","مع خالص الشكر"),
    ("interview","ˈɪntərvjuː","مقابلة"),("resume","ˈrezjuːmeɪ","سيرة ذاتية"),
    ("CV","ˌsiː viː","سيرة ذاتية"),("cover letter","ˈkʌvər ˈletər","خطاب تقديم"),
    ("candidate","ˈkændɪdət","مرشح"),("position","pəˈzɪʃən","منصب"),("vacancy","ˈveɪkənsi","شاغر"),
    ("apply","əˈplaɪ","يتقدم"),("HR","ˌeɪtʃ ˈɑːr","الموارد البشرية"),
    ("strength","streŋθ","نقطة قوة"),("weakness","ˈwiːknəs","نقطة ضعف"),
    ("experience","ɪkˈspɪəriəns","خبرة"),("skill","skɪl","مهارة"),
    ("hard skill","hɑːrd skɪl","مهارة تقنية"),("soft skill","sɒft skɪl","مهارة شخصية"),
    ("team player","tiːm ˈpleɪər","عضو فريق"),("hard worker","hɑːrd ˈwɜːrkər","مجدّ في العمل"),
    ("punctual","ˈpʌŋktʃuəl","ملتزم بالوقت"),("creative","kriˈeɪtɪv","مبدع"),
    ("organized","ˈɔːrɡənaɪzd","منظم"),("motivated","ˈmoʊtɪveɪtɪd","متحفز"),
    ("ambitious","æmˈbɪʃəs","طموح"),("flexible","ˈfleksəbəl","مرن"),
    ("expected salary","ɪkˈspektɪd ˈsæləri","الراتب المتوقع"),
    ("start date","stɑːrt deɪt","تاريخ البدء"),("notice period","ˈnoʊtɪs ˈpɪəriəd","فترة الإشعار"),
    ("references","ˈrefərənsɪz","مراجع"),("background","ˈbækɡraʊnd","الخلفية"),
    ("education","ˌedʒuˈkeɪʃən","التعليم"),("degree","dɪˈɡriː","شهادة"),
    ("certificate","sərˈtɪfɪkət","شهادة دراسية"),("university","ˌjuːnɪˈvɜːrsəti","جامعة"),
    ("graduate","ˈɡrædʒuət","خرّيج"),("internship","ˈɪntɜːrnʃɪp","تدريب"),
    ("offer","ˈɒfər","عرض"),("accept","əkˈsept","يقبل"),("reject","rɪˈdʒekt","يرفض"),
    ("negotiate","nɪˈɡoʊʃieɪt","يفاوض"),("sign","saɪn","يوقع"),("contract","ˈkɒntrækt","عقد"),
    ("voice","vɔɪs","صوت"),("video call","ˈvɪdioʊ kɔːl","مكالمة فيديو"),
    ("chat","tʃæt","دردشة"),("social media","ˈsoʊʃəl ˈmiːdiə","وسائل التواصل"),
    ("post","poʊst","منشور"),("follower","ˈfɒloʊər","متابع"),
    ("share post","ʃeər poʊst","يشارك منشوراً"),("like a post","laɪk ə poʊst","يعجبه منشور"),
    ("comment","ˈkɒment","تعليق"),
],

"opinions": [
    ("opinion","əˈpɪnjən","رأي"),("idea","aɪˈdiːə","فكرة"),("think","θɪŋk","يفكر"),
    ("believe","bɪˈliːv","يصدّق"),("feel","fiːl","يشعر"),("agree","əˈɡriː","يوافق"),
    ("disagree","ˌdɪsəˈɡriː","لا يوافق"),("maybe","ˈmeɪbi","ربما"),("sure","ʃʊər","متأكد"),
    ("perhaps","pərˈhæps","ربما"),("probably","ˈprɒbəbli","غالباً"),("certainly","ˈsɜːrtənli","بالتأكيد"),
    ("really","ˈriːəli","حقاً"),("actually","ˈæktʃuəli","في الواقع"),("honestly","ˈɒnəstli","بصراحة"),
    ("personally","ˈpɜːrsənəli","شخصياً"),("in my opinion","ɪn maɪ əˈpɪnjən","في رأيي"),
    ("for example","fɔːr ɪɡˈzɑːmpəl","على سبيل المثال"),("for instance","fɔːr ˈɪnstəns","مثلاً"),
    ("such as","sʌtʃ æz","مثل"),("like that","laɪk ðæt","مثل ذلك"),
    ("good","ɡʊd","جيد"),("bad","bæd","سيء"),("better","ˈbetər","أفضل"),
    ("worse","wɜːrs","أسوأ"),("best","best","الأفضل"),("worst","wɜːrst","الأسوأ"),
    ("important","ɪmˈpɔːrtənt","مهم"),("interesting","ˈɪntrəstɪŋ","مثير للاهتمام"),
    ("boring","ˈbɔːrɪŋ","ممل"),("useful","ˈjuːsfəl","مفيد"),("useless","ˈjuːsləs","عديم الفائدة"),
    ("difficult","ˈdɪfɪkəlt","صعب"),("easy","ˈiːzi","سهل"),("possible","ˈpɒsəbəl","ممكن"),
    ("impossible","ɪmˈpɒsəbəl","مستحيل"),("true","truː","صحيح"),("false","fɔːls","خاطئ"),
    ("right","raɪt","صحيح"),("wrong","rɒŋ","خطأ"),("yes","jes","نعم"),
    ("no","nəʊ","لا"),("of course","əv kɔːrs","بالطبع"),("certainly not","ˈsɜːrtənli nɒt","بالتأكيد لا"),
    ("definitely","ˈdefɪnətli","بكل تأكيد"),("absolutely","ˈæbsəluːtli","بكل تأكيد"),
    ("never","ˈnevər","أبداً"),("always","ˈɔːlweɪz","دائماً"),("usually","ˈjuːʒəli","عادة"),
    ("often","ˈɒfən","غالباً"),("rarely","ˈreərli","نادراً"),("sometimes","ˈsʌmtaɪmz","أحياناً"),
    ("story","ˈstɔːri","قصة"),("event","ɪˈvent","حدث"),("happen","ˈhæpən","يحدث"),
    ("yesterday","ˈjestərdeɪ","أمس"),("last week","læst wiːk","الأسبوع الماضي"),
    ("last month","læst mʌnθ","الشهر الماضي"),("last year","læst jɪər","العام الماضي"),
    ("years ago","jɪərz əˈɡoʊ","منذ سنوات"),("when I was","wen aɪ wɒz","عندما كنت"),
    ("once","wʌns","ذات مرة"),("first","fɜːrst","أولاً"),("then","ðen","ثم"),
    ("after that","ˈæftər ðæt","بعد ذلك"),("finally","ˈfaɪnəli","أخيراً"),("at the end","æt ðə end","في النهاية"),
    ("remember","rɪˈmembər","يتذكر"),("forget","fərˈɡet","ينسى"),("memory","ˈmeməri","ذاكرة"),
    ("travel","ˈtrævəl","يسافر"),("visit","ˈvɪzɪt","يزور"),("meet","miːt","يقابل"),
    ("see","siː","يرى"),("watch","wɒtʃ","يشاهد"),("hear","hɪər","يسمع"),
    ("learn","lɜːrn","يتعلم"),("teach","tiːtʃ","يعلّم"),("understand","ˌʌndərˈstænd","يفهم"),
    ("explain","ɪkˈspleɪn","يشرح"),("describe","dɪˈskraɪb","يصف"),("compare","kəmˈpeər","يقارن"),
    ("similar","ˈsɪmələr","مشابه"),("different","ˈdɪfərənt","مختلف"),
    ("the same","ðə seɪm","نفس الشيء"),
    ("amazing","əˈmeɪzɪŋ","مذهل"),("awful","ˈɔːfəl","فظيع"),("funny","ˈfʌni","مضحك"),
    ("strange","streɪndʒ","غريب"),("scary","ˈskeəri","مخيف"),("exciting","ɪkˈsaɪtɪŋ","مثير"),
    ("relaxing","rɪˈlæksɪŋ","مريح"),("emotional","ɪˈmoʊʃənəl","عاطفي"),
    ("agree completely","əˈɡriː kəmˈpliːtli","يوافق تماماً"),
    ("agree partly","əˈɡriː ˈpɑːrtli","يوافق جزئياً"),("on the other hand","ɒn ðiː ˈʌðər hænd","من ناحية أخرى"),
    ("however","haʊˈevər","ومع ذلك"),("but","bʌt","لكن"),("although","ɔːlˈðoʊ","رغم أن"),
    ("because","bɪˈkɒz","لأن"),("so","soʊ","لذلك"),("if","ɪf","إذا"),
    ("when","wen","عندما"),("while","waɪl","بينما"),("until","ʌnˈtɪl","حتى"),
],

"future": [
    ("future","ˈfjuːtʃər","المستقبل"),("plan","plæn","يخطط/خطة"),("goal","ɡoʊl","هدف"),
    ("dream","driːm","حلم"),("hope","hoʊp","يأمل"),("wish","wɪʃ","يتمنى"),
    ("will","wɪl","سـ (للمستقبل)"),("going to","ˈɡoʊɪŋ tuː","سـ"),("next year","nekst jɪər","العام القادم"),
    ("next week","nekst wiːk","الأسبوع القادم"),("tomorrow","təˈmɒroʊ","غداً"),
    ("soon","suːn","قريباً"),("later","ˈleɪtər","لاحقاً"),("someday","ˈsʌmdeɪ","يوماً ما"),
    ("study","ˈstʌdi","يدرس"),("learn","lɜːrn","يتعلم"),("travel","ˈtrævəl","يسافر"),
    ("move","muːv","ينتقل"),("save money","seɪv ˈmʌni","يدّخر"),("buy a house","baɪ ə haʊs","يشتري بيتاً"),
    ("buy a car","baɪ ə kɑːr","يشتري سيارة"),("get a job","ɡet ə dʒɒb","يحصل على وظيفة"),
    ("change job","tʃeɪndʒ dʒɒb","يغير الوظيفة"),("start a business","stɑːrt ə ˈbɪznəs","يبدأ مشروعاً"),
    ("get married","ɡet ˈmærid","يتزوج"),("have children","hæv ˈtʃɪldrən","ينجب أطفالاً"),
    ("learn English","lɜːrn ˈɪŋɡlɪʃ","يتعلم الإنجليزية"),("speak fluently","spiːk ˈfluːəntli","يتحدث بطلاقة"),
    ("get healthier","ɡet ˈhelθiər","يصبح أكثر صحة"),("lose weight","luːz weɪt","يخسر وزناً"),
    ("eat better","iːt ˈbetər","يأكل بشكل أفضل"),("exercise more","ˈeksərsaɪz mɔːr","يمارس الرياضة أكثر"),
    ("read more","riːd mɔːr","يقرأ أكثر"),("save time","seɪv taɪm","يوفر الوقت"),
    ("less screen","les skriːn","شاشة أقل"),("more sleep","mɔːr sliːp","نوم أكثر"),
    ("new habit","njuː ˈhæbɪt","عادة جديدة"),("better life","ˈbetər laɪf","حياة أفضل"),
    ("step","step","خطوة"),("first step","fɜːrst step","الخطوة الأولى"),
    ("daily action","ˈdeɪli ˈækʃən","عمل يومي"),("small action","smɔːl ˈækʃən","عمل صغير"),
    ("habit","ˈhæbɪt","عادة"),("discipline","ˈdɪsəplɪn","انضباط"),
    ("focus","ˈfoʊkəs","تركيز"),("patience","ˈpeɪʃəns","صبر"),("effort","ˈefərt","مجهود"),
    ("hard work","hɑːrd wɜːrk","عمل جاد"),("smart work","smɑːrt wɜːrk","عمل ذكي"),
    ("never give up","ˈnevər ɡɪv ʌp","لا تستسلم أبداً"),("keep going","kiːp ˈɡoʊɪŋ","استمر"),
    ("believe in yourself","bɪˈliːv ɪn jɔːrˈself","ثق بنفسك"),
    ("be proud","biː praʊd","افتخر"),("be patient","biː ˈpeɪʃənt","كن صبوراً"),
    ("be kind","biː kaɪnd","كن لطيفاً"),("be honest","biː ˈɒnəst","كن صادقاً"),
    ("be brave","biː breɪv","كن شجاعاً"),("celebrate","ˈseləbreɪt","يحتفل"),
    ("milestone","ˈmaɪlstoʊn","محطة مهمة"),("success","səkˈses","نجاح"),
    ("achievement","əˈtʃiːvmənt","إنجاز"),("progress","ˈproʊɡres","تقدم"),
    ("review","rɪˈvjuː","يراجع/مراجعة"),("repeat","rɪˈpiːt","يكرر"),
    ("practice daily","ˈpræktɪs ˈdeɪli","يتدرب يومياً"),
    ("opportunity","ˌɒpərˈtuːnəti","فرصة"),("challenge","ˈtʃæləndʒ","تحدٍّ"),
    ("change","tʃeɪndʒ","يغير/تغيير"),("improve","ɪmˈpruːv","يحسّن"),("grow","ɡroʊ","ينمو"),
    ("create","kriˈeɪt","يبدع"),("build","bɪld","يبني"),("design","dɪˈzaɪn","يصمم"),
    ("invest","ɪnˈvest","يستثمر"),("time","taɪm","وقت"),("money","ˈmʌni","مال"),
    ("energy","ˈenərdʒi","طاقة"),("health","helθ","صحة"),("family","ˈfæməli","عائلة"),
    ("friend","frend","صديق"),("god willing","ɡɒd ˈwɪlɪŋ","إن شاء الله"),
    ("inshallah","ɪnˈʃɑːlə","إن شاء الله"),("never too late","ˈnevər tuː leɪt","ليس متأخراً أبداً"),
    ("you can do it","juː kæn duː ɪt","يمكنك فعلها"),("one day at a time","wʌn deɪ æt ə taɪm","يوم بيوم"),
    ("five minutes only","faɪv ˈmɪnɪts ˈoʊnli","خمس دقائق فقط"),
    ("start today","stɑːrt təˈdeɪ","ابدأ اليوم"),("don't wait","doʊnt weɪt","لا تنتظر"),
    ("future me","ˈfjuːtʃər miː","أنا في المستقبل"),
    ("better version","ˈbetər ˈvɜːrʒən","نسخة أفضل"),
    ("be the best","biː ðə best","كن الأفضل"),("daily plan","ˈdeɪli plæn","خطة يومية"),
    ("weekly plan","ˈwiːkli plæn","خطة أسبوعية"),("monthly plan","ˈmʌnθli plæn","خطة شهرية"),
    ("yearly plan","ˈjɪərli plæn","خطة سنوية"),
    ("review the year","rɪˈvjuː ðə jɪər","يراجع السنة"),
    ("look back","lʊk bæk","ينظر للوراء"),("look forward","lʊk ˈfɔːrwərd","يتطلع"),
    ("you did it","juː dɪd ɪt","لقد فعلتها"),("congratulations","kənˌɡrætʃəˈleɪʃənz","تهانينا"),
],
}

# ------------------------------------------------------------------
# Topic example-sentence templates.
# Each template is (en_template, ar_template). {w} is replaced with word_en.
# Each topic has ~6+ varied templates; words rotate through them.
# ------------------------------------------------------------------

TOPIC_TEMPLATES = {
"greetings": [
    ("I want to learn the word {w}.", "أريد أن أتعلم كلمة {w}."),
    ("Can you say {w}, please?", "هل يمكنك قول {w} من فضلك؟"),
    ("She wrote {w} in the book.", "كتبت {w} في الكتاب."),
    ("We use {w} every day.", "نستعمل {w} كل يوم."),
    ("Please repeat the word {w}.", "من فضلك كرر كلمة {w}."),
    ("My friend taught me {w}.", "صديقي علّمني كلمة {w}."),
    ("Try to use {w} in a sentence.", "حاول استخدام {w} في جملة."),
],
"numbers": [
    ("Please write the number {w}.", "من فضلك اكتب الرقم {w}."),
    ("The price is {w} dirham.", "السعر هو {w} درهم."),
    ("My class starts at {w}.", "صفي يبدأ عند {w}."),
    ("Today is {w}.", "اليوم هو {w}."),
    ("I have {w} books at home.", "عندي {w} كتباً في البيت."),
    ("We count to {w} together.", "نعد إلى {w} معاً."),
    ("My phone has the number {w}.", "هاتفي فيه الرقم {w}."),
],
"family": [
    ("My {w} is very kind.", "إن {w} لطيف جداً."),
    ("I love my {w} a lot.", "أحب {w} كثيراً."),
    ("This is a photo of my {w}.", "هذه صورة {w}."),
    ("We visit our {w} every weekend.", "نزور {w} كل عطلة نهاية أسبوع."),
    ("My {w} lives in Casablanca.", "{w} يعيش في الدار البيضاء."),
    ("I learned a lot from my {w}.", "تعلمت الكثير من {w}."),
    ("My {w} is a good cook.", "{w} طاهٍ جيد."),
],
"routine": [
    ("I {w} every morning at seven.", "أنا {w} كل صباح في السابعة."),
    ("She likes to {w} before work.", "هي تحب أن {w} قبل العمل."),
    ("On Mondays I {w} for one hour.", "أيام الإثنين أنا {w} لمدة ساعة."),
    ("Do you {w} on the weekend?", "هل أنت {w} في عطلة نهاية الأسبوع؟"),
    ("My family and I {w} together.", "أنا وعائلتي {w} معاً."),
    ("After dinner I usually {w}.", "بعد العشاء عادة أنا {w}."),
    ("It is healthy to {w} every day.", "من الصحي أن {w} كل يوم."),
],
"home_a": [
    ("Our {w} is small but clean.", "{w} الخاص بنا صغير لكنه نظيف."),
    ("The {w} is at the end of the hall.", "إن {w} في نهاية الممر."),
    ("Please close the {w}.", "من فضلك أغلق {w}."),
    ("I clean my {w} every week.", "أنظف {w} كل أسبوع."),
    ("There is a chair in the {w}.", "يوجد كرسي في {w}."),
    ("My family eats in the {w}.", "تأكل عائلتي في {w}."),
    ("The light in the {w} is broken.", "ضوء {w} معطل."),
],
"home_b": [
    ("We bought a new {w} last week.", "اشترينا {w} جديداً الأسبوع الماضي."),
    ("Please put the {w} on the table.", "من فضلك ضع {w} على الطاولة."),
    ("The {w} is in the kitchen.", "إن {w} في المطبخ."),
    ("I clean the {w} on Friday.", "أنظف {w} يوم الجمعة."),
    ("Where is the {w}?", "أين {w}؟"),
    ("My favorite {w} is blue.", "إن {w} المفضل لدي أزرق."),
    ("This {w} is very useful at home.", "{w} هذا مفيد جداً في البيت."),
],
"food": [
    ("I want to order {w}, please.", "أريد أن أطلب {w} من فضلك."),
    ("This {w} is very delicious.", "{w} هذا لذيذ جداً."),
    ("Do you like {w}?", "هل تحب {w}؟"),
    ("We don't have {w} today.", "ليس لدينا {w} اليوم."),
    ("Can I have a glass of {w}?", "هل يمكنني الحصول على كوب من {w}؟"),
    ("My mother makes the best {w}.", "أمي تصنع أفضل {w}."),
    ("Please bring two {w}.", "من فضلك أحضر اثنين من {w}."),
],
"shopping": [
    ("How much is this {w}?", "بكم هذا {w}؟"),
    ("I would like to buy a {w}.", "أرغب في شراء {w}."),
    ("Do you have this {w} in red?", "هل لديكم هذا {w} باللون الأحمر؟"),
    ("This {w} is too expensive.", "هذا {w} غالٍ جداً."),
    ("I need a smaller {w}.", "أحتاج {w} أصغر."),
    ("Can I try this {w} on?", "هل يمكنني تجربة هذا {w}؟"),
    ("Where can I find a {w}?", "أين يمكنني أن أجد {w}؟"),
],
"directions": [
    ("Excuse me, where is the {w}?", "عذراً، أين {w}؟"),
    ("Go straight and you will see the {w}.", "اذهب مستقيماً وسترى {w}."),
    ("The {w} is on your right.", "إن {w} على يمينك."),
    ("Turn left at the {w}.", "انعطف يساراً عند {w}."),
    ("How do I get to the {w}?", "كيف أصل إلى {w}؟"),
    ("The {w} is near my home.", "{w} قريب من بيتي."),
    ("There is a big {w} downtown.", "يوجد {w} كبير في وسط المدينة."),
],
"health_a": [
    ("My {w} hurts a little.", "إن {w} يؤلمني قليلاً."),
    ("Please take care of your {w}.", "من فضلك اعتنِ بـ {w}."),
    ("The doctor checked my {w}.", "الطبيب فحص {w} لي."),
    ("I have a problem with my {w}.", "عندي مشكلة في {w}."),
    ("Move your {w} slowly.", "حرّك {w} ببطء."),
    ("Your {w} is fine, don't worry.", "إن {w} بخير، لا تقلق."),
    ("I drink water for my {w}.", "أشرب الماء لـ {w}."),
],
"health_b": [
    ("I need to see a {w}.", "أحتاج أن أرى {w}."),
    ("The {w} gave me good advice.", "أعطاني {w} نصيحة جيدة."),
    ("Please give me the {w}.", "من فضلك أعطني {w}."),
    ("I have an appointment with the {w}.", "عندي موعد مع {w}."),
    ("The {w} starts at 9 a.m.", "إن {w} يبدأ في التاسعة صباحاً."),
    ("Don't forget the {w} every day.", "لا تنسَ {w} كل يوم."),
    ("I feel better after the {w}.", "أشعر بتحسن بعد {w}."),
],
"work": [
    ("I have a meeting about the {w}.", "عندي اجتماع بخصوص {w}."),
    ("Please send the {w} by email.", "من فضلك أرسل {w} بالبريد الإلكتروني."),
    ("My {w} is on the desk.", "{w} على المكتب."),
    ("We finished the {w} on time.", "أنهينا {w} في الوقت."),
    ("Can you help me with this {w}?", "هل يمكنك مساعدتي في {w}؟"),
    ("The {w} starts at nine.", "{w} يبدأ في التاسعة."),
    ("I work as a {w}.", "أعمل كـ {w}."),
],
"communication": [
    ("Please send me an {w}.", "من فضلك أرسل لي {w}."),
    ("I will call you about the {w}.", "سأتصل بك بشأن {w}."),
    ("Can I leave a {w}?", "هل يمكنني ترك {w}؟"),
    ("The interviewer asked about my {w}.", "سألني المُحاوِر عن {w}."),
    ("I want to prepare for the {w}.", "أريد أن أستعد لـ {w}."),
    ("My {w} is ready now.", "{w} جاهز الآن."),
    ("Please reply to the {w} soon.", "من فضلك رد على {w} قريباً."),
],
"opinions": [
    ("In my opinion, this is a good {w}.", "في رأيي، هذا {w} جيد."),
    ("I think {w} is very important.", "أعتقد أن {w} مهم جداً."),
    ("She doesn't agree with the {w}.", "هي لا توافق على {w}."),
    ("That was an interesting {w}.", "كان ذلك {w} مثيراً للاهتمام."),
    ("Honestly, I don't like this {w}.", "بصراحة، لا يعجبني هذا {w}."),
    ("It was a long but good {w}.", "كان {w} طويلاً لكنه جيد."),
    ("Tell me your {w} about it.", "أخبرني {w} بخصوصه."),
],
"future": [
    ("Next year I will {w}.", "العام القادم سأنا {w}."),
    ("My goal is to {w} every day.", "هدفي أن {w} كل يوم."),
    ("I hope I can {w} soon.", "آمل أن أستطيع {w} قريباً."),
    ("In five years I want to {w}.", "بعد خمس سنوات أريد أن {w}."),
    ("Tomorrow I will {w} for thirty minutes.", "غداً سأنا {w} لمدة ثلاثين دقيقة."),
    ("Don't stop, keep going to {w}.", "لا تتوقف، استمر لـ {w}."),
    ("One day I will {w} in English.", "يوماً ما سأنا {w} بالإنجليزية."),
],
}

# ------------------------------------------------------------------
# Topic key-sentence templates (the 11 daily "sentences" shown on the
# Sentences screen). Mix of practical phrases per topic.
# ------------------------------------------------------------------

TOPIC_SENTENCES = {
"greetings": [
    ("Hello, my name is Ahmed.", "مرحباً، اسمي أحمد."),
    ("Nice to meet you.", "تشرفت بمعرفتك."),
    ("How are you today?", "كيف حالك اليوم؟"),
    ("I am from Morocco.", "أنا من المغرب."),
    ("I speak Arabic and a little English.", "أتحدث العربية وقليلاً من الإنجليزية."),
    ("What is your name?", "ما اسمك؟"),
    ("Where are you from?", "من أين أنت؟"),
    ("I am happy to meet you.", "أنا سعيد بلقائك."),
    ("Have a nice day.", "أتمنى لك يوماً سعيداً."),
    ("See you tomorrow.", "أراك غداً."),
    ("Thank you very much.", "شكراً جزيلاً."),
    ("Excuse me, can you help me?", "عذراً، هل يمكنك مساعدتي؟"),
    ("I don't understand, please repeat.", "لا أفهم، من فضلك أعد."),
    ("Could you speak slowly?", "هل يمكنك التحدث ببطء؟"),
],
"numbers": [
    ("It is seven o'clock.", "الساعة السابعة."),
    ("My phone number is 0612345678.", "رقم هاتفي 0612345678."),
    ("Today is Monday, the fifth of June.", "اليوم الإثنين، الخامس من يونيو."),
    ("I am twenty years old.", "عمري عشرون سنة."),
    ("How much does it cost?", "كم يكلف؟"),
    ("It costs fifty dirham.", "يكلف خمسين درهماً."),
    ("My class is at nine in the morning.", "صفي في التاسعة صباحاً."),
    ("There are seven days in a week.", "هناك سبعة أيام في الأسبوع."),
    ("I work eight hours every day.", "أعمل ثماني ساعات كل يوم."),
    ("My birthday is in March.", "عيد ميلادي في مارس."),
    ("I'll be there in ten minutes.", "سأكون هناك خلال عشر دقائق."),
    ("Can I have two coffees, please?", "هل يمكنني الحصول على قهوتين من فضلك؟"),
    ("The meeting starts at three p.m.", "الاجتماع يبدأ في الثالثة مساءً."),
    ("We have four classes today.", "لدينا أربعة صفوف اليوم."),
],
"family": [
    ("This is my family.", "هذه عائلتي."),
    ("I have one brother and two sisters.", "لدي أخ واحد وأختان."),
    ("My father works in a hospital.", "والدي يعمل في مستشفى."),
    ("My mother is a great cook.", "والدتي طاهية رائعة."),
    ("My grandmother tells nice stories.", "جدتي تحكي قصصاً جميلة."),
    ("We visit our cousins every month.", "نزور أبناء عمنا كل شهر."),
    ("My sister is younger than me.", "أختي أصغر مني."),
    ("My brother is taller than me.", "أخي أطول مني."),
    ("I love my family very much.", "أحب عائلتي كثيراً."),
    ("We have dinner together every evening.", "نتناول العشاء معاً كل مساء."),
    ("My uncle lives in France.", "عمي يعيش في فرنسا."),
    ("My cousin and I are close friends.", "أنا وابن عمي أصدقاء مقربون."),
    ("My parents are very kind.", "والداي لطيفان جداً."),
    ("We celebrate birthdays at home.", "نحتفل بأعياد الميلاد في البيت."),
],
"routine": [
    ("I wake up at six in the morning.", "أستيقظ في السادسة صباحاً."),
    ("I take a shower and get dressed.", "أستحم وألبس ملابسي."),
    ("I have breakfast with my family.", "أتناول الفطور مع عائلتي."),
    ("I go to work by bus.", "أذهب إلى العمل بالحافلة."),
    ("I start work at nine.", "أبدأ العمل في التاسعة."),
    ("I have lunch at one.", "أتغدى في الواحدة."),
    ("After work I go to the gym.", "بعد العمل أذهب إلى النادي."),
    ("I cook dinner at home.", "أطبخ العشاء في البيت."),
    ("In the evening I study English.", "في المساء أدرس الإنجليزية."),
    ("I go to bed at eleven.", "أنام في الحادية عشرة."),
    ("On weekends I rest and see friends.", "في عطلة نهاية الأسبوع أرتاح وأرى أصدقائي."),
    ("I read a book before sleeping.", "أقرأ كتاباً قبل النوم."),
    ("I usually exercise three times a week.", "عادةً أتمرّن ثلاث مرات أسبوعياً."),
    ("I always check my phone in the morning.", "أتفقد هاتفي في الصباح دائماً."),
],
"home_a": [
    ("I live in a small apartment.", "أعيش في شقة صغيرة."),
    ("Our home has three rooms.", "بيتنا فيه ثلاث غرف."),
    ("My bedroom is on the second floor.", "غرفة نومي في الطابق الثاني."),
    ("Please close the door.", "من فضلك أغلق الباب."),
    ("Open the window for some fresh air.", "افتح النافذة لبعض الهواء النقي."),
    ("The kitchen is next to the living room.", "المطبخ بجانب غرفة المعيشة."),
    ("Our garden is small but nice.", "حديقتنا صغيرة لكنها لطيفة."),
    ("The lights are on.", "الأضواء مضاءة."),
    ("Please use the elevator.", "من فضلك استعمل المصعد."),
    ("I forgot the key at home.", "نسيت المفتاح في البيت."),
    ("There is a beautiful view from the balcony.", "هناك منظر جميل من الشرفة."),
    ("Be careful on the stairs.", "احذر على الدرج."),
    ("The bathroom is at the end of the hall.", "الحمام في نهاية الممر."),
    ("This is my favorite room.", "هذه غرفتي المفضلة."),
],
"home_b": [
    ("We bought a new sofa for the living room.", "اشترينا أريكة جديدة لغرفة المعيشة."),
    ("Please put the plates on the table.", "من فضلك ضع الصحون على الطاولة."),
    ("The fridge is full of food.", "الثلاجة مليئة بالطعام."),
    ("I clean my house every Saturday.", "أنظف بيتي كل سبت."),
    ("Where is the remote control?", "أين جهاز التحكم؟"),
    ("Can you turn on the light?", "هل يمكنك إضاءة الضوء؟"),
    ("The washing machine is broken.", "الغسالة معطلة."),
    ("My books are on the shelf.", "كتبي على الرف."),
    ("The mirror is too high for me.", "المرآة عالية جداً بالنسبة لي."),
    ("Could you pass me the salt?", "هل يمكنك إعطائي الملح؟"),
    ("I need to wash the dishes.", "أحتاج إلى غسل الصحون."),
    ("The curtains are very nice.", "الستائر جميلة جداً."),
    ("My desk is near the window.", "مكتبي بجانب النافذة."),
    ("I sleep on a comfortable bed.", "أنام على سرير مريح."),
],
"food": [
    ("I would like to see the menu.", "أود رؤية القائمة."),
    ("Can I have a glass of water?", "هل يمكنني الحصول على كوب ماء؟"),
    ("I'll have chicken and rice.", "سأتناول الدجاج والأرز."),
    ("Is it spicy?", "هل هو حار؟"),
    ("I'm allergic to nuts.", "لدي حساسية من المكسرات."),
    ("The food is delicious.", "الطعام لذيذ."),
    ("Can I have the bill, please?", "هل يمكنني الحصول على الفاتورة من فضلك؟"),
    ("I would like a table for two.", "أود طاولة لشخصين."),
    ("Do you have any vegetarian dishes?", "هل لديكم أطباق نباتية؟"),
    ("I'm hungry.", "أنا جائع."),
    ("I'm thirsty.", "أنا عطشان."),
    ("This is too salty.", "هذا مالح جداً."),
    ("Can I get this to go?", "هل يمكنني الحصول على هذا سفري؟"),
    ("My favorite food is couscous.", "طعامي المفضل هو الكسكس."),
],
"shopping": [
    ("How much is this?", "بكم هذا؟"),
    ("Do you have this in a larger size?", "هل لديكم هذا بمقاس أكبر؟"),
    ("Can I try it on?", "هل يمكنني تجربته؟"),
    ("I'll take it.", "سآخذه."),
    ("Do you accept credit cards?", "هل تقبلون بطاقات الائتمان؟"),
    ("Where is the fitting room?", "أين غرفة القياس؟"),
    ("Is there a discount?", "هل هناك خصم؟"),
    ("It's too expensive for me.", "إنه غالٍ جداً بالنسبة لي."),
    ("Can I have a receipt, please?", "هل يمكنني الحصول على إيصال من فضلك؟"),
    ("Do you have this in blue?", "هل لديكم هذا باللون الأزرق؟"),
    ("I'm just looking, thank you.", "أنا أتفرج فقط، شكراً."),
    ("Where can I pay?", "أين يمكنني الدفع؟"),
    ("Can I return this if it doesn't fit?", "هل يمكنني إرجاع هذا إذا لم يناسبني؟"),
    ("I need a small bag.", "أحتاج حقيبة صغيرة."),
],
"directions": [
    ("Excuse me, how do I get to the station?", "عذراً، كيف أصل إلى المحطة؟"),
    ("Go straight ahead, then turn right.", "اذهب مستقيماً، ثم انعطف يميناً."),
    ("It's about five minutes on foot.", "حوالي خمس دقائق سيراً على الأقدام."),
    ("Is the bank far from here?", "هل البنك بعيد من هنا؟"),
    ("It's next to the post office.", "إنه بجانب مكتب البريد."),
    ("Turn left at the traffic light.", "انعطف يساراً عند الإشارة."),
    ("Could you show me on the map?", "هل يمكنك أن تريني على الخريطة؟"),
    ("I'm lost.", "أنا تائه."),
    ("I'm looking for the airport.", "أبحث عن المطار."),
    ("Take the bus number 12.", "خذ الحافلة رقم 12."),
    ("The hotel is in the city center.", "الفندق في وسط المدينة."),
    ("Can I walk there?", "هل يمكنني المشي إلى هناك؟"),
    ("The taxi stand is on the corner.", "موقف سيارات الأجرة على الزاوية."),
    ("Please drop me off here.", "من فضلك أنزلني هنا."),
],
"health_a": [
    ("I don't feel well today.", "لا أشعر بخير اليوم."),
    ("My head hurts.", "رأسي يؤلمني."),
    ("I have a sore throat.", "حلقي يؤلمني."),
    ("I think I have the flu.", "أعتقد أن لدي إنفلونزا."),
    ("I need to see a doctor.", "أحتاج إلى رؤية طبيب."),
    ("My stomach hurts after eating.", "معدتي تؤلمني بعد الأكل."),
    ("I have a high fever.", "عندي حمى عالية."),
    ("Please rest in bed.", "من فضلك ارتح في السرير."),
    ("Drink plenty of water.", "اشرب الكثير من الماء."),
    ("I am allergic to penicillin.", "لدي حساسية من البنسلين."),
    ("My back is hurting me.", "ظهري يؤلمني."),
    ("I twisted my ankle.", "لويت كاحلي."),
    ("Take a deep breath.", "خذ نفساً عميقاً."),
    ("How do you feel now?", "كيف تشعر الآن؟"),
],
"health_b": [
    ("I'd like to make an appointment with the doctor.", "أود حجز موعد مع الطبيب."),
    ("Take this pill three times a day.", "خذ هذه الحبة ثلاث مرات يومياً."),
    ("The pharmacy is open until midnight.", "الصيدلية مفتوحة حتى منتصف الليل."),
    ("Do I need a prescription?", "هل أحتاج وصفة طبية؟"),
    ("I'd like to do a blood test.", "أود إجراء فحص دم."),
    ("Please follow the doctor's advice.", "من فضلك اتبع نصيحة الطبيب."),
    ("I have health insurance.", "لدي تأمين صحي."),
    ("My next appointment is on Monday.", "موعدي القادم يوم الإثنين."),
    ("Please call an ambulance.", "من فضلك اتصل بالإسعاف."),
    ("I need to see a specialist.", "أحتاج إلى رؤية أخصائي."),
    ("I feel much better today.", "أشعر بتحسن كبير اليوم."),
    ("This medicine helps me sleep.", "هذا الدواء يساعدني على النوم."),
    ("I have a checkup next week.", "عندي فحص الأسبوع القادم."),
    ("My doctor is very kind.", "طبيبي لطيف جداً."),
],
"work": [
    ("I have a meeting at ten.", "عندي اجتماع في العاشرة."),
    ("Please send me the report by email.", "من فضلك أرسل لي التقرير بالبريد الإلكتروني."),
    ("I will be in the office tomorrow.", "سأكون في المكتب غداً."),
    ("Our project deadline is Friday.", "الموعد النهائي لمشروعنا الجمعة."),
    ("Can you help me with this task?", "هل يمكنك مساعدتي في هذه المهمة؟"),
    ("I work from nine to five.", "أعمل من التاسعة حتى الخامسة."),
    ("My manager is in a meeting.", "مديري في اجتماع."),
    ("Let's discuss this after lunch.", "لنناقش هذا بعد الغداء."),
    ("I need a day off next week.", "أحتاج يوم إجازة الأسبوع القادم."),
    ("The team is working hard.", "الفريق يعمل بجد."),
    ("Please prepare the presentation.", "من فضلك حضّر العرض التقديمي."),
    ("I will join the call in five minutes.", "سأنضم للمكالمة بعد خمس دقائق."),
    ("Could you give me feedback?", "هل يمكنك إعطائي ملاحظات؟"),
    ("My salary is paid monthly.", "يُدفع راتبي شهرياً."),
],
"communication": [
    ("Hello, can I speak to Mr. Ali?", "مرحباً، هل يمكنني التحدث إلى السيد علي؟"),
    ("Please leave a message after the tone.", "من فضلك اترك رسالة بعد الصافرة."),
    ("I'm calling about the job advertisement.", "أتصل بشأن إعلان الوظيفة."),
    ("Could you send the file as an attachment?", "هل يمكنك إرسال الملف كمرفق؟"),
    ("I confirm our meeting for Friday.", "أؤكد اجتماعنا يوم الجمعة."),
    ("Tell me about yourself.", "حدّثني عن نفسك."),
    ("Why do you want this job?", "لماذا تريد هذه الوظيفة؟"),
    ("What is your biggest strength?", "ما هي أكبر نقاط قوتك؟"),
    ("I am a quick learner and a team player.", "أنا متعلم سريع وعضو فريق جيد."),
    ("Do you have any questions for me?", "هل لديك أي أسئلة لي؟"),
    ("Thank you for the opportunity.", "شكراً على هذه الفرصة."),
    ("I look forward to your reply.", "أتطلع إلى ردك."),
    ("Best regards, Ahmed.", "مع أطيب التحيات، أحمد."),
    ("Please confirm by tomorrow.", "من فضلك أكد قبل الغد."),
],
"opinions": [
    ("In my opinion, learning English is very important.", "في رأيي، تعلم الإنجليزية مهم جداً."),
    ("I think Morocco is a beautiful country.", "أعتقد أن المغرب بلد جميل."),
    ("I don't really agree with that idea.", "لا أوافق على تلك الفكرة فعلاً."),
    ("Actually, I prefer staying at home.", "في الواقع، أفضل البقاء في البيت."),
    ("Last summer I traveled to Spain.", "الصيف الماضي سافرت إلى إسبانيا."),
    ("When I was a child, I lived in Marrakech.", "عندما كنت طفلاً، عشت في مراكش."),
    ("That movie was really interesting.", "ذلك الفيلم كان مثيراً للاهتمام حقاً."),
    ("First, we visited the museum, then the park.", "أولاً، زرنا المتحف، ثم الحديقة."),
    ("On the other hand, it was expensive.", "من ناحية أخرى، كان غالياً."),
    ("Honestly, I don't have a strong opinion.", "بصراحة، ليس لدي رأي قوي."),
    ("Yesterday I met an old friend.", "أمس قابلت صديقاً قديماً."),
    ("It was a long but useful experience.", "كانت تجربة طويلة لكنها مفيدة."),
    ("I think we should try a new way.", "أعتقد أنه يجب علينا تجربة طريقة جديدة."),
    ("That's a great point, thanks.", "تلك نقطة رائعة، شكراً."),
],
"future": [
    ("Next year I will speak English better.", "العام القادم سأتحدث الإنجليزية بشكل أفضل."),
    ("My goal is to study every day for thirty minutes.", "هدفي أن أدرس كل يوم لثلاثين دقيقة."),
    ("In five years, I want to work abroad.", "بعد خمس سنوات، أريد العمل في الخارج."),
    ("I will save money to buy a car.", "سأدّخر المال لشراء سيارة."),
    ("Tomorrow I'll review today's words.", "غداً سأراجع كلمات اليوم."),
    ("I hope I can travel more.", "آمل أن أستطيع السفر أكثر."),
    ("Don't give up, keep going.", "لا تستسلم، استمر."),
    ("Small steps every day make a big difference.", "خطوات صغيرة كل يوم تصنع فرقاً كبيراً."),
    ("I am proud of my progress.", "أنا فخور بتقدمي."),
    ("You can do it, believe in yourself.", "يمكنك فعلها، ثق بنفسك."),
    ("Even five minutes a day is enough.", "حتى خمس دقائق في اليوم تكفي."),
    ("I will speak only English on Sundays.", "سأتحدث الإنجليزية فقط أيام الأحد."),
    ("Next month I'll read my first English book.", "الشهر القادم سأقرأ أول كتاب لي بالإنجليزية."),
    ("Inshallah, I will become fluent in English.", "إن شاء الله، سأصبح طليقاً في الإنجليزية."),
],
}

# ------------------------------------------------------------------
# Per-day topic title (Arabic) — kept short and concrete.
# We'll generate a "day_title_ar" per day using a topic + day-in-topic.
# ------------------------------------------------------------------

DAY_TITLE_PATTERNS = {
"greetings":   ["التحية الأولى", "تقديم النفس", "أسماء وكلمات لطف", "السؤال عن الحال", "بلد ولغة", "أصدقاء جدد", "وداع جميل"],
"numbers":     ["الأرقام من 0 إلى 20", "أرقام أكبر", "أيام الأسبوع", "الشهور والمواسم", "الساعة والوقت", "التاريخ والميلاد", "المراجعة"],
"family":      ["أفراد العائلة", "الإخوة والأخوات", "الأقارب", "الأبناء والآباء", "العمر والوصف", "زيارات العائلة", "العائلة الكبيرة"],
"routine":     ["الصباح الباكر", "الذهاب للعمل", "وقت العمل أو الدراسة", "وقت الغداء", "بعد الظهر", "المساء والعائلة", "قبل النوم"],
"home_a":      ["البيت والغرف", "الباب والنافذة"],
"home_b":      ["غرفة المعيشة", "غرفة النوم", "المطبخ", "الحمام", "أدوات البيت"],
"food":        ["وجبات اليوم", "في المطعم", "طلب الطعام", "الفواكه والخضار", "اللحم والسمك", "المشروبات", "ضيافة الأهل"],
"shopping":    ["في السوق", "الملابس", "الألوان والمقاسات", "السعر والدفع", "تخفيضات وعروض", "متجر الإلكترونيات", "الإرجاع والاستبدال"],
"directions":  ["السؤال عن الطريق", "اتجاهات أساسية", "في المدينة", "وسائل النقل", "محطة الحافلة", "الذهاب للمطار", "المراجعة"],
"health_a":    ["أجزاء الجسم", "الألم والمرض", "أعراض شائعة", "نمط حياة صحي"],
"health_b":    ["عند الطبيب", "في الصيدلية", "إصابات بسيطة"],
"work":        ["البحث عن وظيفة", "أول يوم عمل", "في المكتب", "الاجتماعات", "البريد والمشاريع", "المشاكل والحلول", "نهاية الأسبوع"],
"communication": ["مكالمة هاتفية", "ترك رسالة صوتية", "كتابة بريد إلكتروني", "التحضير للمقابلة", "أسئلة المقابلة", "الإجابات الذكية", "متابعة المقابلة"],
"opinions":    ["إعطاء الرأي", "الموافقة والاختلاف", "ذكريات من الماضي", "قصة طريفة", "قصة من السفر", "تجارب صعبة", "نصيحة لصديق"],
"future":      ["خطط لهذا الشهر", "أهداف هذا العام", "حلم كبير", "حياة صحية", "تعلم لغات", "مراجعة 90 يوماً", "ماذا الآن؟"],
}

# 6 tasks per day, sums to ~60–75 minutes total.
DAILY_TASKS = [
    ("vocabulary", "تعلم الكلمات",
     "اقرأ كلمات اليوم بصوت عالٍ مرتين، وانظر لكل مثال جملة. اكتب كل كلمة جديدة في دفترك.",
     15, 1),
    ("listening", "استماع",
     "استمع لجمل اليوم باستخدام زر القراءة 🔊 لكل جملة. كرر بعد كل جملة بصوت عالٍ.",
     10, 2),
    ("shadowing", "ترديد فوري (Shadowing)",
     "اضغط على زر القراءة لكل جملة وقم بترديدها مباشرة بنفس الإيقاع، 3 مرات لكل جملة.",
     10, 3),
    ("speaking", "تكلم وسجّل صوتك",
     "اختر 3 جمل من اليوم وقم بتسجيل صوتك وأنت تنطقها. استمع لنفسك وحاول تحسين النطق.",
     10, 4),
    ("writing", "كتابة قصيرة",
     "اكتب 4–6 جمل تستعمل فيها كلمات اليوم. ابدأ بجملة سهلة عن نفسك ثم وسّعها.",
     10, 5),
    ("review", "مراجعة (SRS)",
     "افتح شاشة المراجعة وراجع البطاقات المستحقة اليوم. اضغط صعبة/جيدة/سهلة حسب حفظك.",
     10, 6),
]


def chunk_words(words, n_per_day):
    """Cycle through topic words to ensure each day gets exactly n_per_day words.
       Allows repeats if topic word list is shorter than days*n_per_day, so we
       always meet the 22/day target. Repeats reinforce learning."""
    out = []
    i = 0
    while len(out) < n_per_day:
        out.append(words[i % len(words)])
        i += 1
    return out


def build_day_words(day_id, topic_key, day_in_topic, total_days_in_topic):
    pool = TOPIC_WORDS[topic_key]
    n = 22
    # Slice a per-day window over the pool so each day gets different words.
    start = (day_in_topic * n) % len(pool)
    out = []
    for k in range(n):
        out.append(pool[(start + k) % len(pool)])
    return out


def build_day_sentences(day_id, topic_key, day_in_topic):
    pool = TOPIC_SENTENCES[topic_key]
    n = 11
    start = (day_in_topic * n) % len(pool)
    out = []
    for k in range(n):
        out.append(pool[(start + k) % len(pool)])
    return out


def example_for(word_en, topic_key, i):
    templates = TOPIC_TEMPLATES[topic_key]
    en_t, ar_t = templates[i % len(templates)]
    return en_t.format(w=word_en), ar_t.format(w=word_en)


def get_day_title(topic_key, day_in_topic):
    titles = DAY_TITLE_PATTERNS[topic_key]
    return titles[day_in_topic % len(titles)]


def build():
    days = []
    words_out = []
    sentences_out = []
    tasks_out = []

    # Map day_id -> (week_no, phase_id, topic_key, topic_en, topic_ar, idx_in_topic)
    day_meta = {}
    for week_no, phase_id, day_range, topic_key, topic_en, topic_ar in WEEKS:
        days_list = list(day_range)
        for idx, d in enumerate(days_list):
            day_meta[d] = (week_no, phase_id, topic_key, topic_en, topic_ar, idx, len(days_list))

    word_id = 1
    sent_id = 1
    task_id = 1

    for day_id in range(1, 91):
        week_no, phase_id, topic_key, topic_en, topic_ar, idx, n_days = day_meta[day_id]
        title_ar = get_day_title(topic_key, idx)
        est_minutes = sum(t[3] for t in DAILY_TASKS)
        days.append({
            "id": day_id,
            "phase_id": phase_id,
            "week_no": week_no,
            "title_ar": title_ar,
            "topic_en": topic_en,
            "topic_ar": topic_ar,
            "est_minutes": est_minutes,
        })

        # Words
        day_words = build_day_words(day_id, topic_key, idx, n_days)
        for i, (w_en, ipa, ar) in enumerate(day_words):
            ex_en, ex_ar = example_for(w_en, topic_key, i + day_id)
            words_out.append({
                "id": word_id,
                "day_id": day_id,
                "word_en": w_en,
                "ipa": ipa,
                "meaning_ar": ar,
                "example_en": ex_en,
                "example_ar": ex_ar,
                "audio_ref": "",  # built-in TTS — no bundled audio
            })
            word_id += 1

        # Sentences
        day_sents = build_day_sentences(day_id, topic_key, idx)
        for s_en, s_ar in day_sents:
            sentences_out.append({
                "id": sent_id,
                "day_id": day_id,
                "sentence_en": s_en,
                "translation_ar": s_ar,
                "audio_ref": "",
            })
            sent_id += 1

        # Tasks
        for t_type, label_ar, instr_ar, duration, order in DAILY_TASKS:
            tasks_out.append({
                "id": task_id,
                "day_id": day_id,
                "type": t_type,
                "label_ar": label_ar,
                "instructions_ar": instr_ar,
                "duration_min": duration,
                "sort_order": order,
            })
            task_id += 1

    return PHASES, days, words_out, sentences_out, tasks_out


def main():
    phases, days, words, sentences, tasks = build()

    (OUT / "phases.json").write_text(
        json.dumps(phases, ensure_ascii=False, indent=2), encoding="utf-8")
    (OUT / "days.json").write_text(
        json.dumps(days, ensure_ascii=False, indent=2), encoding="utf-8")
    (OUT / "words.json").write_text(
        json.dumps(words, ensure_ascii=False, indent=2), encoding="utf-8")
    (OUT / "sentences.json").write_text(
        json.dumps(sentences, ensure_ascii=False, indent=2), encoding="utf-8")
    (OUT / "tasks.json").write_text(
        json.dumps(tasks, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"phases:    {len(phases)}")
    print(f"days:      {len(days)}")
    print(f"words:     {len(words)}  (~{len(words)/90:.1f} per day)")
    print(f"sentences: {len(sentences)}  (~{len(sentences)/90:.1f} per day)")
    print(f"tasks:     {len(tasks)}  (~{len(tasks)/90:.1f} per day)")


if __name__ == "__main__":
    main()
