﻿&НаКлиенте
Перем СтруктураСобытияМетрики;

&НаКлиенте
Перем ЦепочкаСобытий;

&НаКлиенте
Перем РазницаЧасовыхПоясов;

&НаСервере
Перем ОбработкаОбъект;

&НаСервере
Функция МодульОбъекта()

	Если ОбработкаОбъект = Неопределено Тогда
		ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	КонецЕсли;	
	
	Возврат ОбработкаОбъект;
	
КонецФункции

//ВСПОМОГАТЕЛЬНЫЕ {             

&НаКлиенте
Функция ИмяФормы(Форма)
	ВремИмяФормы = Форма.ИмяФормы;
	Поз = Найти(ВремИмяФормы, "Форма.");
	Имя = Сред(ВремИмяФормы, Поз + 6);
	Возврат Имя;
КонецФункции

&НаКлиенте
Процедура Метрика_ПоместитьВоВХ(Имя,Значение) Экспорт
	
	ПоместитьВоВременноеХранилище(Значение, Объект.ПараметрыКлиентСерверМетрика.АдресаВХ[Имя]);
				
КонецПроцедуры

&НаКлиенте
Функция Метрика_ИзвлечьИзВХ(Имя) Экспорт
	
	АдресВХ = Объект.ПараметрыКлиентСерверМетрика.АдресаВХ[Имя];
	
	Если Не ЭтоАдресВременногоХранилища(АдресВХ) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ПолучитьИзВременногоХранилища(АдресВХ);
			
КонецФункции

&НаКлиенте
Функция Метрика_РазложитьСтрокуВМассивСлов(Знач Строка, РазделителиСлов="")
	
	Слова = Новый Массив;
	
	Если СтрДлина(РазделителиСлов) = 1 Тогда
		
		НайденныйСимвол = Найти(Строка,РазделителиСлов);
		Пока НайденныйСимвол>0 Цикл
			Слова.Добавить(Лев(Строка,НайденныйСимвол-1));
			Строка = Сред(Строка,НайденныйСимвол+1);
			НайденныйСимвол = Найти(Строка,РазделителиСлов);
		КонецЦикла;
		
		Если НЕ ПустаяСтрока(Строка) Тогда
			Слова.Добавить(Строка);
		КонецЕсли;
		
	Иначе
		
		Для Сч = 1 По СтрДлина(РазделителиСлов) Цикл
			Строка = СтрЗаменить(Строка,Сред(РазделителиСлов,Сч,1),Символы.ПС);
		КонецЦикла;
		
		Для Сч=1 По СтрЧислоСтрок(Строка) Цикл
			ТекСлово = СокрЛП(СтрПолучитьСтроку(Строка,Сч));
			Если ТекСлово<>"" Тогда
				Слова.Добавить(ТекСлово);
			КонецЕсли;	
		КонецЦикла;	
		
	КонецЕсли;
	
	Возврат Слова;
	
КонецФункции

//} ВСПОМОГАТЕЛЬНЫЕ

//ТЕКУЧИЕ ВЫРАЖЕНИЯ

//Основная реализация

&НаКлиенте
Функция НоваяМетрика() Экспорт
	
	СтруктураСобытияМетрики 					= Метрика_ТиповаяСтруктураМетрики();
	СтруктураСобытияМетрики["ClientInstanceID"]	= Объект.ПараметрыКлиентСерверМетрика.ИдентификаторКлиента;
	Возврат ЭтаФорма;
	
КонецФункции

&НаКлиенте
Функция УстановитьПараметр(ПутьКПараметру, Значение) Экспорт
	
	Путь 	= Метрика_РазложитьСтрокуВМассивСлов(ПутьКПараметру, ".");
	Эл		= СтруктураСобытияМетрики;
	НовыйЭл	= СтруктураСобытияМетрики;
	Для Каждого ЧастьПути Из Путь Цикл
		Эл = НовыйЭл;
		Если Эл[(ЧастьПути)] = Неопределено Тогда
			Эл.Вставить((ЧастьПути), Новый Соответствие);
		КонецЕсли;
		НовыйЭл = Эл[(ЧастьПути)];
	КонецЦикла;
	Эл.Вставить((ЧастьПути), Значение);
	
	Возврат ЭтаФорма;
	
