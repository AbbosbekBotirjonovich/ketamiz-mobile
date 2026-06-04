/// Terms of Use content ported verbatim from the Ketamiz web app.
/// Version 2.5.0 — May 3, 2026.
library;

class TermsSection {
  final String title;
  final List<String> content;
  const TermsSection(this.title, this.content);
}

class TermsContent {
  final String title;
  final String subtitle;
  final List<TermsSection> sections;
  const TermsContent({
    required this.title,
    required this.subtitle,
    required this.sections,
  });
}

/// Returns the terms for the given language code, falling back to Uzbek.
TermsContent termsForLanguage(String code) =>
    kTerms[code] ?? kTerms['uz']!;

const Map<String, TermsContent> kTerms = {
  'en': _termsEn,
  'ru': _termsRu,
  'uz': _termsUz,
};

const TermsContent _termsEn = TermsContent(
  title: "Terms and Conditions of Use",
  subtitle:
      "Official agreement for using the Ketamiz.com platform. Version 2.5.0 — May 3, 2026",
  sections: [
    TermsSection("1. General Provisions", [
      "Ketamiz.com is an information platform designed to coordinate transport services between drivers and passengers. By registering or using the platform, you fully agree to these Terms. If you do not agree, you may not use the platform."
    ]),
    TermsSection("2. User Types", [
      "Passenger (Client) — a person who books a trip.",
      "Driver — a person who offers and manages trips.",
      "Each user type has distinct rights and responsibilities."
    ]),
    TermsSection("3. Booking Rules", [
      "Upon booking, the trip cost and service fee are deducted from the user's internal platform balance.",
      "Seats are considered reserved only after a successful transaction.",
      "A driver may not book their own trip."
    ]),
    TermsSection("4. Payment and Balance", [
      "Passenger: payment is deducted at the time of booking; if the balance is insufficient, the booking cannot proceed.",
      "Driver: earnings are credited to the balance after booking confirmation; the platform retains a service fee."
    ]),
    TermsSection("5. Service Fee (Commission)", [
      "The platform charges a fixed service fee for each successful booking. The commission is applied at the time of booking or cancellation and is non-refundable unless otherwise stated."
    ]),
    TermsSection("6. Adding a Passenger", [
      "Additional passengers can be added to an existing booking; a separate charge is applied for each.",
      "The number of passengers added cannot exceed the available seats on the trip."
    ]),
    TermsSection("7. Removing a Passenger", [
      "Passenger removal is only permitted at least 2 hours before the trip departure.",
      "Refunds are partial: the service fee and cancellation charge are retained."
    ]),
    TermsSection("8. Cancellation Policy", [
      "Cancellations must be made at least 2 hours before the scheduled departure.",
      "Upon cancellation, a partial refund is issued; platform commission and cancellation fee are deducted.",
      "If the driver cancels, all passengers receive a full refund and may be eligible for additional compensation."
    ]),
    TermsSection("9. Trip Status", [
      "Active — trip is available and accepting bookings.",
      "Full — all seats are booked; no new bookings accepted.",
      "Cancelled — trip or booking has been cancelled.",
      "Completed — trip has successfully concluded."
    ]),
    TermsSection("10. Liability", [
      "Ketamiz.com acts solely as an intermediary and is not liable for the actual execution of any trip.",
      "The driver is fully responsible for the safety of passengers.",
      "Passengers must provide accurate personal information."
    ]),
    TermsSection("11. Balance and Transactions", [
      "All financial operations (debits and credits) are recorded and stored on the platform. Users may view their transaction history through the dashboard."
    ]),
    TermsSection("12. Fraud and Misuse", [
      "Strictly prohibited: fake bookings, submission of false information, and circumventing the payment system.",
      "Upon detection, the account is blocked and the balance may be frozen."
    ]),
    TermsSection("13. Amendments to Terms", [
      "The platform may amend these Terms unilaterally at any time. Changes take effect upon publication. Continued use of the platform constitutes acceptance of the updated terms."
    ]),
    TermsSection("14. Consent", [
      "By completing registration, the user fully accepts these Terms and undertakes to comply with all platform rules."
    ]),
    TermsSection("15. Viewing Trips", [
      "All active and fully booked trips are visible to registered users. Each trip is displayed with route, time, price, and available seat information."
    ]),
    TermsSection("16. Access to Trip Information", [
      "Detailed trip information is only available for trips the user has personally booked.",
      "Other trips are displayed in a general, summary view only."
    ]),
    TermsSection("17. Trip Statuses — Important", [
      "Active — trip is available for booking.",
      "Full — all seats are occupied.",
      "In Progress — trip has started; modifications are restricted.",
      "Completed — trip has ended; refunds and changes are not possible.",
      "Cancelled — trip or booking has been cancelled."
    ]),
    TermsSection("18. Trip In Progress", [
      "A trip is considered 'in progress' from its start time until completion.",
      "During this period: adding passengers, cancellation, and refunds are not permitted."
    ]),
    TermsSection("19. Completed Trip", [
      "Once a trip is completed, no refunds or booking modifications are possible. All transactions are considered final."
    ]),
    TermsSection("20. Cancelled Trips", [
      "Cancelled trips are retained in the user's history and remain viewable. A cancelled trip cannot be reinstated."
    ]),
    TermsSection("21. User History", [
      "The platform provides users access to their trip history: active, completed, and cancelled. This information is accessible only to the account holder."
    ]),
    TermsSection("22. Time-Based Restrictions", [
      "2 hours or more before departure: cancellation is permitted.",
      "Less than 2 hours before departure: cancellation and passenger removal are prohibited; no refund is issued."
    ]),
    TermsSection("23. Data Accuracy", [
      "Users must provide accurate name, phone number, and location details.",
      "The platform is not responsible for issues arising from inaccurate data; affected bookings may be cancelled."
    ]),
    TermsSection("24. Platform Limitations", [
      "Ketamiz.com is not responsible for driver delays.",
      "The platform does not mediate personal disputes between drivers and passengers.",
      "The platform operates exclusively as an information intermediary."
    ]),
    TermsSection("25. Technical Failures", [
      "The platform is not liable for losses resulting from internet outages, server errors, or failures in third-party payment systems."
    ]),
    TermsSection("26. Account Suspension", [
      "Accounts are suspended for: repeated unjustified cancellations, fake bookings, and payment manipulation.",
      "Suspension may occur without prior notice."
    ]),
    TermsSection("27. Rule Violations", [
      "Upon detecting a rule violation, the platform may: cancel the booking, freeze the balance, and permanently suspend the account."
    ]),
    TermsSection("28. Driver Role", [
      "Drivers independently create trips, set prices, and accept passengers.",
      "Drivers bear full personal responsibility for their trips and passenger safety."
    ]),
    TermsSection("29. Trip Creation Rules", [
      "Drivers must accurately enter: route, time (start and end), price, and available seats.",
      "Creating multiple overlapping trips simultaneously is prohibited.",
      "Non-compliant submissions will be rejected by the system."
    ]),
    TermsSection("30. Driver Trip Visibility", [
      "Drivers can only view and manage their own trips, with filtering available by status: active, completed, and cancelled."
    ]),
    TermsSection("31. Trip Statuses — For Drivers", [
      "Active — bookings are accepted.",
      "Full — all seats are occupied.",
      "Completed — trip has concluded.",
      "Cancelled — trip has been cancelled."
    ]),
    TermsSection("32. Driver Trip Cancellation", [
      "If a driver cancels a trip: all bookings are annulled and passengers receive a full refund.",
      "The driver is charged: passenger compensation and platform service fee.",
      "Reinstatement of the trip is not possible."
    ]),
    TermsSection("33. Financial Liability — Driver", [
      "An unjustified cancellation by the driver incurs: full passenger refund, additional compensation, and platform service fee.",
      "These amounts are automatically deducted from the driver's balance."
    ]),
    TermsSection("34. Negative Balance", [
      "A driver's balance may become negative as a result of cancellations.",
      "The platform reserves the right to recover the debt from future earnings or pursue legal remedies."
    ]),
    TermsSection("35. Passenger Compensation", [
      "When a driver cancels a trip, the passenger receives a full refund and may be entitled to additional compensation as configured by the platform."
    ]),
    TermsSection("36. Platform Commission on Cancellation", [
      "Upon cancellation, the platform retains its service fee and commission. The applicable rate is determined by platform configuration."
    ]),
    TermsSection("37. Driver Restrictions", [
      "Drivers are prohibited from: unjustified trip cancellations, creating fictitious trips, and misleading passengers.",
      "Violations result in account suspension."
    ]),
    TermsSection("38. Driver Account Suspension", [
      "Driver accounts are suspended for: repeated cancellations, submission of false information, and financial manipulation. Suspension may occur without prior warning."
    ]),
    TermsSection("39. Archived Trips", [
      "Cancelled trips are archived in the platform database for audit and history purposes. Users may access this data through their dashboard."
    ]),
    TermsSection("40. Transactions", [
      "Every financial operation (debit and credit) is recorded in the system.",
      "By registering, the driver consents to this transaction recording system."
    ]),
    TermsSection("41. Platform Rights", [
      "Ketamiz.com reserves the right to: compulsorily cancel a trip, freeze balances, and revise commission rates.",
      "These rights are exercised to protect users and maintain platform integrity."
    ]),
    TermsSection("42. Registration and SMS Verification", [
      "Users must register with a valid phone number and complete SMS verification.",
      "An unverified account cannot create bookings or trips."
    ]),
    TermsSection("43. Use of Phone Number", [
      "A user's phone number may be used for: SMS verification, booking notifications, trip updates, and facilitating communication between driver and passenger."
    ]),
    TermsSection("44. Driver-Passenger Communication", [
      "Once a booking is confirmed, the platform may share the driver's and passenger's phone numbers with each other to facilitate trip coordination."
    ]),
    TermsSection("45. SMS Notifications", [
      "The platform may send SMS notifications for:",
      "New booking, booking cancellation, passenger addition or removal, trip cancellation, and balance changes."
    ]),
    TermsSection("46. Privacy", [
      "Phone numbers are shared only with the participants of the relevant trip.",
      "Data is not disclosed to third parties except as required by law."
    ]),
    TermsSection("47. User Obligations", [
      "Users must not use other users' data for spam, marketing, or disclosure to third parties.",
      "Violation of this obligation results in immediate account suspension."
    ]),
    TermsSection("48. Platform Liability — Communication", [
      "Ketamiz.com is not responsible for direct communications between users or agreements reached outside the platform. The platform solely provides the means of communication."
    ]),
    TermsSection("49. Misuse and Consequences", [
      "Prohibited: SMS spam, use of fake phone numbers, and harassment of other users.",
      "Consequences: account suspension and potential legal action."
    ]),
  ],
);

