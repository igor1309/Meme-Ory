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
        
        for sample in stories {
            let story = Story(context: context)
            story.text = sample
            story.timestamp = Date()
            
            let tag = Tag(context: context)
            let index = Int(arc4random_uniform(UInt32(tagStrings.count)))
            tag.name = tagStrings[index]
            story.tags.append(tag)
        }
        
        context.saveContext()
        
        return controller
    }()

    static let story: Story = {
        let context = preview.container.viewContext
        
        let story = Story(context: context)
        story.text = stories[4]
        story.timestamp = Date()
        
        let tag = Tag(context: context)
        tag.name = SampleData.tagStrings[1]
        story.tags.append(tag)
        
        context.saveContext()
        
        return story
    }()
    
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
    
    static let stories = [
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
        """
    ]
}

