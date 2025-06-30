# Estudo 1: programa 'salve, simpatia!'

## Objetivos

- Apresentar os conceitos mais fundamentais da programação em assembly.
- Exemplificar a estrutura elementar de um código em assembly.
- Apresentar o conceito de *chamadas de sistema*.
- Ilustrar os atributos básicos dos tipos de dados.
- Demonstrar os procedimentos de montagem (`nasm`) e linkedição (`ld`).

## Requisitos

- Qualquer sistema GNU/Linux x86_64
- Assemblador: `nasm` (`apt install nasm`)
- Linkeditor: `ld` (`apt install binutils`)
- Um editor de textos puros (nano, vim, etc...)

## Criando o código-fonte

O arquivo do código em assembly não tem uma extensão predeterminada (não existe o conceito de "extensões" no GNU/Linux), mas costuma-se utilizar:

```
arquivo.asm
```

### O programa 'salve.asm'

Para este primeiro contato com a linguagem assembly, vamos criar um programa que imprime no terminal a frase *Salve, simpatia!*.

#### Preparando um diretório de estudos

```
:~$ mkdir asm
:~$ cd asm
:~/asm$ mkdir 01
:~/asm$ cd 01
:~/asm/01$ 
```

#### Criando o arquivo

```
:~/asm/01$ nano salve.asm
```

## Seções do código

Os programas em assembly podem ter três seções:

- `section .data`: definição de dados inicializados.
- `section .bss`: definição de dados não inicializados.
- `section .text`: o código do programa.

Notas:

- O nome `.bss` vem de *block started by symbol*.
- A ordem das seções é indiferente.
- Neste primeiro exemplo, nós utilizaremos apenas as seções `.data` e `.text`.

## Layout de uma linha de código

Cada linha de código do NASM (a menos que seja uma macro, uma diretiva de pré-processamento ou uma diretiva de compilação) é composta pela combinação de quatro campos:

```
+---------+-----------+-----------+--------------+
| rótulo: | instrução | operandos | ; comentário |
+---------+-----------+-----------+--------------+
```

A presença ou ausência de qualquer um desses campos pode variar ou até ser opcional, mas este é o layout geral.

## A seção '.text'

A execução de programas em assembly é feita de cima para baixo e deve sempre conter um rótulo (*label*) para indicar o ponto de início do programa: seu *ponto de entrada*, o que nós definimos desta forma na seção `.text`:

```asm
section .data


section .text

    global _start  ; A diretiva 'global' torna o rótulo '_start'
                   ; visível de qualquer parte do programa.

_start:            ; Aqui está o início do programa.
```

> Em algumas situações (especialmente quando trabalhamos em conjunto com a linguagem C), o ponto de entrada poderá ser indicado com o rótulo `_main`, mas `_start` é o rótulo buscado, por padrão, pelo linkeditor `ld` no GNU/Linux.

### Rótulos

Os rótulos (*labels*) são identificadores de endereços e servem para que possamos fazer saltos (*jumps*) para diferentes partes do programa ou localizar dados na memória. Nós podemos criá-los livremente, mas o rótulo `_start:` normalmente é utilizado para definir o *ponto de entrada* do programa.

### A diretiva 'global'

A diretiva `global` é utilizada para exportar símbolos do código para o objeto gerado na compilação. Marcando o rótulo `_start:` como global, ele será adicionado ao código do objeto gerado e o linkeditor (`ld`) irá utilizá-lo para definir o ponto de entrada do programa executável como um todo, mesmo que ele seja composto por vários arquivos-fonte.

## A seção '.data'

Na seção `.data` nós definimos os identificadores de *dados inicializados*, algo análogo às variáveis e constantes inicializadas de linguagens de alto nível. É "algo análogo" porque, em linguagens de baixo nível, o conceito de "variáveis" é uma mera analogia com o que temos em linguagens de alto nível: na prática, esses identificadores de dados são rótulos (*labels*) e apenas nomeiam endereços na memória.

### Definindo uma mensagem