const TermsContent _termsRu = TermsContent(
  title: "Условия использования платформы",
  subtitle:
      "Официальное соглашение по использованию Ketamiz.com. Версия 2.5.0 — 3 мая 2026 г.",
  sections: [
    TermsSection("1. Общие положения", [
      "Ketamiz.com — информационная платформа для координации транспортных услуг между водителями и пассажирами. Регистрируясь или используя платформу, вы выражаете полное и безоговорочное согласие с настоящими условиями. Отказ от условий означает невозможность использования платформы."
    ]),
    TermsSection("2. Типы пользователей", [
      "Пассажир (Client) — лицо, бронирующее поездку.",
      "Водитель (Driver) — лицо, предлагающее поездку.",
      "Каждый тип пользователя имеет отдельные права и обязанности."
    ]),
    TermsSection("3. Правила бронирования", [
      "При бронировании стоимость поездки и сервисный сбор списываются с внутреннего баланса пользователя.",
      "Места считаются забронированными только после успешного завершения транзакции.",
      "Водитель не может забронировать собственную поездку."
    ]),
    TermsSection("4. Оплата и баланс", [
      "Пассажир: оплата списывается в момент бронирования; при недостаточном балансе бронирование не выполняется.",
      "Водитель: доход поступает на баланс после подтверждения бронирования, при этом платформа удерживает сервисный сбор."
    ]),
    TermsSection("5. Сервисный сбор (Комиссия)", [
      "Платформа удерживает установленный сервисный сбор за каждое успешное бронирование. Комиссия применяется в момент бронирования или отмены и возврату не подлежит, если иное не предусмотрено условиями."
    ]),
    TermsSection("6. Добавление пассажира", [
      "К существующему бронированию можно добавить нового пассажира; за каждого дополнительного пассажира взимается отдельная оплата.",
      "Количество добавляемых пассажиров не может превышать количество свободных мест."
    ]),
    TermsSection("7. Удаление пассажира", [
      "Удаление пассажира возможно не позднее чем за 2 часа до начала поездки.",
      "Возврат средств производится частично: сервисный сбор и плата за отмену удерживаются."
    ]),
    TermsSection("8. Отмена бронирования", [
      "Отмена должна быть выполнена не менее чем за 2 часа до начала поездки.",
      "При отмене пассажиру возвращается часть средств за вычетом комиссии и платы за отмену.",
      "При отмене водителем всем пассажирам гарантируется полный возврат средств и возможная компенсация."
    ]),
    TermsSection("9. Статус поездки", [
      "Active — поездка активна, бронирование принимается.",
      "Full — все места заняты, новые бронирования не принимаются.",
      "Cancelled — поездка или бронирование отменены.",
      "Completed — поездка успешно завершена."
    ]),
    TermsSection("10. Ответственность", [
      "Ketamiz.com выступает исключительно посредником и не несёт ответственности за фактическое выполнение поездки.",
      "Водитель несёт полную ответственность за безопасность пассажиров.",
      "Пассажир обязан вводить достоверные личные данные."
    ]),
    TermsSection("11. Баланс и транзакции", [
      "Все финансовые операции (дебет и кредит) фиксируются и хранятся на платформе. Пользователь может просматривать историю транзакций в личном кабинете."
    ]),
    TermsSection("12. Мошенничество и злоупотребление", [
      "Строго запрещены: фиктивные бронирования, ввод заведомо ложных данных и обход системы оплаты.",
      "При обнаружении нарушений аккаунт блокируется, баланс может быть заморожен."
    ]),
    TermsSection("13. Изменение условий", [
      "Платформа вправе в одностороннем порядке изменять настоящие условия в любое время. Изменения вступают в силу с момента публикации. Продолжение использования платформы означает согласие с новыми условиями."
    ]),
    TermsSection("14. Согласие", [
      "Проходя регистрацию, пользователь выражает полное согласие с настоящими условиями и берёт на себя обязательство соблюдать правила платформы."
    ]),
    TermsSection("15. Просмотр поездок", [
      "Все активные и заполненные поездки доступны для просмотра зарегистрированными пользователями. Каждая поездка отображается с маршрутом, временем, ценой и количеством свободных мест."
    ]),
    TermsSection("16. Доступ к информации о поездке", [
      "Подробная информация доступна только для поездок, забронированных пользователем.",
      "Остальные поездки отображаются только в общем виде."
    ]),
    TermsSection("17. Статусы поездок — важно", [
      "Active — поездка доступна для бронирования.",
      "Full — все места заняты.",
      "In Progress — поездка началась, изменения ограничены.",
      "Completed — поездка завершена, возврат и изменения невозможны.",
      "Cancelled — поездка или бронирование отменены."
    ]),
    TermsSection("18. Поездка в процессе (In Progress)", [
      "Поездка считается 'в процессе' с момента начала до завершения.",
      "В этот период добавление пассажиров, отмена и возврат средств невозможны."
    ]),
    TermsSection("19. Завершённая поездка (Completed)", [
      "После завершения поездки возврат средств и изменение бронирования невозможны. Все транзакции считаются окончательными."
    ]),
    TermsSection("20. Отменённые поездки (Cancelled)", [
      "Отменённые поездки сохраняются в истории и доступны для просмотра. Восстановление отменённой поездки невозможно."
    ]),
    TermsSection("21. История пользователя", [
      "Платформа предоставляет пользователю доступ к истории поездок: активных, завершённых и отменённых. Данные доступны только владельцу аккаунта."
    ]),
    TermsSection("22. Временны́е ограничения", [
      "За 2 часа и более до начала поездки: отмена разрешена.",
      "Менее чем за 2 часа до начала: отмена и удаление пассажиров запрещены, возврат средств не производится."
    ]),
    TermsSection("23. Достоверность данных", [
      "Пользователь обязан вводить корректные имя, номер телефона и адрес.",
      "Платформа не несёт ответственности за последствия ввода недостоверных данных; бронирование может быть аннулировано."
    ]),
    TermsSection("24. Ограничения платформы", [
      "Ketamiz.com не несёт ответственности за опоздания водителей.",
      "Платформа не урегулирует личные конфликты между водителем и пассажиром.",
      "Платформа действует исключительно как информационный посредник."
    ]),
    TermsSection("25. Технические сбои", [
      "Платформа не несёт ответственности за убытки, возникшие вследствие отключения интернета, серверных ошибок или сбоев в сторонних платёжных системах."
    ]),
    TermsSection("26. Блокировка аккаунта", [
      "Аккаунт блокируется в следующих случаях: систематические беспричинные отмены, фиктивные бронирования и манипуляции с оплатой.",
      "Блокировка может осуществляться без предварительного уведомления."
    ]),
    TermsSection("27. Нарушение правил", [
      "При нарушении правил платформа вправе: аннулировать бронирование, заморозить баланс и полностью заблокировать аккаунт."
    ]),
    TermsSection("28. Роль водителя", [
      "Водитель самостоятельно создаёт поездки, устанавливает цены и принимает пассажиров.",
      "Водитель несёт полную личную ответственность за свои поездки и безопасность пассажиров."
    ]),
    TermsSection("29. Правила создания поездки", [
      "Водитель обязан корректно указать маршрут, время (начало и конец), цену и количество мест.",
      "Создание нескольких пересекающихся поездок одновременно запрещено.",
      "При нарушении правил поездка не создаётся."
    ]),
    TermsSection("30. Права водителя на просмотр поездок", [
      "Водитель может просматривать и управлять только своими поездками, с возможностью фильтрации по статусу: активные, завершённые, отменённые."
    ]),
    TermsSection("31. Статусы поездок — для водителя", [
      "Active — принимаются бронирования.",
      "Full — все места заняты.",
      "Completed — поездка завершена.",
      "Cancelled — поездка отменена."
    ]),
    TermsSection("32. Отмена поездки водителем", [
      "При отмене поездки водителем: все бронирования аннулируются и пассажирам возвращаются полные средства.",
      "С водителя списываются: компенсация пассажирам и сервисный сбор платформы.",
      "Восстановление поездки невозможно."
    ]),
    TermsSection("33. Финансовая ответственность водителя", [
      "При беспричинной отмене водитель оплачивает: полный возврат пассажирам, дополнительную компенсацию и сервисный сбор платформы.",
      "Указанные суммы автоматически списываются с баланса водителя."
    ]),
    TermsSection("34. Отрицательный баланс", [
      "Баланс водителя может стать отрицательным в результате отмен.",
      "Платформа вправе удержать задолженность из будущих доходов или принять правовые меры."
    ]),
    TermsSection("35. Компенсация пассажиру", [
      "При отмене поездки водителем пассажир получает полный возврат средств и может получить дополнительную компенсацию в соответствии с конфигурацией платформы."
    ]),
    TermsSection("36. Комиссия платформы", [
      "При отмене платформа удерживает свой сервисный сбор и комиссию. Размер комиссии определяется конфигурацией платформы."
    ]),
    TermsSection("37. Ограничения для водителей", [
      "Водителю запрещено: беспричинно отменять поездки, создавать фиктивные поездки и вводить пассажиров в заблуждение.",
      "Нарушение правил влечёт блокировку аккаунта."
    ]),
    TermsSection("38. Блокировка аккаунта водителя", [
      "Аккаунт водителя блокируется за: систематические отмены, ввод недостоверных данных и финансовые манипуляции. Блокировка может осуществляться без предупреждения."
    ]),
    TermsSection("39. Архив поездок", [
      "Отменённые поездки хранятся в архиве базы данных платформы для целей аудита и истории. Пользователь может просматривать их через личный кабинет."
    ]),
    TermsSection("40. Транзакции", [
      "Каждая финансовая операция (списание и пополнение) фиксируется в системе.",
      "Регистрируясь, водитель соглашается с данной системой учёта транзакций."
    ]),
    TermsSection("41. Права платформы", [
      "Ketamiz.com вправе: принудительно отменить поездку, заморозить баланс и изменить ставку комиссии.",
      "Эти права применяются для защиты пользователей и обеспечения работы платформы."
    ]),
    TermsSection("42. Регистрация и SMS-подтверждение", [
      "Пользователь обязан зарегистрироваться с использованием действующего номера телефона и пройти SMS-верификацию.",
      "Неподтверждённый аккаунт не может создавать бронирования или поездки."
    ]),
    TermsSection("43. Использование номера телефона", [
      "Номер телефона пользователя может использоваться для: SMS-верификации, уведомлений о бронировании, изменений поездки и организации связи между водителем и пассажиром."
    ]),
    TermsSection("44. Связь водителя и пассажира", [
      "После подтверждения бронирования платформа может передать номера телефонов водителя и пассажира друг другу для удобства организации поездки."
    ]),
    TermsSection("45. SMS-уведомления", [
      "Платформа может отправлять SMS в следующих случаях:",
      "Новое бронирование, отмена бронирования, добавление или удаление пассажира, отмена поездки, изменения баланса."
    ]),
    TermsSection("46. Конфиденциальность", [
      "Номера телефонов передаются только участникам конкретной поездки.",
      "Данные не передаются третьим лицам, за исключением случаев, предусмотренных законом."
    ]),
    TermsSection("47. Обязанности пользователя", [
      "Пользователю запрещено использовать данные других пользователей для рассылки спама, маркетинга или передачи третьим лицам.",
      "Нарушение данного требования влечёт немедленную блокировку аккаунта."
    ]),
    TermsSection("48. Ответственность платформы — связь", [
      "Ketamiz.com не несёт ответственности за личное общение между пользователями и договорённости, достигнутые за пределами платформы. Платформа лишь предоставляет инструмент связи."
    ]),
    TermsSection("49. Нарушение правил использования и последствия", [
      "Запрещено: SMS-спам, использование поддельных номеров телефонов и преследование других пользователей.",
      "Последствия: блокировка аккаунта и возможное применение правовых мер."
    ]),
  ],
);