КонецФункции

&НаКлиенте
Процедура НовыйСтекСобытийКлиент()
	
	СтекСобытийКлиент = Новый Структура;
	СтекСобытийКлиент.Вставить("МассивСобытий", Новый Массив);
	
КонецПроцедуры

&НаКлиенте
Функция Метрика_СобратьСтекСобытийКлиент() Экспорт
	
	Если СтекСобытийКлиент = Неопределено Тогда
		Возврат Новый Массив;
	КонецЕсли;
	
	ТекущийСтек = СтекСобытийКлиент.МассивСобытий;
	НовыйСтекСобытийКлиент();
	
	Возврат ТекущийСтек;
	
КонецФункции

//ТЕРМИНАЛЬНЫЙ ОПЕРАЦИИ {

&НаКлиенте
// Отправляет данные в метрику
//
// Возвращаемое значение:
//   Булево   - признак удачной отправки
//
Функция Отправить() Экспорт

	Метрика = Метрика_НовыйМетрика(СтруктураСобытияМетрики["ClientInstanceID"],
										СтруктураСобытияМетрики["Time"],
										СтруктураСобытияМетрики["Path"],
										СтруктураСобытияМетрики["TraceID"],
										СтруктураСобытияМетрики["Session"],
										СтруктураСобытияМетрики["AppContext"],
										СтруктураСобытияМетрики["Variables"]);
	Результат = Метрика_ОтправитьСобытиеСервер(Метрика, СтруктураСобытияМетрики["Topic"]);
	Возврат Результат;

КонецФункции // Отправить()

&НаСервере
Функция Метрика_ОтправитьСобытиеСервер(Метрика, Топик)
	
	Возврат МодульОбъекта().Метрика_ОтправитьСобытие(Метрика, Топик);
	
КонецФункции // Метрика_ОтправитьСобытиеСервер()

&НаКлиенте
// Для отложенной отправки помещает структру событий в стек
//
//
// Возвращаемое значение:
//   Число   - длина очереди
//
Функция ПоместитьВОчередь() Экспорт
	
	ВремяВозникновения(ТекущаяДата());
	Метрика = Метрика_НовыйМетрика(СтруктураСобытияМетрики["ClientInstanceID"],
									СтруктураСобытияМетрики["Time"],
									СтруктураСобытияМетрики["Path"],
									СтруктураСобытияМетрики["TraceID"],
									СтруктураСобытияМетрики["Session"],
									СтруктураСобытияМетрики["AppContext"],
									СтруктураСобытияМетрики["Variables"]);
 	Результат = Метрика_ПоместитьСобытиеВСтекКлиент(Метрика, СтруктураСобытияМетрики["Topic"]);
	Возврат Результат;

КонецФункции // ПоместитьВОчередь()

&НаКлиенте
Функция Метрика_ПоместитьСобытиеВСтекКлиент(Метрика_Событие, Топик = "Behavior")
	
	Если СтекСобытийКлиент = Неопределено Тогда
		НовыйСтекСобытийКлиент();
	КонецЕсли;
	
	СтекСобытийКлиент.МассивСобытий.Добавить(Новый Структура("Топик, Метрика", 
											Топик, 
											Метрика_Событие));
	
	Возврат СтекСобытийКлиент.МассивСобытий.Количество();
	
КонецФункции

//} ТЕРМИНАЛЬНЫЕ ОПЕРАЦИИ

//Важные операции

&НаКлиенте
// Отправляет событие начала замера производительности
//
// Возвращаемое значение:
//   УникальныйИдентификатор   - ИД для замера производительности
//
Функция НачатьЗамер(ИДЗамера) Экспорт

	Возврат Здоровье()
			.Событие("start")
			.УстановитьИДЦепочки(ИДЗамера);
			
КонецФункции // НачатьЗамерПроизводительности()

