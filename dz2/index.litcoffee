#Реализация алгоритма Форда-Фалкерсона

Функция для транспонирования матрицы.
Создаем матрицу `A` такого же размера, что и G, а потом наполняем ее значениями:


    transposition = (G) ->
      A = ((null for el in row) for row in G)
      for row, i in G
        for el, j in row
          A[j][i] = el

      return A

Функция для приведения матрицы в нормальный вид, т.е. чтобы можно было считать
ее производную для определения наличия пути из i в j. Считаем, что из вершины
можно достичь эту же самую вершину.

    normalizeMatrix = (A) ->
      B = (((if Number.isFinite(el) and el isnt 0 then 1 else 0) for el, j in row) for row, i in A)
      for i in [0...A.length]
        B[i][i] = 1

      return B

Функция для скалярного умножения двух строк:

    multiply = (s1, s2) ->
      sum = false
      for el, i in s1
        sum = sum || !!s1[i]*s2[i]

      return sum

Сначала напишем функцию, которая будет проверять достижимость из s в t:

    derivative = (G) ->
      A = normalizeMatrix(G)

      len = A.length
      while len--
        At = transposition(A)
        for s1, i in A
          for s2, j in At
            A[i][j] = multiply(s1, s2)

      return A

Функция, возвращающая какой-то путь в графе. Используется поиск в ширину.

    getPath = (G, i, j) ->
        colors = []
        stack = [i]
        path = []

        while stack.length isnt 0
          v = stack.pop()
          path.push(v)
          colors[v] = true

          #путь найден
          if v is j
            #Просматриваем все элементы с конца, пока не найдем стартовую вершину
            path.reverse()
            p = []
            for node in path
              p.push(node)
              #нашли. Теперь возвращаем путь p.
              if node is i
                p.reverse()
                return p

          for el, index in G[v] when not colors[index]?
            if Number.isFinite(el) and el isnt 0
              stack.push(index)

        #если ничего не нашли.
        return false

Непосредственно алгоритм Форда-Фалкерсона:
Первый аргумент - граф, второй и третий - начальная и конечная вершина

    ff = (G, s, t) ->

      #Генерируем массив размерности той же, что и G, заполненный нулями.
      #В нем будут храниться потоки.

      f = ((0 for el in row) for row in G)

      #Копируем G в Gf. Gf - остаточная сеть.

      C = (((if Number.isFinite(el) then el else 0) for el in row) for row in G)
      Gf = ((el for el in row) for row in C)

      #Ищем n-ую производную остаточной сети и смотрим, существует ли путь из s в t

      #берем какой-то путь из остаточной сети, если он есть
      while p = getPath(Gf, s, t)
        #восстанавливаем ребра, по которым проходил путь p.
        edges = []
        for i in [1...p.length]
          source = p[i - 1]
          target = p[i]
          #массив ребер. У каждого элемента массива три свойства: source ребра,
          #target ребра и текущий вес ребра в остаточной сети
          edges.push source: source, target: target, weight: Gf[source][target]

        #берем ребро в пути p с наименьшим весом
        edges.sort (a, b) -> a.weight - b.weight
        cfp = edges[0].weight

        #изменяем потоки в пути p на только что извлеченную величину
        for edge in edges
          f[edge.source][edge.target] += cfp
          f[edge.target][edge.source] -= cfp

        #считаем новую остаточную сеть
        for row, i in Gf
          for el, j in row
            Gf[i][j] = C[i][j] - f[i][j]

      # после цикла while возвращаем матрицу, которая описывает потоки на графе.
      return f



Граф (вариант 001):

    inf = Number.POSITIVE_INFINITY
    G = [
      [  0,   3,   3, inf, inf, inf],
      [inf,   0, inf,   2,   1, inf],
      [inf, inf,   0, inf,   3, inf],
      [inf, inf, inf,   0, inf,   3],
      [inf, inf, inf, inf,   0,   4],
      [inf, inf, inf, inf, inf,   0]
    ]

Простые тесты работоспособности:

    #console.log(derivative(G))
    #console.log(getPath(G, 0, 5))
    console.log("Real result: ")
    console.log(ff(G, 0, 5))


Ожидаемый вывод совпадает с настоящим:

    expected = [
      [  0,  3,  3,  0,  0,  0 ],
      [ -3,  0,  0,  2,  1,  0 ],
      [ -3,  0,  0,  0,  3,  0 ],
      [  0, -2,  0,  0,  0,  2 ],
      [  0, -1, -3,  0,  0,  4 ],
      [  0,  0,  0, -2, -4,  0 ]
    ]
    console.log("\nExpected result:")
    console.log expected


###Real result:
[ [ 0, 3, 3, 0, 0, 0 ],
  [ -3, 0, 0, 2, 1, 0 ],
  [ -3, 0, 0, 0, 3, 0 ],
  [ 0, -2, 0, 0, 0, 2 ],
  [ 0, -1, -3, 0, 0, 4 ],
  [ 0, 0, 0, -2, -4, 0 ] ]

###Expected result:
[ [ 0, 3, 3, 0, 0, 0 ],
  [ -3, 0, 0, 2, 1, 0 ],
  [ -3, 0, 0, 0, 3, 0 ],
  [ 0, -2, 0, 0, 0, 2 ],
  [ 0, -1, -3, 0, 0, 4 ],
  [ 0, 0, 0, -2, -4, 0 ] ]