```asm
section .data

    msg db "Salve, simpatia!",10  ; 'msg' - rótulo dos dados definidos
                                  ; 'db'  - os dados são definidos como
                                  ;         uma cadeia de bytes.

section .text

    global _start  ; A diretiva 'global' torna o rótulo '_start'
                   ; visível de qualquer parte do código.

_start:            ; Aqui está o início do programa.
```

### O rótulo 'msg'

Os identificadores não representam os dados, mas o endereço na memória onde o dado será registrado. Portanto, o rótulo `msg` pode ser entendido como um *ponteiro*, através do qual, nós podemos recuperar os dados no endereço de memória apontado. Para isso, além da localização do dado na memória, nós precisamos saber o espaço ocupado (em bytes) pelo dado definido.

### A mensagem

No código, a nossa mensagem ocupa 17 bytes na memória:

```
    |←     16     →|  1 
   "Salve, simpatia!",10
```

As cadeias de caracteres podem ser definidas entre aspas (simples ou duplas, tanto faz) e, separados por vírgulas, nós podemos utilizar as representações numéricas de caracteres individuais, como a quebra de linha (decimal 10, na tabela ASCII).

### Caracteres multibyte

Alguns caracteres da língua portuguesa, como os caracteres acentuaos e o cê com cedilha, ocupam dois bytes de comprimento, o que dificulta a realização de uma contagem precisa. Por exemplo, a string `Olá, mundo!` não tem 11 bytes de comprimento, e sim 12.

### A pseudo-instrução 'db'

A pseudo-instrução `db` (*define bytes*) é utilizada para definir que os dados devem ser interpretados como uma cadeia de bytes. Contudo, nós ainda podemos definir dados como cadeias de palavras (`dw`), cadeias de palavras duplas (`dd`) ou cadeias de palavras quádruplas (`dq`), onde, em processadores x86_64, as palvras terão, 2, 4 ou 8 bytes de comprimento, respectivamente.

Isso afeta diretamente o espaço ocupado pelos dados na memória:

| Diretiva | Caracteres | Caracteres em hexa na memória             | Tamanho                        |
|----------|------------|-------------------------------------------|--------------------------------|
| `db`     | `'ABCDE'`  | `0x41 0x42 0x43 0x44 0x45`                | 5 bytes                        |
| `dw`     | `'ABCDE'`  | `0x41 0x42 0x43 0x44 0x45 0x00`           | 6 bytes, 3 palavras de 2 bytes |
| `dd`     | `'ABCDE'`  | `0x41 0x42 0x43 0x44 0x45 0x00 0x00 0x00` | 8 bytes, 2 palavras de 4 bytes |
| `dq`     | `'ABCDE'`  | `0x41 0x42 0x43 0x44 0x45 0x00 0x00 0x00` | 8 bytes, 1 palavra de 8 bytes  |

Existem outros múltiplos de palavras após `dq`: 

- `dt`: palavras de 10 bytes (*ten-word*: 80 bits).
- `do`: palavras de 16 bytes (*octo-word*: 128 bits).
- `dy`: palavras de 32 bytes (256 bits).
- `dz`: palavras de 64 bytes (512 bits).

> Nenhum deles permite a passagem de constantes numéricas inteiras como valor.

### O tamanho da mensagem

No NASM, todos os dados iniciados com as pseudo-instruções `dX` (onde `X` pode ser `b`, `w`, `d`, `q`...) são armazenados sequencialmente na memória: ou seja, o início de uma cadeia de bytes será registrada logo após o último byte da cadeia anterior. Portanto, cada cadeia de bytes estabelece um novo ponto inicial para o dado iniciado seguinte (seu *offset*). Deste modo, pelo seu rótulo, é possível determinar o ponto inicial de cada cadeia de bytes, enquanto o seu final será sempre o último byte escrito na memória.

Tendo isso em mente, uma forma de obter o tamanho da nossa mensagem é recorrendo a uma subtração utilizando o token `$`, que representa o último endereço ocupado com dados na memória:

