/// Ошибка, возникшая в фоновой операции без вызывающего кода: обработчике потока,
/// «выстрелил и забыл». Репозиторий отдаёт её наружу в потоке, а блок передаёт в
/// `addError`, чтобы её увидел `BlocObserver`.
typedef BackgroundError = ({Object error, StackTrace stackTrace});
