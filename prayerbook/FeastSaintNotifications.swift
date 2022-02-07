//
//  FeastSaintNotifications.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/11/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import Foundation
import UserNotifications
import swift_toolkit

class FeastSaintNotifications: FeastNotifications {
    class func saintNotification(date: Date, body: String) {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru")
        
        let d = formatter.string(from: date)
        
        addNotification(date: date, title: "", body: "\(d) - \(body)")
    }
    
    override class func setupExtraNotifications() {
        let year = DateComponents(date: Date()).toDate().year

        for (date, descr) in FeastList.remembrance {
            addNotification(date: date,  title: "Поминовение усопших", body: descr.string)
        }
        
        saintNotification(date: Date(2,1,year), body: "Прав. Иоанна Кронштадского, чудотворца")
        saintNotification(date: Date(3,1,year), body: "Свт. Петра, митр. Московского и всея России чудотворца")
        saintNotification(date: Date(15,1,year), body: "прп. Серафима, Саровского чудотворца")
        saintNotification(date: Date(23,1,year), body: "Свт. Феофана, Затворника Вышенского")
        saintNotification(date: Date(27,1,year), body: "Равноап. Нины, просветительницы Грузии")
        saintNotification(date: Date(30,1,year), body: "Прп. Антония Великого")
        
        saintNotification(date: Date(2,2,year), body: "Прп. Евфимия Великого")
        saintNotification(date: Date(6,2,year), body: "Блж. Ксении Петербургской")
        saintNotification(date: Date(12,2,year), body: "Собор Вселенских учителей и святителей Василия Великого, Григория Богослова и Иоанна Златоустого")
        
        saintNotification(date: Date(25,2,year), body: "Иверской иконы Божией Матери")
        
        saintNotification(date: Date(9,3,year), body: "Первое (IV) и второе (452) обретение главы Иоанна Предтечи")
        saintNotification(date: Date(15,3,year), body: "Иконы Божией Матери, именуемой Державная (1917)")
        saintNotification(date: Date(22,3,year), body: "40 мучеников, в Севастийском озере мучившихся")
        
        saintNotification(date: Date(2,5,year), body: "Блж. Матроны Московской")
        saintNotification(date: Date(6,5,year), body: "Вмч. Георгия Победоносца")
        saintNotification(date: Date(15,5,year), body: "Перенесение мощей блгв. князей Бориса и Глеба")
        saintNotification(date: Date(16,5,year), body: "Прп. Феодосия, игумена Киево-Печерского (1074)")
        saintNotification(date: Date(21,5,year), body: "Апостола и евангелиста Иоанна Богослова")
        saintNotification(date: Date(22,5,year), body: "Перенесение мощей святителя и чудотворца Николая")
        saintNotification(date: Date(24,5,year), body: "Равноапп. Мефодия и Кирилла")
        
        saintNotification(date: Date(1,6,year), body: "Блгвв. вел. кн. Димитрия Донского")
        saintNotification(date: Date(3,6,year), body: "Владимирской иконы Божией Матери")
        saintNotification(date: Date(7,6,year), body: "Третье обретение главы Предтечи и Крестителя Господня Иоанна")

        saintNotification(date: Date(2,7,year), body: "Святителя Иоанна (Максимовича) архиепископа Шанхайского и Сан-Францисского, Чудотворца")
        
        saintNotification(date: Date(6,7,year), body: "Владимирской иконы Божией Матери")
        saintNotification(date: Date(11,7,year), body: "Прпп. Сергия и Германа, Валаамских чудотворцев")

        saintNotification(date: Date(17,7,year), body: "Страстотерпцев Императора Николая II, Императрицы Александры, царевича Алексия, великих княжен Ольги, Татианы, Марии, Анастасии")

        saintNotification(date: Date(21,7,year), body: "Казанской иконы Божией Матери")
        saintNotification(date: Date(28,7,year), body: "Равноап. вел. кн. Владимира")

        saintNotification(date: Date(1,8,year), body: "Обретение мощей прп. Серафима, Саровского чудотворца")
        saintNotification(date: Date(2,8,year), body: "Пророка Илии")
        saintNotification(date: Date(6,8,year), body: "Мчч. блгвв. князей Бориса и Глеба")
        saintNotification(date: Date(15,8,year), body: "Блж. Василия, Христа ради юродивого, Московского чудотворца")
        saintNotification(date: Date(21,8,year), body: "Перенесение мощей прпп. Зосимы и Савватия Соловецких (1566, 1992)")

        saintNotification(date: Date(8,9,year), body: "Владимирской иконы Божией Матери")
        saintNotification(date: Date(14,9,year), body: "Начало индикта - церковное новолетие")
        saintNotification(date: Date(15,9,year), body: "Прпп. Антония (1073) и Феодосия (1074) Печерских")
        saintNotification(date: Date(24,9,year), body: "Прп. Силуана Афонского")

        saintNotification(date: Date(8,10,year), body: "прп. Сергия, игумена Радонежского, всея России чудотворца")
        saintNotification(date: Date(9,10,year), body: "Апостола и евангелиста Иоанна Богослова")
        saintNotification(date: Date(13,10,year), body: "Свт. Михаила, первого митр. Киевского")
        saintNotification(date: Date(23,10,year), body: "Прп. Амвросия Оптинского")
        saintNotification(date: Date(26,10,year), body: "Иверской иконы Божией Матери")

        saintNotification(date: Date(4,11,year), body: "Казанской иконы Божией Матери")
        saintNotification(date: Date(8,11,year), body: "Вмч. Димитрия Солунского")
        saintNotification(date: Date(21,11,year), body: "Собор Архистратига Михаила и прочих Небесных Сил бесплотных")
        saintNotification(date: Date(26,11,year), body: "Свт. Иоанна Златоустого")

        saintNotification(date: Date(6,12,year), body: "Блгв. вел. кн. Александра Невского")
        saintNotification(date: Date(10,12,year), body: "Иконы Божией Матери, именуемой Знамение")
        saintNotification(date: Date(18,12,year), body: "Прп. Саввы Освященного")
        saintNotification(date: Date(19,12,year), body: "Святителя Николая, архиепископа Мир Ликийских чудотворца")
    }
}