```asm
section .data

    msg db "Salve, simpatia!",10  ; 'msg' - rótulo dos dados definidos.
                                  ; 'db'  - os dados são definidos como
                                  ;         uma cadeia de bytes.

    len equ $ - msg               ; len - rótulo do tamanho da mensagem.
                                  ; equ - pseudo-instrução para definir constantes.
                                  ; $   - Último endereço ocupado na memória.
                                  ; msg - Rótulo do endereço inicial da mensagem.

section .text

    global _start  ; A diretiva 'global' torna o rótulo '_start'
                   ; visível de qualquer parte do programa.

_start:            ; Aqui está o início do programa.
```

> **Importante!** Se outras strings fossem definidas com `db`, o tamanho de cada uma deveria ser calculado logo após a sua definição!

### A pseudo-instrução 'equ'

Diferente de `db`, que define dados que podem ser alterados até o limite de seu comprimento, os dados definidos pela pseudo-instrução `equ` (*equal*) são pré-processados na compilação e, por isso, tornados constantes: ou seja, não poderão ser alterados na execução do programa.

## O código do programa

Um programa em assembly consiste, fundamentalmente, da manipulação de dados na memória do sistema e nos registradores da CPU através de *instruções*.

### Registradores

Registradores são memórias para uso exclusivo do processador (hardware). Na arquitetura x86-64, os registradores podem ter a capacidade de armazenar até 64 bits de dados (8 bytes). No caso dos registradores de uso geral, nós podemos acessar e registrar dados em suas subdivisões de 32, 16 e 8 bits. 

Por exemplo, as subdivisões do registrador `rax` podem ser acessadas utilizando os nomes `eax`, `ax`, `ah` e `al`:

```
64                                  32                16        8        0
 ↓                                   ↓                 ↓        ↓        ↓
 +-----------------------------------------------------------------------+
 |                                  rax                                  |
 |-----------------------------------+-----------------------------------|
 |                                   |                eax                |
 |-----------------------------------+-----------------+-----------------|
 |                                                     |       ax        |
 |-----------------------------------------------------+--------+--------|
 |                                                     |   ah   |   al   |
 +-----------------------------------------------------+--------+--------+
```

Este padrão de nomes se repete para os registradores `rbx`, `rcx` e `rdx` (trocando `a` por `b`, `c` ou `d`), mas outros registradores de 64 bits também possuem identificaores para suas porções de 32, 16 e 8 bits. Entre outros usos, essa característica possibilita a escrita de código compatível com arquiteturas de 32 e 16 bits.

### Instruções

As instruções são *mnemônicos* que facilitam a chamada dos códigos de instruções da CPU (*opcodes*) -- sem elas, nós teríamos que escrever os números binários (código de máquina) específicos para comandar cada ação da CPU. Elas são utilizadas para indicar operações com dados em registradores e na memória -- como cópias, operações lógicas e aritméticas --, dar saltos no código, manipular pilhas e executar chamadas de sistema.

Para cada instrução, há três possibilidades de operandos, chamados de *modos de direcionamento* (*adderessing modes*):

**Registradores:**

- Registradores de propósito geral (`rax`, `rbx`, `rcx`, `rdx`...)
- Registradores de índice (`rdi`, `rsi`, `rsp`, `rbp`)
- Registradores de inteiros (`r8` a `r15`)

**Memória:**

- Endereço efetivo (um valor que corresponde a um endereço)
- Rótulo (um identificador para um endereço)
- Derreferência (uma indicação do endereço de destino)

**Valores imediatos:**

- Inteiros em base 2, 8, 10 ou 16
- Caracteres (também são inteiros)
- Strings (sequências de inteiros)
- Números de ponto flutuante

No nosso primeiro programa, nós utilizamos apenas as instruções: 

- `mov`, que copia dados entre registradores ou entre registradores e endereços de memória.
- `syscall`, para executar a chamada de sistema definida pelas atribuições feitas a certos registradores predeterminados pelas *convenções de chamada de sistema*.

As chamadas de sistema serão necessárias porque queremos fazer duas coisas: escrever a mensagem no terminal e terminar o programa, e ambos os procedimentos envolvem o sistema operacional.