&НаКлиенте
// Отправляет событие окончания замера производительности
//
// Параметры:
//  ИДЗамера  - УникальныеИдентификатор - ид начала замера
// Возвращаемое значение:
//   УникальныйИдентификатор   - ИД для замера производительности
//
Функция ЗакончитьЗамер(ИДЗамера) Экспорт
	
	Возврат Здоровье()
			.Событие("end")
			.УстановитьИДЦепочки(ИДЗамера);
			
КонецФункции // НачатьЗамерПроизводительности()

&НаКлиенте
// Отправить какую-либо дополнительную информацию
//
// Параметры:
//  ИмяПеременной  - Строка - имя поля
//  ЗначениеПеременной  - Строка, Число, УникальныеИдентификатор
//
// Возвращаемое значение:
//   Форма
//
Функция ДобавитьПеременную(ИмяПеременной, ЗначениеПеременной) Экспорт

	Если СтруктураСобытияМетрики["Variables"] = Неопределено Тогда
		СтруктураСобытияМетрики["Variables"] = Новый Соответствие;
	КонецЕсли;

	СтруктураСобытияМетрики["Variables"].Вставить(ИмяПеременной, ЗначениеПеременной);
	
	Возврат ЭтаФорма
	
КонецФункции // ДобавитьПеременную()

//Цепочки событий

&НаКлиенте
Функция НачатьЦепочкуСобытий(ИмяЦепочки) Экспорт
	
	ЦепочкаСобытий = ИмяЦепочки;
	Возврат УстановитьИДЦепочки(ИмяЦепочки);
	
КонецФункции

&НаКлиенте
Функция ЗакончитьЦепочкуСобытий(ИмяЦепочки) Экспорт
	
	ЦепочкаСобытий = Неопределено;
	Возврат УстановитьИДЦепочки(ИмяЦепочки);
	
КонецФункции

//УКАЗАНИЕ ТОПИКОВ {

&НаКлиенте
// Указывается какой топик использовать
//
// Параметры:
//  Топик  - Строка - имя топика для отправки: Behavior, EventLog и т.д.
// Возвращаемое значение:
//   Форма
//
Функция Топик(Топик) Экспорт
	
	Возврат УстановитьПараметр("Topic", Топик);

КонецФункции // Топик()

&НаКлиенте
Функция Поведение() Экспорт
	
	Возврат Топик("Behavior").УстановитьИДЦепочки(ЦепочкаСобытий);
	
КонецФункции // Поведение()

&НаКлиенте
Функция Журнал() Экспорт
	
	Возврат Топик("Log");
	
КонецФункции // Журнал()

&НаКлиенте
Функция Здоровье() Экспорт
	
	Возврат Топик("Health");
	
КонецФункции // Здоровье()

&НаКлиенте
Функция Статистика() Экспорт
	
	Возврат Топик("Statistics");
	
КонецФункции // Статистика()

&НаКлиенте
Функция ОбратнаяСвязь() Экспорт
	
	Возврат Топик("Feedback");
	
КонецФункции // ОбратнаяСвязь()

//} УКАЗАНИЕ ТОПИКОВ

&НаКлиенте
// Устанавливает категорию классификации события
//
// Параметры:
//  ИмяКатегории  - Строка - имя используемой категории(Обмен, Проверка списка и т.д.)
//
// Возвращаемое значение:
//   Форма
//
Функция Категория(ИмяКатегории) Экспорт

	Возврат УстановитьПараметр("Path.Category", ИмяКатегории);;

КонецФункции // Категория()

&НаКлиенте
// Устанавливает имя события
//
// Параметры:
//  ИмяКатегории  - Строка - имя события(buttonClick, openForm и т.д.)
//
// Возвращаемое значение:
//   Форма
//
Функция Событие(ИмяСобытия) Экспорт

	Возврат УстановитьПараметр("Path.Action", ИмяСобытия);

КонецФункции // Событие()

&НаКлиенте
// Добавляет параметр Метка. Ярлык события
//
// Параметры:
//  Метка  - Строка - устанавливаемая метка
//
// Возвращаемое значение:
//   Форма
//
Функция Метка(Метка) Экспорт
	
	Возврат УстановитьПараметр("Path.Label", Метка);

