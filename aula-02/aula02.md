# 1. Seções e segmentos do código <!--{{{1-->

- Seções são uma forma de organizar os dados escritos
  no arquivo binário *durante a ligação*.

- Os segmentos, suas contrapartes, descrevem dados conforme
  serão vistos *durante a execução* pelo sistema operacional.

- Podemos criar quantas seções quisermos, na ordem que
  quisermos e com os nomes que quisermos.

- As *seções padrão* são aquelas que terão seus atributos
  configurados pelo assemblador.

## 1.1 - Arquivo binário ELF <!--{{{1-->

```
Visão do linker                             Visão do sistema
                +-------------------------+ <---+ 
                |      Cabeçalho ELF      |     |
                +-------------------------+     |
     (opcional) |  Cabeçalho do Programa  | Descreve segmentos
          +---→ +-------------------------+     |
          |     |           ...           |     |
          |     +-------------------------+     +--- Segmento de código
          |     |          .text          |     |
          |     +-------------------------+     |
          |     |         .rodata         |     |
          |     +-------------------------+     |
        Seções  |           ...           | ←---+
          |     +-------------------------+     |
          |     |          .data          |     |
          |     +-------------------------+     +--- Segmento de dados
          |     |          .bss           |     |
          |     +-------------------------+ ←---+
          |     |           ...           | Outros segmentos
          +---→ +-------------------------+
Descreve seções |   Cabeçalho de Seções   | (opcional)
                +-------------------------+
```

## 1.2 - Layout de memória <!--{{{1-->

```
Hi +------------+
   |    Stack   |
   +------------+
   |      ↓     |
   |            |
   |      ↑     |
   +------------+
   |            |
   |    Heap    |
   |            |
   +------------+ ←-+
   |   .bss     |   |
   +------------+   |
   |   .data    |   +-- Vem do binário
   +------------+   |
   |   .text    |   |
Lo +------------+ ←-+
```

## 1.3 - Descrição das seções/segmentos <!--{{{1-->

### Dados não inicializados (*block starting symbol*)

Análogo à definição de variáveis não inicializadas
com seus tipos respectivos tipos.

```asm
section .bss
```

### Dados inicializados <!--{{{1-->

Análogo à inicialização de variáveis e definições
de constantes (pré-processadas).

```asm
section .data
```

### Dados inalteráveis (*read only*) <!--{{{1-->

Dados constantes, geralmente integrados ao segmento
`.text` do binário executável.

```asm
section .rodata
```

### Código do programa (*texto*) <!--{{{1-->

Contém todas as instruções do programa.

```asm
section .text
```

#### Nota

> *No fim das contas, não há diferença entre código e dados!*

## 2 - Seção .data no programa 'salve.asm' <!--{{{1-->

```asm
section .data

msg:	db  "Salve, simpatia!",10
len:    equ $ - msg  
```

### 2.1 - Rótulos <!--{{{1-->

- Identificam endereços dos dados no código.

- São convertidos em *símbolos* na ligação e organizados
  na seção a que pertencerem.

- Nas seções `.data` e `.bss`, endereçam dados estáticos.

- Na seção `.text`, endereçam instruções (linhas do código).

### 2.2 - Pseudoinstruções `db` e `equ` <!--{{{1-->

- Na verdade, são *diretivas*.

- A pseudoinstrução `db` é processada na montagem
  e resulta na definição do endereço de uma cadeia
  de bytes de tamanho fixo e conteúdo.

- A pseudoinstrução `equ` é processada na montagem
  e resulta em um *valor imediato* onde for utilizada
  no código.

## 3 - A seção .text no programa 'salve.asm' <!--{{{1-->

```asm
section .text

	global _start

_start:

	mov	rax, 1
	mov	rdi, 1
	mov	rsi, msg
	mov	rdx, len
	syscall

_end:

	mov	rax, 60
	mov	rdi, 0
	syscall
```

### 3.1 - Ponto de entrada do programa <!--{{{1-->

- Com a diretiva `global`, o NASM exporta o símbolo
  `_start` para arquivo objeto gerado.

- Por padrão, o `ld` procura pelo símbolo `_start`
  para marcar o ponto de entrada do programa.

