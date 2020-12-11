import Foundation

let source = """
Вопрос «Есть ли евреи на других планетах?» очень интересовал доктора астрономии и члена-корреспондента Академии Наук Семёна Каца.
Когда все ушли с работы, он отправил в космос сообщение:
— Ну?
Ответ пришел через 5 минут:
— Сёма, не морочьте нам голову…

 ***

— Рабинович, у вас алиби есть?
— А шо это такое?
— Ну, видел ли вас кто-нибудь во время убийства?
— Слава Богу, нет.

 ***

— Ребе, тут в Торе пропуск!
— Не говори чепуху!
— Посмотрите сами, тут написано: не пожелай жены ближнего своего. А почему нигде нет: не пожелай мужа ближней своей?
— Ну-уу… Пускай она даже пожелает - ему-то все равно нельзя!

 ***

— Яша, я уже вышла из ванны и жду неприличных предложений…
— Софочка, а давай заправим оливье кетчупом.
— Нет, Яша, это уже перебор!

 ***

— Моня, почему ты не даришь мне цветы?
— Циля, я подарил тебе весь мир! Иди нюхай цветы на улицу!..

 ***

— Беня, я гарантирую вам, шо через пять лет мы будем жить лучше, чем в Европе!
— А шо у них случится?

 ***

— Семочка, если будешь хорошо себя вести, купим тебе велосипед!
— А если плохо?
— Пианино!

 ***

— Сара, выполни мою последнюю просьбу! Сожги мое тело в крематории! Прах положи в конверт, напиши там: «ТЕПЕРЬ ВЫ ПОЛУЧИЛИ С МЕНЯ ВСЁ», и отправь в налоговую.

 ***

— Фирочка, а чем вы увлекаетесь?
— Рисованием и верховой ездой. А вы, Боря?
— Таки не поверите… Художницами и наездницами!

 ***

— Рабинович, а шо вы имеете сказать за старость?
— Старость – это когда из половых органов остались одни глаза.
— А чтобы пооптимистичнее?
— Но взгляд твердый!

 ***

Германия. Автобус с туристами из Одессы. Экскурсовод просит каждого посмотреть, все ли его соседи сели в автобус. Закрывается дверь, автобус уезжает. Километров через десять его догоняет полицейская машина. В дверь заходит женщина средних лет и с характерным акцентом восклицает:
— Моня, не с твоим щастьем!


"""

let separator = """


 ***


"""

let components = source.components(separatedBy: separator)
let first = components[0]
let trimmedFirst = first.trimmingCharacters(in: .whitespacesAndNewlines)
print(first)
print(first == trimmedFirst)
print(trimmedFirst)
//components.map { print($0) }
for component in components {
    print(component)
}
