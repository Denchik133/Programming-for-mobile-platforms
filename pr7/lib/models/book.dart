class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final int year;
  final String description;
  final bool isAvailable;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.year,
    required this.description,
    this.isAvailable = true,
  });
}

final List<Book> sampleBooks = [
  const Book(
    id: '1',
    title: 'Кобзар',
    author: 'Тарас Шевченко',
    genre: 'Українська література',
    year: 1840,
    description: 'Збірка поетичних творів Тараса Шевченка.',
  ),
  const Book(
    id: '2',
    title: 'Тіні забутих предків',
    author: 'Михайло Коцюбинський',
    genre: 'Українська література',
    year: 1911,
    description: 'Повість про життя гуцулів, кохання та традиції.',
  ),
  const Book(
    id: '3',
    title: 'Захар Беркут',
    author: 'Іван Франко',
    genre: 'Українська література',
    year: 1883,
    description: 'Історична повість про боротьбу громади за свободу.',
  ),
  const Book(
    id: '4',
    title: 'Гаррі Поттер і філософський камінь',
    author: 'Джоан Ролінґ',
    genre: 'Фентезі',
    year: 1997,
    description: 'Перша історія про юного чарівника Гаррі Поттера.',
  ),
  const Book(
    id: '5',
    title: 'Володар перснів',
    author: 'Джон Рональд Руел Толкін',
    genre: 'Фентезі',
    year: 1954,
    description: 'Подорож до Мордору заради знищення Єдиного Персня.',
  ),
  const Book(
    id: '6',
    title: '1984',
    author: 'Джордж Орвелл',
    genre: 'Фантастика',
    year: 1949,
    description: 'Роман-антиутопія про тотальний контроль суспільства.',
  ),
  const Book(
    id: '7',
    title: '451° за Фаренгейтом',
    author: 'Рей Бредбері',
    genre: 'Фантастика',
    year: 1953,
    description: 'Антиутопія про суспільство, у якому заборонені книги.',
  ),
  const Book(
    id: '8',
    title: 'Маленький принц',
    author: 'Антуан де Сент-Екзюпері',
    genre: 'Класика',
    year: 1943,
    description: 'Філософська казка про дружбу, любов і відповідальність.',
  ),
  const Book(
    id: '9',
    title: 'Робінзон Крузо',
    author: 'Даніель Дефо',
    genre: 'Пригоди',
    year: 1719,
    description: 'Історія виживання людини на безлюдному острові.',
  ),
  const Book(
    id: '10',
    title: 'Острів скарбів',
    author: 'Роберт Луїс Стівенсон',
    genre: 'Пригоди',
    year: 1883,
    description: 'Пригодницький роман про пошуки піратських скарбів.',
  ),
  const Book(
    id: '11',
    title: 'Злочин і кара',
    author: 'Федір Достоєвський',
    genre: 'Класика',
    year: 1866,
    description: 'Роман про моральний вибір, провину та відповідальність.',
  ),
  const Book(
    id: '12',
    title: 'Гордість і упередження',
    author: 'Джейн Остін',
    genre: 'Класика',
    year: 1813,
    description: 'Роман про стосунки, суспільні норми та кохання.',
  ),
  const Book(
    id: '13',
    title: 'Квіти для Елджернона',
    author: 'Деніел Кіз',
    genre: 'Фантастика',
    year: 1966,
    description: 'Історія експерименту, що змінює інтелект людини.',
  ),
  const Book(
    id: '14',
    title: 'Айвенго',
    author: 'Вальтер Скотт',
    genre: 'Пригоди',
    year: 1819,
    description: 'Історичний роман про лицарів і середньовічну Англію.',
  ),
  const Book(
    id: '15',
    title: 'Майстер і Маргарита',
    author: 'Михайло Булгаков',
    genre: 'Класика',
    year: 1967,
    description: 'Філософський роман із містичними та сатиричними мотивами.',
  ),
];