### Chamadas de sistema

No GNU/Linux, nenhum programa tem acesso direto aos recursos do hardware: tudo é intermediado e controlado pelo kernel (o Linux). Sempre que for preciso manipular arquivos, escrever ou ler dados por um dispositivo de entrada e saída, alocar espaços em memória, iniciar e terminar processos, entre tantas outras ações envolvendo o hardware, isso terá que ser feito através de alguma função interna que o kernel disponibiliza em sua interface de programação através da biblioteca `glibc`: são as *chamadas de sistema* (*system calls* ou apenas *syscalls*).

Com a linguagem assembly, as chamadas de sistema são feitas informando o identificador numérico da função e seus argumentos através de registradores específicos, por exemplo...

| rax  | syscall     | rdi                    | rsi               | rdx            | r10 | r8 | r9 |
|------|-------------|------------------------|-------------------|----------------|-----|----|----|
| `0`  | `sys_read`  | `int FD`               | `char *buf`       | `size_t count` |     |    |    |
| `1`  | `sys_write` | `int FD`               | `const char *buf` | `size_t count` |     |    |    |
| `2`  | `sys_open`  | `const char *filename` | `int flags`       | `int mode`     |     |    |    |
| `3`  | `sys_close` | `int FD`               |                   |                |     |    |    |
| ...  | ...         | ...                    | ...               | ...            |     |    |    |
| `60` | `sys_exit`  | `int ret`              |                   |                |     |    |    |

Quando estamos falando de *syscalls*, a ordem de atribuição de dados aos registradores não importa: assim que a instrução `syscall` for executada, os dados que forem encontrados nesses registradores serão utilizados. Contudo, como veremos no futuro, quando trabalhamos em conjunto com a linguagem C/C++, existem convenções específicas para a ordem de passagem de argumentos (ABI - *application binary interface*), a fim de garantir uma correspondência direta entre os parâmetros definidos na assinatura de uma função em C/C++ e sua contraparte em assembly.

## Escrevendo caracteres no terminal

Para imprimir caracteres no terminal, nós teremos que utilizar a mesma chamada de sistema utilizada para escrever em arquivos: porque, em sistemas operacionais parecidos com o UNIX, como o GNU/Linux, tudo tem uma representação na forma de arquivo, inclusive o hardware. Sendo assim, o display do terminal tem uma representação na forma do arquivo `/dev/stdout`, que está disponível para escrita através de um outro arquivo, chamado de *descritor de arquivos* (FD).

Os descritores de arquivos são ligações simbólicas que o kernel disponibiliza para os processos manipularem arquivos (também chamados de *file handlers* em outros contextos), mas todo processo é iniciado com acesso a três descritores de arquivo por padrão:

| FD  | Dispositivo   | Descrição                                   |
|-----|---------------|---------------------------------------------|
| `0` | `/dev/stdin`  | Entrada padrão (teclado)                    |
| `1` | `/dev/stdout` | Saída padrão (display do terminal)          |
| `2` | `/dev/stderr` | Saída padrão de erros (display do terminal) |

Para escrevermos a nossa mensagem no terminal, portanto, nós utilizaremos a chamada de sistema `sys_write` (`rax = 1`) informando o descritor de arquivos `1` como argumento (`rdi = 1`). Também precisaremos informar a localização da cadeia de caracteres que foi registrada na memória, que, no exemplo, e tem seu endereço inicial identificado pelo rótulo `msg` (`rsi = msg`). Finalmente, também teremos que informar o tamanho da cadeia de caracteres em bytes (`rdx = len`).

No código, fica assim:

```asm
    mov rax, 1     ; Chamada de sistema 'sys_write'.
    mov rdi, 1     ; Descritor de arquivos 1 (stdout).
    mov rsi, msg   ; Ponteiro para a string na memória.
    mov rdx, len   ; Constante com o tamanho da string.
    syscall        ; Invoca a chamda de sistema com os
                   ; dados nos registradores.
```

## Terminando o programa

