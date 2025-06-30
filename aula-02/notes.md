## Seções e segmentos do código

- Seções são uma forma de organizar os dados escritos no arquivo binário *durante a ligação*

- Os segmentos, suas contrapartes, descrevem dados conforme seão vistos *durante a execução* pelo sistema operacional

- Podemos criar quantas seções quisermos, na ordem que quisermos e com os nomes que quisermos.

As *seções padrão* são aquelas que terão seus atributos configurados pelo _assemblador_

Uma seção no arquivo objeto nada mais é que uma maneira de agrupar dados no arquivo. É como criar um grupo novo e dar um sentido para ele. Três exemplos principais de seções são:

- A seção de código, onde o código que é executado pelo processador fica.

- Seção de dados, onde variáveis são alocadas.

- Seção de dados não inicializada, onde a memória será alocada dinamicamente ao carregar o executável na memória. Geralmente usada para variáveis não inicializadas, isto é, variáveis que não têm um valor inicial definido.

### 1.1 Arquivo binário elf

![alt text](./images/image1.png)

Existem quatro seções principais que podemos usar no nosso código e o linker irá resolvê-las corretamente sem que nós precisamos dizer a ele como fazer seu trabalho. O NASM também reconhece essas seções como "padrão" e já configura os atributos delas corretamente.

- .text -- Usada para armazenar o código executável do nosso programa.

- .data -- Usada para armazenar dados inicializados do programa, por exemplo uma variável global.

- .bss -- Usada para reservar espaço para dados não-inicializados, por exemplo uma variável global que foi declarada mas não teve um valor inicial definido.

- .rodata ou .rdata -- Usada para armazenar dados que sejam somente leitura (readonly), por exemplo uma constante que não deve ter seu valor alterado em tempo de execução.