КонецФункции // Метка()

&НаКлиенте
// Добавляет параметр Представление. Место возникновения события, форма, панель и т.д.
//
// Параметры:
//  Преставление  - Строка - устанавливаемая метка
//
// Возвращаемое значение:
//   Форма
//
Функция Представление(Представление) Экспорт
	
	Возврат УстановитьПараметр("Path.View", Представление);

КонецФункции // Метка()

&НаКлиенте
// Указывает время возникновения, если это не текущее событие
//
// Параметры:
//  ВремяВозникновения  - Дата - Время, когда случилось событие
//
// Возвращаемое значение:
//   Форма
//
Функция ВремяВозникновения(ВремяВозникновения)

	ПриведенноеВремя = ВремяВозникновения + РазницаЧасовыхПоясов;
	Возврат УстановитьПараметр("Time.ClientTime", ПриведенноеВремя);

КонецФункции // ВремяВозникновения()

&НаКлиенте
// Добавляет файл к отправке как base64
//
// Параметры:
//  ДанныеДляЗаписи		- Строка, Файл, ДвоичныеДанные
//  ИмяФайла			- Строка
//
// Возвращаемое значение:
//   Форма
//
Функция ДобавитьФайл(ДанныеДляЗаписи, ИмяФайла = Неопределено) Экспорт
	Если ТипЗнч(ДанныеДляЗаписи) = Тип("Строка") Тогда
		Файл = Новый Файл(ДанныеДляЗаписи);
		Если Не Файл.Существует() Или Файл.ЭтоКаталог() Тогда
			ВызватьИсключение "Передан некорректный путь к файлу";
		КонецЕсли;
		ДД = Новый ДвоичныеДанные(ДанныеДляЗаписи);
		Если ИмяФайла = Неопределено Тогда
			ИмяФайла = Файл.ИмяБезРасширения;
		КонецЕсли;
	ИначеЕсли ТипЗнч(ДанныеДляЗаписи) = Тип("Файл") Тогда
		ДД = Новый ДвоичныеДанные(ДанныеДляЗаписи.ПолноеИмя);
		Если ИмяФайла = Неопределено Тогда
			ИмяФайла = ДанныеДляЗаписи.ИмяБезРасширения;
		КонецЕсли;
	ИначеЕсли ТипЗнч(ДанныеДляЗаписи) = Тип("ДвоичныеДанные") Тогда
		ДД = ДанныеДляЗаписи;
		Если ИмяФайла = Неопределено Тогда
			ИмяФайла = "binary";
		КонецЕсли;
	Иначе
		//"Переданные неподдерживаемые данные для сохранения в base64"
		Возврат ЭтаФорма;
	КонецЕсли;
	
	Возврат ДобавитьПеременную(ИмяФайла, ДД);

КонецФункции // ДобавитьФайл()

&НаКлиенте
// Добавляет уникальные идентификатор объекта в дополнительные переменные
//
// Параметры:
//  ОбъектСсылка  - ЛюбаяСсылка
//  ИмяОбъекта  - Строка 
//
// Возвращаемое значение:
//   Форма
//
Функция ДобавитьУИД(ОбъектСсылка, ИмяОбъекта = Неопределено) Экспорт

	Попытка
		УИД = ОбъектСсылка.УникальныйИдентификатор();
	Исключение
		ВызватьИсключение "Не удалось получить УИД объекта";
	КонецПопытки;
	
	Если ИмяОбъекта = Неопределено Тогда
		Попытка
			ИмяОбъекта = Строка(ОбъектСсылка);
		Исключение
			ИмяОбъекта = "UUID";
		КонецПопытки;
	КонецЕсли;
	
	Возврат ДобавитьПеременную(ИмяОбъекта, УИД);
	
КонецФункции // ДобавитьУИД()

