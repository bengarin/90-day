/// Curated English-word → emoji map for the vocabulary cards.
/// Lookup is lowercase-exact-match; falls back to a generic icon for
/// words not in the map. Keep this list small and offline — the goal is
/// visual association, not coverage of every word.
class EmojiMap {
  static const String fallback = '📘';

  static const Map<String, String> _map = {
    // greetings & social
    'hello': '👋', 'hi': '👋', 'bye': '👋', 'goodbye': '👋', 'thanks': '🙏',
    'thank': '🙏', 'please': '🙏', 'sorry': '🙇', 'welcome': '🤝',
    'yes': '✅', 'no': '❌', 'ok': '👌', 'okay': '👌',

    // pronouns & basics
    'i': '🙋', 'you': '👉', 'we': '👥', 'they': '👥', 'he': '🧑', 'she': '👩',
    'name': '🏷️', 'age': '🎂',

    // family
    'family': '👨‍👩‍👧', 'mother': '👩', 'father': '👨', 'mom': '👩', 'dad': '👨',
    'parent': '👨‍👩‍👧', 'son': '👦', 'daughter': '👧', 'child': '🧒',
    'children': '🧒', 'baby': '👶', 'brother': '👦', 'sister': '👧',
    'friend': '🤝', 'wife': '👰', 'husband': '🤵',

    // verbs - movement
    'go': '🚶', 'come': '🚶', 'walk': '🚶', 'run': '🏃', 'jump': '🤸',
    'drive': '🚗', 'travel': '✈️', 'fly': '✈️', 'swim': '🏊', 'ride': '🚴',

    // verbs - daily
    'eat': '🍽️', 'drink': '🥤', 'sleep': '😴', 'wake': '⏰', 'work': '💼',
    'study': '📚', 'read': '📖', 'write': '✍️', 'speak': '💬', 'talk': '💬',
    'listen': '👂', 'hear': '👂', 'see': '👀', 'look': '👀', 'watch': '👀',
    'play': '🎮', 'sing': '🎤', 'dance': '💃', 'cook': '🍳', 'clean': '🧹',
    'buy': '🛒', 'sell': '🏷️', 'pay': '💳', 'help': '🤝',

    // verbs - mental/emotion
    'think': '💭', 'know': '🧠', 'remember': '🧠', 'forget': '🤔',
    'understand': '💡', 'learn': '📚', 'teach': '👨‍🏫', 'love': '❤️',
    'like': '👍', 'hate': '👎', 'want': '🎯', 'need': '🆘', 'feel': '💗',

    // food & drinks
    'food': '🍽️', 'water': '💧', 'milk': '🥛', 'tea': '🍵', 'coffee': '☕',
    'juice': '🧃', 'bread': '🍞', 'rice': '🍚', 'meat': '🥩', 'chicken': '🍗',
    'fish': '🐟', 'egg': '🥚', 'cheese': '🧀', 'salt': '🧂', 'sugar': '🍬',
    'apple': '🍎', 'banana': '🍌', 'orange': '🍊', 'fruit': '🍎',
    'vegetable': '🥦', 'tomato': '🍅', 'potato': '🥔', 'pizza': '🍕',
    'breakfast': '🍳', 'lunch': '🍱', 'dinner': '🍽️',

    // body
    'head': '🗣️', 'face': '😀', 'eye': '👁️', 'eyes': '👀', 'ear': '👂',
    'mouth': '👄', 'nose': '👃', 'hand': '✋', 'hands': '🙌', 'foot': '🦶',
    'feet': '🦶', 'hair': '💇', 'heart': '❤️', 'tooth': '🦷',

    // places
    'home': '🏠', 'house': '🏠', 'school': '🏫', 'work_place': '🏢',
    'office': '🏢', 'shop': '🏬', 'store': '🏪', 'market': '🛍️',
    'restaurant': '🍽️', 'hospital': '🏥', 'bank': '🏦', 'hotel': '🏨',
    'park': '🌳', 'beach': '🏖️', 'city': '🏙️', 'country': '🌍',
    'street': '🛣️', 'road': '🛣️', 'airport': '🛫', 'station': '🚉',

    // nature
    'sun': '☀️', 'moon': '🌙', 'star': '⭐', 'sky': '🌌', 'cloud': '☁️',
    'rain': '🌧️', 'snow': '❄️', 'wind': '💨', 'fire': '🔥', 'tree': '🌳',
    'flower': '🌸', 'sea': '🌊', 'river': '🏞️', 'mountain': '⛰️',
    'earth': '🌍', 'world': '🌍',

    // animals
    'cat': '🐱', 'dog': '🐶', 'bird': '🐦', 'horse': '🐴', 'cow': '🐄',
    'sheep': '🐑', 'lion': '🦁', 'tiger': '🐯', 'elephant': '🐘',
    'monkey': '🐵', 'rabbit': '🐰', 'mouse': '🐭', 'snake': '🐍',
    'animal': '🐾',

    // time
    'time': '⏰', 'hour': '🕐', 'minute': '⏱️', 'second': '⏱️',
    'day': '📅', 'week': '📆', 'month': '🗓️', 'year': '📅',
    'today': '📍', 'tomorrow': '➡️', 'yesterday': '⬅️',
    'morning': '🌅', 'afternoon': '🌞', 'evening': '🌆', 'night': '🌙',
    'now': '⏰', 'later': '⏳', 'soon': '⏳', 'early': '🌅', 'late': '🌙',

    // weather
    'weather': '🌤️', 'hot': '🔥', 'cold': '🥶', 'warm': '🌤️', 'cool': '🍃',

    // tech
    'phone': '📱', 'computer': '💻', 'laptop': '💻', 'internet': '🌐',
    'email': '📧', 'message': '💬', 'app': '📱', 'video': '🎬', 'music': '🎵',
    'photo': '📷', 'picture': '🖼️', 'camera': '📷', 'tv': '📺',

    // money/work
    'money': '💰', 'job': '💼', 'business': '💼', 'meeting': '🤝',
    'company': '🏢', 'boss': '👔', 'salary': '💵', 'price': '🏷️',
    'cheap': '🪙', 'expensive': '💎', 'rich': '🤑', 'poor': '🪙',

    // school/learning
    'book': '📕', 'page': '📄', 'word': '📝', 'sentence': '📝',
    'language': '🗣️', 'english': '🇬🇧', 'arabic': '🇲🇦', 'grammar': '📐',
    'test': '📝', 'exam': '📝', 'lesson': '📚', 'class': '🏫',
    'student': '🧑‍🎓', 'teacher': '👨‍🏫', 'homework': '📒',

    // adjectives
    'big': '⬆️', 'small': '⬇️', 'good': '👍', 'bad': '👎', 'new': '🆕',
    'old': '👴', 'young': '👶', 'fast': '⚡', 'slow': '🐢', 'easy': '😊',
    'hard': '😤', 'difficult': '😤', 'happy': '😄', 'sad': '😢',
    'angry': '😠', 'tired': '😩', 'busy': '🏃', 'free': '🆓',
    'beautiful': '✨', 'ugly': '🤢', 'dirty': '🧼',
    'long': '➖', 'short': '➖', 'tall': '⬆️',

    // colors
    'red': '🔴', 'blue': '🔵', 'green': '🟢', 'yellow': '🟡',
    'black': '⚫', 'white': '⚪', 'orange_color': '🟠', 'pink': '💗',
    'purple': '🟣', 'brown': '🟤', 'color': '🎨', 'colour': '🎨',

    // numbers (a few that come up as words)
    'one': '1️⃣', 'two': '2️⃣', 'three': '3️⃣', 'four': '4️⃣',
    'five': '5️⃣', 'ten': '🔟', 'hundred': '💯', 'number': '🔢',

    // transport
    'car': '🚗', 'bus': '🚌', 'train': '🚆', 'plane': '✈️', 'bike': '🚲',
    'boat': '⛵',

    // clothes
    'clothes': '👕', 'shirt': '👕', 'pants': '👖', 'shoes': '👟',
    'hat': '🎩', 'dress': '👗',

    // sports / activity
    'sport': '⚽', 'football': '⚽', 'soccer': '⚽', 'basketball': '🏀',
    'tennis': '🎾', 'gym': '🏋️', 'exercise': '🏋️',

    // misc useful
    'key': '🔑', 'door': '🚪', 'window': '🪟', 'bed': '🛏️', 'chair': '🪑',
    'table': '🪑', 'gift': '🎁', 'party': '🎉', 'wedding': '💒',
    'birthday': '🎂', 'idea': '💡', 'question': '❓', 'answer': '✅',
    'problem': '⚠️', 'solution': '💡', 'health': '💊', 'doctor': '👨‍⚕️',
    'medicine': '💊', 'sick': '🤒',
  };

  static String of(String word) {
    final key = word.trim().toLowerCase();
    return _map[key] ?? fallback;
  }
}