const TermsContent _termsUz = TermsContent(
  title: "Foydalanish shartlari va qoidalari",
  subtitle:
      "Ketamiz.com platformasidan foydalanish bo'yicha rasmiy kelishuv. Vertsiya 2.5.0 — 3-may 2026",
  sections: [
    TermsSection("1. Umumiy qoidalar", [
      "Ketamiz.com — haydovchilar va yo'lovchilar o'rtasida transport xizmatlarini muvofiqlashtirish uchun mo'ljallangan axborot platformasidir. Platformadan foydalanish orqali siz ushbu shartlarga to'liq rozilik bildirasiz. Agar rozi bo'lmasangiz, platformadan foydalanish huquqingiz yo'q."
    ]),
    TermsSection("2. Foydalanuvchi turlari", [
      "Mijoz (Client) — safarni band qiluvchi shaxs.",
      "Haydovchi (Driver) — safarni taklif qiluvchi va boshqaruvchi shaxs.",
      "Har bir foydalanuvchi turi uchun alohida huquq va majburiyatlar mavjud."
    ]),
    TermsSection("3. Band qilish (Booking) qoidalari", [
      "Safarni band qilishda to'lov oldindan foydalanuvchining platformadagi balansidan yechib olinadi.",
      "O'rindiqlar faqat to'lov muvaffaqiyatli amalga oshirilgandan so'ng rezerv hisoblanadi.",
      "Haydovchi bo'lgan foydalanuvchi o'z safarini band qila olmaydi."
    ]),
    TermsSection("4. To'lov va balans", [
      "Mijoz: to'lov booking vaqtida yechiladi; balans yetarli bo'lmasa — booking amalga oshmaydi.",
      "Haydovchi: daromad booking tasdiqlangandan so'ng balansga tushadi va platforma xizmat haqini ushlab qoladi."
    ]),
    TermsSection("5. Xizmat haqi (Komissiya)", [
      "Har bir booking uchun platforma belgilangan xizmat haqini ushlab qoladi. Komissiya booking yoki bekor qilish paytida qo'llanilishi mumkin va qaytarilmaydi, agar shartlarda boshqacha ko'rsatilmagan bo'lsa."
    ]),
    TermsSection("6. Qo'shimcha yo'lovchi qo'shish", [
      "Mavjud bookingga yangi yo'lovchi qo'shish mumkin, bunda har bir qo'shimcha yo'lovchi uchun alohida to'lov olinadi.",
      "Balansdan mablag' yechib olinadi. Safarning bo'sh o'rindiqlaridan ortiq yo'lovchi qo'shib bo'lmaydi."
    ]),
    TermsSection("7. Yo'lovchini olib tashlash", [
      "Yo'lovchini olib tashlash faqat safar boshlanishidan kamida 2 soat oldin amalga oshirilishi mumkin.",
      "Qaytariladigan mablag' to'liq bo'lmaydi: xizmat haqi va bekor qilish to'lovi ushlab qolinadi."
    ]),
    TermsSection("8. Bookingni bekor qilish", [
      "Bekor qilish safar boshlanishidan kamida 2 soat oldin amalga oshirilishi shart.",
      "Bekor qilinganda, mijozga to'lovning bir qismi qaytariladi; bekor qilish to'lovi va komissiya ushlab qolinadi.",
      "Haydovchi tomonidan bekor qilinganda, barcha yo'lovchilarga to'liq qaytariladi va qo'shimcha kompensatsiya taqdim etilishi mumkin."
    ]),
    TermsSection("9. Safar holati (Trip Status)", [
      "Active — safar faol, booking qabul qilinadi.",
      "Full — barcha o'rindiqlar band, yangi booking qabul qilinmaydi.",
      "Cancelled — safar yoki booking bekor qilingan.",
      "Completed — safar muvaffaqiyatli yakunlangan."
    ]),
    TermsSection("10. Javobgarlik", [
      "Ketamiz.com faqat vositachi sifatida ishlaydi va haydovchi hamda yo'lovchi o'rtasidagi real safar uchun javobgar emas.",
      "Haydovchi yo'lovchilar xavfsizligi uchun to'liq javobgardir.",
      "Mijoz to'g'ri shaxsiy ma'lumotlar kiritishi shart."
    ]),
    TermsSection("11. Balans va tranzaksiyalar", [
      "Platformadagi har bir moliyaviy harakat (debit va kredit) yozib boriladi va saqlanadi. Foydalanuvchi o'z tranzaksiyalar tarixini dashboard orqali ko'rishi mumkin."
    ]),
    TermsSection("12. Firibgarlik va noto'g'ri foydalanish", [
      "Quyidagilar qat'iyan taqiqlanadi: soxta booking, soxta ma'lumot kiritish va to'lovni chetlab o'tish.",
      "Bunday holat aniqlanganda hisob bloklanadi va balans muzlatilishi mumkin."
    ]),
    TermsSection("13. Shartlarga o'zgartirish kiritish", [
      "Ketamiz.com ushbu shartlarni istalgan vaqtda bir tomonlama o'zgartirish huquqiga ega. Yangilangan shartlar e'lon qilingan vaqtdan kuchga kiradi. Foydalanishni davom ettirish yangi shartlarga rozilik hisoblanadi."
    ]),
    TermsSection("14. Rozilik", [
      "Ro'yxatdan o'tish orqali foydalanuvchi ushbu shartlarga to'liq rozilik bildiradi va platforma qoidalariga amal qilishni o'z zimmasiga oladi."
    ]),
    TermsSection("15. Safarlarni ko'rish", [
      "Platformadagi barcha faol va to'ldirilgan safarlarni foydalanuvchi ko'rishi mumkin. Har bir safar yo'nalish, vaqt, narx va bo'sh o'rindiqlar ma'lumotlari bilan taqdim etiladi."
    ]),
    TermsSection("16. Safar ma'lumotlariga kirish", [
      "Foydalanuvchi faqat o'zi band qilgan safarlar haqida to'liq ma'lumot oladi.",
      "Boshqa safarlar faqat umumiy ko'rinishda taqdim etiladi."
    ]),
    TermsSection("17. Safar holatlari (Muhim)", [
      "Active — safar mavjud, booking mumkin.",
      "Full — barcha o'rindiqlar band, yangi booking qabul qilinmaydi.",
      "In Progress — safar boshlangan, o'zgartirishlar cheklangan.",
      "Completed — safar yakunlangan, o'zgartirish yoki qaytarish mumkin emas.",
      "Cancelled — safar yoki booking bekor qilingan."
    ]),
    TermsSection("18. Davom etayotgan safar (In Progress)", [
      "Safar boshlangan vaqtdan yakunlanguncha 'in progress' hisoblanadi.",
      "Bu davrda: yangi yo'lovchi qo'shib bo'lmaydi, bekor qilish va qaytarish mumkin emas."
    ]),
    TermsSection("19. Yakunlangan safar (Completed)", [
      "Safar tugagandan so'ng hech qanday qaytarish yoki o'zgartirish amalga oshirilmaydi. Platforma barcha tranzaksiyalarni yakunlangan deb hisoblaydi."
    ]),
    TermsSection("20. Bekor qilingan safarlar (Cancelled)", [
      "Bekor qilingan safarlar tarixda saqlanadi va foydalanuvchi ularni ko'ra oladi. Bekor qilingan safar qayta tiklanmaydi."
    ]),
    TermsSection("21. Foydalanuvchi tarixi", [
      "Platforma foydalanuvchiga o'tgan safarlar (faol, yakunlangan, bekor qilingan) tarixini taqdim etadi. Bu ma'lumotlar faqat hisob egasiga ko'rsatiladi."
    ]),
    TermsSection("22. Vaqtga bog'liq cheklovlar", [
      "Safar boshlanishidan 2 soat va undan ko'proq oldin: bekor qilish mumkin.",
      "Safar boshlanishiga 2 soatdan kam qolsa: bekor qilish va yo'lovchi olib tashlash taqiqlanadi, mablag' qaytarilmaydi."
    ]),
    TermsSection("23. Ma'lumotlar aniqligi", [
      "Foydalanuvchi ism, telefon raqami va manzil kabi barcha ma'lumotlarni to'g'ri kiritishga majbur.",
      "Noto'g'ri ma'lumot tufayli yuzaga keladigan muammolar uchun platforma javobgar emas va booking bekor qilinishi mumkin."
    ]),
    TermsSection("24. Platforma cheklovlari", [
      "Ketamiz.com safar vaqtiga kechikishlar uchun javobgar emas.",
      "Haydovchi va mijoz o'rtasidagi shaxsiy kelishmovchiliklar uchun platforma javobgarlikni o'z zimmasiga olmaydi.",
      "Platforma faqat axborot vositachisi sifatida xizmat qiladi."
    ]),
    TermsSection("25. Texnik uzilishlar", [
      "Platforma internet uzilishi, server xatolari yoki uchinchi tomon to'lov tizimlari xatoliklari natijasida yuzaga keladigan zararlar uchun javobgar emas."
    ]),
    TermsSection("26. Hisob bloklanishi", [
      "Quyidagi holatlarda hisob bloklanadi: ko'p marotaba asossiz bekor qilish, soxta booking yoki to'lov manipulyatsiyasi.",
      "Bloklash avvaldan ogohlantirmasdan amalga oshirilishi mumkin."
    ]),
    TermsSection("27. Qoidalarni buzish", [
      "Platforma qoidabuzarlik aniqlanganda quyidagi choralarni ko'rish huquqiga ega:",
      "Bookingni bekor qilish, balansni muzlatish va hisobni butunlay bloklash."
    ]),
    TermsSection("28. Haydovchi roli", [
      "Haydovchi platformada safar yaratadi, narx va shartlarni mustaqil belgilaydi.",
      "Haydovchi o'z safarlari va yo'lovchilar xavfsizligi uchun to'liq shaxsiy javobgardir."
    ]),
    TermsSection("29. Safar yaratish qoidalari", [
      "Haydovchi yo'nalish, vaqt (boshlanish va tugash), narx va bo'sh o'rindiqlar sonini to'g'ri kiritishi shart.",
      "Bir xil yo'nalishda bir vaqtning o'zida bir nechta ustma-ust tushadigan safarlar yaratish taqiqlanadi.",
      "Qoida buzilganda safar yaratilmaydi."
    ]),
    TermsSection("30. Haydovchining safarlarni ko'rish huquqi", [
      "Haydovchi faqat o'zi yaratgan safarlarni ko'rish va boshqarish huquqiga ega. Safarlarni faol, yakunlangan va bekor qilingan holat bo'yicha filtrlash mumkin."
    ]),
    TermsSection("31. Safar holatlari — haydovchi uchun", [
      "Active — booking qabul qilinadi.",
      "Full — barcha o'rindiqlar band.",
      "Completed — safar yakunlangan.",
      "Cancelled — safar bekor qilingan."
    ]),
    TermsSection("32. Safarni bekor qilish — haydovchi tomonidan", [
      "Haydovchi safarni bekor qilganda: barcha mavjud bookinglar bekor qilinadi va mijozlarga mablag' to'liq qaytariladi.",
      "Haydovchidan qo'shimcha kompensatsiya va platforma xizmat haqi yechib olinadi.",
      "Qayta tiklash imkoniyati mavjud emas."
    ]),
    TermsSection("33. Moliyaviy javobgarlik — haydovchi", [
      "Haydovchi safarni asossiz bekor qilganda quyidagilarni to'laydi: mijozga to'liq qaytarish, qo'shimcha kompensatsiya va platforma xizmat haqi.",
      "Ushbu summalar haydovchi balansidan avtomatik yechiladi."
    ]),
    TermsSection("34. Manfiy balans", [
      "Haydovchi balansi bekor qilishlar natijasida manfiy qiymatga tushishi mumkin.",
      "Platforma ushbu qarzdorlikni keyingi daromadlardan ushlab qolish yoki huquqiy choralar ko'rish huquqini o'zida saqlab qoladi."
    ]),
    TermsSection("35. Mijoz kompensatsiyasi", [
      "Haydovchi safarni bekor qilganda, mijoz to'liq mablag'ini qaytarib oladi va platforma konfiguratsiyasiga ko'ra qo'shimcha kompensatsiyaga haqli bo'lishi mumkin."
    ]),
    TermsSection("36. Platforma komissiyasi", [
      "Bekor qilish yuz berganda platforma o'z xizmat haqini va komissiyasini ushlab qolish huquqiga ega. Komissiya miqdori platforma konfiguratsiyasiga binoan belgilanadi."
    ]),
    TermsSection("37. Haydovchi uchun cheklovlar", [
      "Haydovchiga quyidagilar taqiqlanadi: safarni asossiz bekor qilish, soxta safar yaratish va yo'lovchilarni noto'g'ri yo'naltirish.",
      "Ushbu qoidalarni buzish hisobni bloklanishiga olib keladi."
    ]),
    TermsSection("38. Haydovchi hisobi bloklanishi", [
      "Quyidagi holatlarda haydovchi hisobi bloklanadi: ko'p marotaba asossiz bekor qilish, noto'g'ri ma'lumot kiritish va moliyaviy manipulyatsiya. Bloklash avvaldan ogohlantirmasdan amalga oshirilishi mumkin."
    ]),
    TermsSection("39. Arxivlangan safarlar", [
      "Bekor qilingan safarlar platforma ma'lumotlar bazasida audit va tarix maqsadida alohida saqlanadi. Foydalanuvchi ushbu ma'lumotlarga o'z dashboard orqali kirish imkoniyatiga ega."
    ]),
    TermsSection("40. Tranzaksiyalar", [
      "Platformadagi har bir moliyaviy amal (yechish va qo'shish) qayd etiladi.",
      "Haydovchi platformada ro'yxatdan o'tish orqali ushbu tranzaksiya tizimiga rozilik bildiradi."
    ]),
    TermsSection("41. Platforma huquqlari", [
      "Ketamiz.com quyidagi huquqlarga ega: safarni majburiy bekor qilish, balansni muzlatish va komissiya stavkasini o'zgartirish.",
      "Ushbu huquqlar platformaning yaxlitligi va foydalanuvchilar manfaatini himoya qilish uchun qo'llaniladi."
    ]),
    TermsSection("42. Ro'yxatdan o'tish va SMS tasdiqlash", [
      "Foydalanuvchi haqiqiy telefon raqami orqali ro'yxatdan o'tishi va SMS orqali tasdiqdan o'tishi shart.",
      "Tasdiqlanmagan hisob booking yoki safar yarata olmaydi."
    ]),
    TermsSection("43. Telefon raqamidan foydalanish", [
      "Foydalanuvchi raqami quyidagi maqsadlarda ishlatilishi mumkin: SMS tasdiqlash, booking xabarlari, safar o'zgarishlari va haydovchi hamda yo'lovchi o'rtasidagi aloqa."
    ]),
    TermsSection("44. Haydovchi va mijoz o'rtasidagi aloqa", [
      "Booking tasdiqlangandan so'ng platforma safarni tashkil qilishni osonlashtirish maqsadida haydovchi va mijozning telefon raqamlarini bir-biriga taqdim etishi mumkin."
    ]),
    TermsSection("45. SMS orqali bildirishnomalar", [
      "Platforma quyidagi holatlarda SMS yuborishi mumkin:",
      "Yangi booking, booking bekor qilinishi, yo'lovchi qo'shilishi yoki olib tashlanishi, safar bekor qilinishi, to'lov va balans o'zgarishlari."
    ]),
    TermsSection("46. Maxfiylik", [
      "Telefon raqamlar faqat safar ishtirokchilari o'rtasida ulashiladi.",
      "Ma'lumotlar uchinchi shaxslarga qonuniy talab bo'lmasa berilmaydi."
    ]),
    TermsSection("47. Foydalanuvchi majburiyatlari", [
      "Foydalanuvchi boshqa foydalanuvchilarning shaxsiy ma'lumotlarini spam yuborish, marketing yoki uchinchi shaxslarga berish uchun ishlatmasligi shart.",
      "Ushbu qoidani buzish hisobning darhol bloklanishiga olib keladi."
    ]),
    TermsSection("48. Platforma javobgarligi — aloqa bo'yicha", [
      "Ketamiz.com foydalanuvchilar o'rtasidagi to'g'ridan-to'g'ri muloqot yoki platformadan tashqaridagi kelishuvlar uchun javobgar emas. Platforma faqat aloqa o'rnatish vositasini taqdim etadi."
    ]),
    TermsSection("49. Noto'g'ri foydalanish va jazo choralari", [
      "Taqiqlanadi: SMS spam, soxta telefon raqamlar va boshqa foydalanuvchilarni bezovta qilish.",
      "Natijada: hisob bloklanadi va huquqiy choralar ko'rilishi mumkin."
    ]),
  ],
);
