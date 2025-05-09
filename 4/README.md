1. Сначала нужно преобразовать ячейки в координаты:
Каждой ячейке присваиваются координаты (x, y), где:
x — номер ряда (0, 1, 2) с шагом 1 м между рядами.
y — позиция стеллажа в ряду (начиная с 1м к северу от стола, далее на юг). Для стеллажа i в ряду:
y = 1 - (i - 1).
2. Далее, нужно сгруппировать ячейки по рядам:
Ячейки группируются по их x-координате. Для каждого ряда определяются:
Минимальный (y_min) и максимальный (y_max) y среди всех ячеек.
Если ряд пуст, он исключается из маршрута.
3. Оптимизация порядка посещения рядов:
Ряды посещаются в порядке 0 -> 1 -> 2 (от ближайшего к стола к дальнему). Это минимизирует переходы между рядами
4. Определение направления движения внутри ряда:
В каждом ряду кладовщик движется от северной границы (y_max) к южной (y_min). Это позволяет собрать все ячейки за один проход без возвратов.
5. Построение маршрута:
Начало: стол (0, 0).
Переход к северной точке первого ряда (0, y_max).
Движение на юг до y_min.
Переход на 1 м восток к следующему ряду, повторение шагов.
Завершение маршрута после посещения последней ячейки.

6. Решение оптимальное, так как:
- Минимизирует переходы между рядами:
Последовательность 0 -> 1 -> 2 сокращает общее расстояние перемещения по оси X до 2 м (1 м между каждыми соседними рядами).
- Полностью покрывает ряды:
Движение от y_max к y_min в каждом ряду гарантирует, что все ячейки будут посещены за один проход, исключая повторные заходы.
- Учитывает начальную точку:
Маршрут начинается от стола и сразу направляется к ближайшему ряду, что сокращает начальный холостой пробег.
- Алгоритм работает для любого случайного набора ячеек, так как использует жадную стратегию, ориентированную на геометрию склада.