- O ponto de entrada pode ser definido por outros
  rótulos, mas será preciso informar ao `ld`, pela
  opção `-e`, o símbolo que deverá ser utilizado.

### 3.2 - Chamadas de sistema <!--{{{1-->

- Métodos para acessar funcionalidades do kernel.

- Definidos na biblioteca C padrão `libc` (UNIX) ou
  `glibc` (GNU/Linux).

- As convenções de chamadas de sistema são especificadas
  pela *Interface de Abstração Binária* (ABI), que
  determina quais registradores deverão receber os
  argumentos de cada chamada de sistema.

- Na arquitetura x86-64, as chamadas de sistema são
  executadas com a instrução `syscall`.

- Na arquitetura x86, as chamadas de sistema são
  executadas com a instrução `int 0x80`.

### 3.3 - Chamada `sys_write` <!--{{{1-->

- Escreve uma cadeia de bytes em um descritor de arquivos.

- Descritores de arquivo padrão:

| FD  | Dispositivo   | Descrição                            |
|-----|---------------|--------------------------------------|
| `0` | `/dev/stdin`  | Entrada padrão (teclado do terminal) |
| `1` | `/dev/stdout` | Saída padrão (display do terminal)   |
| `2` | `/dev/stderr` | Saída padrão de erros (`=stdout`)    |

- Obtido um descritor de arquivos (com a chamada `sys_open`),
  podemos escrever em qualquer arquivo.

- Parâmetros da chamada `sys_write` (x86-64):

| Registrador | Valor     | Descrição                              |
|-------------|-----------|----------------------------------------|
| `rax`       | `imm 1`   | O identificador da chamada `sys_write` |
| `rdi`       | `imm FD`  | O número do descritor de arquivos      |
| `rsi`       | `mem`     | O endereço inicial da cadeia de bytes  |
| `rdx`       | `imm len` | A quantidade de bytes a ser escrita    |

### 3.4 - Chamada `sys_exit` <!--{{{1-->

- Termina a execução do programa e retorna um estado de término.

- Parâmetros da chamada `sys_exit` (x86-64):

| Registrador | Valor     | Descrição                              |
|-------------|-----------|----------------------------------------|
| `rax`       | `imm 60`  | O identificador da chamada `sys_exit`  |
| `rdi`       | `imm RET` | O estado de término do programa        |

### 3.5 - A instrução `mov` <!--{{{1-->

- Copia dados para registradores.

- Sintaxe:

```
mov <destino>, <origem>
```

- Os operandos podem ser:

| Destino | Origem                |
|---------|-----------------------|
| *reg*   | *reg*, *mem* ou *imm* |
| *mem*   | *imm* ou *reg*        |

### 3.6 - Registradores de uso geral <!--{{{1-->

| Registrador | Nome              | 32   | 16   | 8(HI) | 8(LO) |
|-------------|-------------------|------|------|-------|-------|
| RAX         | Acumulador        | EAX  | AX   | AH    | AL    |
| RBX         | Base              | EBX  | BX   | BH    | BL    |
| RCX         | Contador          | ECX  | CX   | CH    | CL    |
| RDX         | Dados             | EDX  | DX   | DH    | DL    |
| RSI         | Índice de origem  | ESI  | SI   |       | SIL   |
| RDI         | Índice de destino | EDI  | DI   |       | DIL   |
| RSP         | Ponteiro de pilha | ESP  | SP   |       | SPL   |
| RBP         | Base da pilha     | EBP  | BP   |       | BPL   |
| R8          |                   | R8D  | R8W  |       | R8B   |
| ...         |                   |      |      |       |       |
| R15         |                   | R15D | R15W |       | R15B  |

#### Correção!

> Na aula 1, eu disse que os bytes nos registradores são
> escritos na ordem *little endian*, mas não é bem assim:
> na verdade, esta ordem se aplica apenas aos bytes na
> memória e nos arquivos binários!

## Demonstrações <!--{{{1-->

Dado inicializado no label `msg`:

```
(gdb) x /24xb 0x402000
```

Início do código (byte 0x1000):

```
xxd -c12 -g1 -s 4096 -l 48 salve
```

Ponto de entrada:

```
(gdb) x /48xb 0x401000
```


