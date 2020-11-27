//
//  SampleData.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import CoreData

struct SampleData {
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        let tags: [Tag] = tagStrings.map {
            let tag = Tag(context: context)
            tag.name = $0
            
            return tag
        }
        
        for sample in texts {
            let story = Story(context: context)
            story.text = sample
            story.timestamp = Date()
            story.isFavorite = Bool.random()
            
            if let tag = tags.randomElement() {
                story.tags.append(tag)
            }
        }
        
        return controller
    }()

    static func story(storyIndex: Int = 4, tagIndex: Int = 2) -> Story {
        let context = preview.container.viewContext
        
        let story = Story(context: context)
        story.text = texts[storyIndex % texts.count]
        story.timestamp = Date()
        
        let tag = Tag(context: context)
        tag.name = SampleData.tagStrings[tagIndex % tagStrings.count]
        story.tags.append(tag)
        
        return story
    }
    
    static let tag: Tag = {
        let context = preview.container.viewContext
        
        let tag = Tag(context: context)
        tag.name = "общество"
        
        return tag
    }()
    
    static let tags: Set<Tag> = {
        let context = preview.container.viewContext
        
        let tags: [Tag] = tagStrings.map {
            let tag = Tag(context: context)
            tag.name = $0
            
            return tag
        }
        
        return Set(tags)
    }()
    
    static let tagStrings = ["Путин", "евреи и еврейство", "жизнь и судьба", "отношения"]
    
    static let texts = [
        """
        — Скажи мне, Сёма , какое самое благоприятное время для сбора яблок?
        — Когда собака привязана.
        """,
        """
        — Изя, два миллиона ливанцев вышли на протест против коррупции. Как ты думаешь, возможно такое в России?
        — Сёма, подумай сам, ну откуда в России два миллиона ливанцев?
        """,
        """
        — Яша, и чего ви так долго вчера шумели ?
        — Пили.
        — А шо у вас было ?
        — Деньги.
        """,
        """
        🔯– Сарочка, с днем рождения! И сколько вам стукнуло?
        – Когда я выходила замуж за Сёму, мне было 20, а ему 40, то есть я в два раза моложе. Сейчас Сёме 70, а мне, стало быть, 35!
        """,
        """
        — Сара! Я, таки, считаю, что ты неправа.
        — Ой, Марик! Я тебя умоляю! Пересчитай...
        """,
        """
        — А что у тебя с тем Борей?
        — Ой, я того Борю… убила бы!
        — А что такое?
        — Пригласила его в гости, тонко попросила купить в ближайшей аптеке "что–нибудь к чаю"... И так, что вы думаете принес—этот поц?
        — Хаааа... А есть ещё варианты?!
        — Есть! Он, бл@дь, припёр "Гематоген"!
        """,
        """
        Рабинович с Цукерманом смотрят фильм про Илью Муромца, там, где к нему обращаются люди:
        — Гой еси, ты добрый молодец, Илья Муромец.
        Цукерман:
        — Что они говорят?
        Рабинович:
        — Ты хороший человек Илья Муромец, хоть и не еврей.
        """,
        """
        — Додик, шо там упало на кухне?!
        — Ривочка, это не бунт, это случайно.
        """,
        """
        У старого Мойше спросили:
        — Вы верите в приметы?
        — Смотря какие.
        — Ну, например, вы проснулись утром, и встали не с той ноги…
        — Милочка, в моем возрасте проснуться утром – это уже хорошая примета!
        """,
        """
        — Беня, я гарантирую вам, шо через пять лет мы будем жить лучше, чем в Европе!
        — А шо у них случится?
        """,
        """
        — Вы посадили меня рядом с евреем! Я не желаю сидеть рядом с этим странным человеком. Найдите мне другое место!
        — Я проверю, есть ли возможность найти другое место, самолет полон. Женщина бросила уничижительный взгляд на соседа-еврея и гордо посмотрела поверх голов пассажиров.
        Через несколько минут стюард вернулся.
        — Мадам, и обычный и первый класс полны, и свободных мест нет. У нас есть только одно место в бизнес-классе.
        Женщина только успела открыть рот, как стюард продолжил:
        — Такие вещи мы делаем только в исключительном случае. Я обратился к командиру экипажа для получения разрешения. Вследствие исключительных обстоятельств командир согласился с тем, что не стоит заставлять человека сидеть рядом с тем, кто ему неприятен.
        — Мистер, я Вас прошу собрать вещи и пройти со мной в бизнес-класс.
        Еврей встал и прошел за ним, сопровождаемый аплодисментами пассажиров. Женщина покраснев от злости, заявила стюарду:
        — Наверняка, капитан ошибся!
        — Что Вы, мадам, капитан Кацман никогда не ошибается.
        """
    ]
}

