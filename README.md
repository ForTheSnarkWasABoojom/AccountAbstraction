# Account Abstraction Contracts
Этот репозиторий содержит смарт-контракты, реализующие Account Abstraction (абстракцию аккаунтов) в Ethereum-совместимых блокчейнах.

## Схема работы
Предполагается, что пользователи делятся на две категории - рядовые работники и управляющие. <br>
Рядовые работники имеют доступ к методам контракта Facade. <br>
Facade предоставляет возможность вызова методов ReinvestmentManager, часть методов доступна для прямого вызова сотрудниками. <br>

Другая часть предполагается излишне уязвимыми для прямого использования рядовыми работниками. <br>
Поэтому рядовыми работниками "уязвимые" методы используются следующим образом: <br>
* Создается запрос на операцию, он передается в Bundler. 
* В памяти Bundler накапливаются запросы на операции
* По преодолению порога отправки набор запросов передается в EntryPoint.
* После подписания запроса операция выполняется

В EntryPoint доступ имеют только управляющие, определяемые наличием их адреса в списке доверенных подписантов контракта. <br>
Управляющие могут подписывать операции, подтверждая тем самым их валидность. <br>
По преодолению порога количества необходимых подписей операция передается для выполнения ReinvestmentManager.