&НаКлиенте
// Добавлять идентификатор цепочки событий
//
// Параметры:
//  ИД  - УникальныйИдентификатор, Строка
//
// Возвращаемое значение:
//   Форма
//
Функция УстановитьИДЦепочки(ИД) Экспорт
	
	Возврат УстановитьПараметр("TraceID", ИД);

КонецФункции // УстановитьИДЦепочки()

&НаКлиенте
// Установить признак отправки системной информации
//
// Возвращаемое значение:
//   Форма
//
Функция ССистемнойИнформацией() Экспорт

	Возврат УстановитьПараметр("AppContext", Объект.ПараметрыКлиентСерверМетрика.КонтекстПриложенияКлиент);
	
КонецФункции // ССистемнойИнформацией()

//ДЕКОРАТОР ЧАСТЫХ ОПЕРАЦИЙ

//Отправка начала/конца сеанса

&НаКлиенте
// Отправляет событие в метрику о начале сеанса
//
// Возвращаемое значение:
//   Форма
//
Функция НачалоСеанса() Экспорт

	Возврат Поведение()
			.Категория("session")
			.Событие("start")
			.ССистемнойИнформацией();

КонецФункции // НачалоСеанса()

&НаКлиенте
// Отправляет событие в метрику о конце сеанса
//
// Возвращаемое значение:
//   Форма
//
Функция КонецСеанса() Экспорт

	Возврат Поведение()
			.Категория("session")
			.Событие("finish");

КонецФункции // КонецСеанса()

//Отправка открытия/закрытия формы

&НаКлиенте
Функция НаФорме(Форма) Экспорт
	
	Возврат Представление(ИмяФормы(Форма))
			.ДобавитьПеременную("Форма.Заголовок", Форма.Заголовок);
			
КонецФункции
		
&НаКлиенте
// Отправляет событие открытия формы
//
// Параметры:
//  Форма  - УправляемаяФорма - форма, которая была открыта
//
// Возвращаемое значение:
//   Форма
//
Функция ОткрытаФорма(Форма) Экспорт
	
	Возврат Поведение()
			.НаФорме(Форма)
			.Событие("formOpen");
			
КонецФункции // ОткрытаФорма()

&НаКлиенте
// Отправляет событие закрытия формы
//
// Параметры:
//  Форма  - УправляемаяФорма - форма, которая была открыта
//
// Возвращаемое значение:
//   Форма
//
Функция ЗакрытаФорма(Форма) Экспорт
	
	Возврат Поведение()
			.НаФорме(Форма)
			.Событие("formClose");
			
КонецФункции // ЗакрытаФорма()

//Отправка событий элементов

&НаКлиенте
Функция Элемента(Элемент)
	
	Возврат Метка(Элемент.Имя)
			.ДобавитьПеременную("Элемент.Заголовок", Элемент.Заголовок);

КонецФункции

&НаКлиенте
//Отправляет событие о выборе произвольного объекта
//
// Параметры:
//  ИмяОбъекта  - имя выбранного объекта
//
// Возвращаемое значение:
//   Форма
//
Функция Выбор(ИмяОбъекта) Экспорт
	
	Возврат Поведение()
			.Метка(ИмяОбъекта)
			.Событие("selection");
	
КонецФункции

&НаКлиенте
//Отправляет событие по нажатию кнопки
//
// Параметры:
//  Кнопка  - КнопкаФормы - нажатая кнопка. НЕ КОМАНДА!
//
// Возвращаемое значение:
//   Форма
//
Функция НажатаКнопка(Кнопка) Экспорт
	
	Возврат Поведение()
			.Элемента(Кнопка)
			.Событие("buttonClick");
			
КонецФункции

&НаКлиенте
//Отправляет событие по нажатию гиперссылки
//
// Параметры:
//  Надпись  - ПолеФормы - элемент формы соответствующий надписи
//
// Возвращаемое значение:
//   Форма
//
Функция НажатаНадпись(Надпись) Экспорт
	
	Возврат Поведение()
			.Элемента(Надпись)
			.Событие("labelClick");
			
КонецФункции

//Поле ввода