Para terminar o programa corretamente, é preciso invocar a chamada de systema `sys_exit`, que recebe apenas dois argumentos: o identificador da chamada (`rax = 60`) e um inteiro entre `0` e `255` (em `rdi`) indicando o estado de termino do programa.

```asm
    mov rax, 60    ; Chamada de sistema 'sys_exit'
    mov rdi, 0     ; Retorno 0 (sucesso)
    syscall
```

O shell do sistema utilizará o valor retornado ao término do programa para eventuais comandos condicionais, mas convenciona-se dizer que o programa terminou com *sucesso* se o seu retorno for `0`. Qualquer valor diferente de `0` será interpretado pelo shell como *erro*, mas isso não significa necessariamente que algo deu errado: o programador pode ter simplesmente escolhido produzir estados de término com outros valores, por exemplo, para notificar eventos para comandos encadeados na linha de comandos.

Sendo assim, este é o nosso código final:

```asm
section .data

    msg db "Salve, simpatia!",10  ; 'msg' - rótulo dos dados definidos.
                                  ; 'db'  - os dados são definidos como
                                  ;         uma cadeia de bytes.

    len equ $ - msg               ; len - rótulo do tamanho da mensagem.
                                  ; equ - pseudo-instrução para definir constantes.
                                  ; $   - Último endereço ocupado na memória.
                                  ; msg - Rótulo do endereço inicial da mensagem.

section .text

    global _start  ; A diretiva 'global' torna o rótulo '_start'
                   ; visível de qualquer parte do programa.

_start:            ; Aqui está o início do programa.

    mov rax, 1     ; Chamada de sistema 'sys_write'.
    mov rdi, 1     ; Descritor de arquivos 1 (stdout).
    mov rsi, msg   ; Ponteiro para a string na memória.
    mov rdx, len   ; Constante com o tamanho da string.
    syscall        ; Invoca a chamda de sistema com os
                   ; dados nos registradores.

    mov rax, 60    ; Chamada de sistema 'sys_exit'
    mov rdi, 0     ; Retorno 0 (sucesso)
    syscall
```

## "Compliando" o programa

A rigor, a função do NASM não é exatamente "compilar" o programa, mas produzir um arquivo binário contendo o equivalente do nosso código na linguagem da máquina -- processo que nós chamamos de *montagem*. É por isso que dizemos que o programa NASM é um *assemblador* (ou *montador*).

> Portanto, "assembly" é uma "linguagem de montagem", ao passo que "assembler" é o termo utilizado para fazer referência ao programa que monta o binário em código de máquina.

Para montar nosso programa com o NASM:

```
:~/asm/01$ nasm -f elf64 salve.asm -o salve.o
:~/asm/01$
```

Onde:

- `-f elf64`: formato de saída para Linux 64 bits (ELF64).
- `-o salve.o`: arquivo objeto de saída.

Se não houver mensagens, significa que tudo foi montado corretamente; caso contrário, as mensagens indicariam as linhas em que algo teria dado errado. Para visualizar o que foi gerado...

```
:~/asm/01$ ls
salve.asm  salve.o
```

O arquivo objeto ainda não é o binário executável do nosso programa. Antes, ele ainda precisa receber os códigos binários para fazer as ligações necessárias com as bibliotecas específicas do sistema operacional, o que será feito, no nosso caso, com o *linkeditor* `ld`.

```
:~/asm/01$ ld -m elf_x86_64 -s salve.o -o salve
:~/asm/01$
```

Onde:

- `-m elf_x86_64`: formato do binário.
- `-s`: omite a informação dos símbolos na saída (*strip*).
- `-o salve`: nome do arquivo binário executável gerado.

Novamente, se não houver mensagens, o nosso programa foi linkeditado corretamente. O resultado deste último comando é a criação do binário executável do nosso programa:

```
:~/asm/01$ ls
salve  salve.asm  salve.o
```

A partir de agora, nós podemos executá-lo indicando seu caminho (`./`, diretório corrente) na linha do comando:

```
:~/asm/01$ ./salve
Salve, simpatia!
```

Aí está! Nosso primeiro programas em assembly NASM 64 bits foi criado com sucesso!