&НаКлиенте
//Отправляет событие по нажатию гиперссылки
//
// Параметры:
//  ПолеВвода  - ПолеФормы - элемент формы соответствующий полю ввода
//
// Возвращаемое значение:
//   Форма
//
Функция ПолеВводаПриИзменении(ПолеВвода) Экспорт

	Возврат Поведение()
			.Элемента(ПолеВвода)
			.Событие("inputModify");

КонецФункции // ПолеВводаПриИзменении()

&НаКлиенте
Функция ПолеВводаНачалоВыбора(ПолеВвода) Экспорт
	
	Возврат Поведение()
			.Элемента(ПолеВвода)
			.Событие("inputStartChoosing");
	
КонецФункции // ПолеВводаНачалоВыбора

&НаКлиенте
Функция ПолеВводаОчистка(ПолеВвода) Экспорт
	
	Возврат Поведение()
			.Элемента(ПолеВвода)
			.Событие("inputClear");
	
КонецФункции // ПолеВводаОчистка

&НаКлиенте
Функция ПолеВводаРегулирование(ПолеВвода) Экспорт
	
	Возврат Поведение()
			.Элемента(ПолеВвода)
			.Событие("inputChange");
	
КонецФункции // ПолеВводаРегулирование

&НаКлиенте
Функция ПолеВводаОткрытие(ПолеВвода) Экспорт
	
	Возврат Поведение()
			.Элемента(ПолеВвода)
			.Событие("inputOpenValue");
	
КонецФункции // ПолеВводаОткрытие

&НаКлиенте
Функция ПолеВводаОбработкаВыбора(ПолеВвода) Экспорт
	
	Возврат Поведение()
			.Элемента(ПолеВвода)
			.Событие("inputChoose");
	
КонецФункции // ПолеВводаОбработкаВыборка

//Страницы

&НаКлиенте
// Отправляет событие при смене страницы
//
// Параметры:
//  Страница  - ГруппаФормы - Группа соотв. текущей странице
//
// Возвращаемое значение:
//   Форма
//
Функция СменаСтраницы(Страница) Экспорт

	Возврат Поведение()
			.Элемента(Страница)
			.Событие("pageChange");

КонецФункции // СменаСтраницы()

&НаКлиенте
// Отправляет событие при смене флага
//
// Параметры:
//  Флажок  - ПолеФормы - элемент управления флажок
//	Значение- Булево - значение флага
//
// Возвращаемое значение:
//   Форма
//
Функция ПриСменеФлажка(Флажок, Значение) Экспорт
	
	Возврат Поведение()
			.Элемента(Флажок)
			.Событие("checkbox" + ?(Значение, "Check", "Uncheck"));
			
КонецФункции

//Сбор ошибок

&НаКлиенте
// Отправляет данные о возникшей ошибке
//
// Параметры:
//  МестоОшибки		- Строка - событие, взвавшее ошибку, например ВыводДанных.ПолучитьОбласть
//  ОписаниеОшибки  - Строка - описание возникшей ощибки, например из ОписаниеОшибки()
//                 <продолжение описания параметра>
//
// Возвращаемое значение:
//   Форма
//
Функция Ошибка(Место, ОписаниеОшибки) Экспорт
	
	Возврат Журнал()
			.Событие("error")
			.Категория(Место)
			.Метка(ОписаниеОшибки);
			
КонецФункции // Ошибка()

&НаКлиенте
// Отправляет произвольную информацию для лога
//
// Параметры:
//  Место			- Строка - событие, для фиксации информации
//  Информация		- Строка - информация о событии
//                 <продолжение описания параметра>
//
// Возвращаемое значение:
//   Форма
//
Функция Информация(Место, Информация) Экспорт
	
	Возврат Журнал()
			.Событие("info")
			.Категория(Место)
			.Метка(Информация);
			
КонецФункции // Информация()

//ОСНОВНЫЕ ПРОЦЕДУРЫ/ФУНКЦИИ РАБОТЫ С МЕТРИКОЙ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
		
	Параметры.Свойство("ОбъектПараметрыКлиентСервер", Объект.ПараметрыКлиентСерверМетрика);
		
КонецПроцедуры

&НаКлиенте 
Процедура ИнициализироватьКонтекстПриложенияКлиент() Экспорт

	Объект.ПараметрыКлиентСерверМетрика.КонтекстПриложенияКлиент = Метрика_СформироватьКонтекстПриложенияКлиент();
	
КонецПроцедуры

&НаКлиенте 
Процедура ВычислитьРазницуЧасовыхПоясов() Экспорт
	
	РазницаЧасовыхПоясов = ВычислитьРазницуЧасовыхПоясовСервер(ТекущаяДата());
	
КонецПроцедуры

&НаСервереБезКонтекста 
Функция ВычислитьРазницуЧасовыхПоясовСервер(ТекущаяДатаКлиент)
	
	Возврат ТекущаяДатаКлиент - ТекущаяДатаСеанса();
	
КонецФункции

//ИЗ ГЛОБАЛЬНЫХ МОДУЛЕЙ

&НаКлиенте
Функция Метрика_СформироватьКонтекстПриложенияКлиент() Экспорт
	
	AppVersion 					= Объект.ПараметрыКлиентСерверМетрика.КонтекстПриложенияСервер["AppVersion"]; 
	КП_Браузер 					= Неопределено; 
	КП_АппаратноеОбеспечение 	= Метрика_НовыйКонтекстПриложенияАппаратноеОбеспечение(); 
	КП_ОС 						= Метрика_НовыйКонтекстПриложенияОС(); 
	КП_Платформа 				= Объект.ПараметрыКлиентСерверМетрика.КонтекстПриложенияСервер["Platform"];
	
	Возврат Метрика_НовыйКонтекстПриложения(AppVersion, 
											КП_Браузер, 
											КП_АппаратноеОбеспечение, 
											КП_ОС, 
											КП_Платформа);
	
КонецФункции

&НаКлиенте
Функция Метрика_НовыйКонтекстПриложенияАппаратноеОбеспечение() Экспорт
	
	Перем CoresCount, TotalMemoryGb;
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	
	TotalMemoryGb = Окр(СистемнаяИнформация.ОперативнаяПамять / 1000);
	
	//
	
	КП_АппаратноеОбеспечение = Новый Соответствие;
	//КП_АппаратноеОбеспечение.Вставить("CoresCount"	 , CoresCount);
	КП_АппаратноеОбеспечение.Вставить("TotalMemoryGb", TotalMemoryGb);
	
	Возврат КП_АппаратноеОбеспечение; 
	
КонецФункции

&НаКлиенте
Функция Метрика_НовыйКонтекстПриложенияОС() Экспорт
	
	Перем BitSet, Name, Version;
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	СтрокаТипПлатформы  = НРег(СистемнаяИнформация.ТипПлатформы);	
	
	// 
	
	Если Найти(СтрокаТипПлатформы, "64") <> 0 Тогда
		BitSet = "x64";
	Иначе
		BitSet = "x86";	
	КонецЕсли;
	
	// 
	
	Если Найти(СтрокаТипПлатформы, НРег("Linux")) <> 0 Тогда
		Name = "Linux";
	ИначеЕсли Найти(СтрокаТипПлатформы, НРег("MacOS")) <> 0 Тогда
		Name = "MacOS";
	ИначеЕсли Найти(СтрокаТипПлатформы, НРег("Windows")) <> 0 Тогда	
		Name = "Windows";	
	КонецЕсли;	

	Version = "0.0.0";
	
	// С версией какие-то авантюры нужны
	
	КП_ОС = Новый Соответствие;
	КП_ОС.Вставить("BitSet"	, BitSet);
	КП_ОС.Вставить("Name"	, Name);
	КП_ОС.Вставить("Version", Version);
	
	Возврат КП_ОС; 
	
КонецФункции

&НаКлиенте
Функция Метрика_НовыйКонтекстПриложения(Знач AppVersion = Неопределено, 
										КП_Браузер = Неопределено, 
										КП_АппаратноеОбеспечение = Неопределено, 
										КП_ОС = Неопределено, 
										КП_Платформа = Неопределено) Экспорт
		
	КонтекстПриложения = Новый Соответствие;
	КонтекстПриложения.Вставить("AppVersion", AppVersion);
	КонтекстПриложения.Вставить("Browser"	, КП_Браузер);
	КонтекстПриложения.Вставить("Hardware"	, КП_АппаратноеОбеспечение);
	КонтекстПриложения.Вставить("OS"		, КП_ОС);
	КонтекстПриложения.Вставить("Platform"	, КП_Платформа);
	
	Если AppVersion = Неопределено Тогда
		КонтекстПриложения.Удалить("AppVersion");	
	КонецЕсли;
	
	Если КП_Браузер = Неопределено Тогда
		КонтекстПриложения.Удалить("Browser");	
	КонецЕсли;
	
	Если КП_АппаратноеОбеспечение = Неопределено Тогда
		КонтекстПриложения.Удалить("Hardware");	
	КонецЕсли;

	Если КП_ОС = Неопределено Тогда
		КонтекстПриложения.Удалить("OS");	
	КонецЕсли;

	Если КП_Платформа = Неопределено Тогда
		КонтекстПриложения.Удалить("Platform");	
	КонецЕсли;
	
	Возврат КонтекстПриложения; 
	
КонецФункции

&НаКлиенте
Функция Метрика_ТиповаяСтруктураМетрики() Экспорт
	
	СтруктураСобытия = Новый Соответствие;
	
	//Обязательные поля
	
	СтруктураСобытия.Вставить("ID", 					Строка(Новый УникальныйИдентификатор));
	СтруктураСобытия.Вставить("ClientInstanceId");
	СтруктураСобытия.Вставить("Time");
	СтруктураСобытия.Вставить("Path");
	СтруктураСобытия.Вставить("Variables");
	СтруктураСобытия.Вставить("Session", 				Метрика_НовыйСессия(Объект.ПараметрыКлиентСерверМетрика.ИдентификаторСессии));
	СтруктураСобытия.Вставить("TraceId");
	СтруктураСобытия.Вставить("AppContext");
	
	СтруктураСобытия.Вставить("Topic");
	
	Возврат СтруктураСобытия;
	
КонецФункции

&НаКлиенте
Функция Метрика_НовыйСессия(CustomSessionId) Экспорт
	
	Сессия = Новый Соответствие;	
	Сессия.Вставить("CustomSessionId",				CustomSessionId);	
		
	Возврат Сессия;
	
КонецФункции

&НаКлиенте
Функция Метрика_НовыйМетрика(ClientInstanceId, 
								МоментВремени, 
								Событие, 
								TraceID				= Неопределено,
								Сессия				= Неопределено, 
								КонтекстПриложения 	= Неопределено, 
								Переменные 			= Неопределено) Экспорт
	
	Перем Variables;
	
	Метрика = Новый Соответствие;
	Метрика.Вставить("Id"			   	 , Строка(Новый УникальныйИдентификатор));
	Метрика.Вставить("ClientInstanceId"	 , ClientInstanceId);
	Метрика.Вставить("Time"			   	 , МоментВремени);	
	Метрика.Вставить("Path"			   	 , Событие);
	Метрика.Вставить("TraceID"			 , Строка(TraceID));
	Метрика.Вставить("Session"		   	 , Сессия);
	Метрика.Вставить("AppContext"		 , КонтекстПриложения);	
		
	// Преобразовать Variables
	
	Метрика.Вставить("Variables", Переменные);
	
	// Капризная
	
	Если Сессия = Неопределено Тогда
		Метрика.Удалить("Session");			
	КонецЕсли;
	
	Если КонтекстПриложения = Неопределено Тогда
		Метрика.Удалить("AppContext");			
	КонецЕсли;
	
	Если Переменные = Неопределено Тогда
		Метрика.Удалить("Variables");			
	КонецЕсли;
	
	Если TraceID = Неопределено Тогда
		Метрика.Удалить("TraceID");			
	КонецЕсли;	
	
	Возврат Метрика;
	
КонецФункции
