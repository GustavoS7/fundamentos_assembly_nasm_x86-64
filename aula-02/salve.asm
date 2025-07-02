section .data

msg: db "Salve, simpatia", 10 ; 'msg' - rótulo dos dados definidos
                              ; 'db' - os dados são definidos como
                              ;        uma cadeia de bytes

len: equ $ - msg              ; len - rótulo do tamanho da mensagem
                              ; equ - pseudo-instrução para definir constantes
                              ; $ - endereço do último byte escrito na memória
                              ; msg - endereço do primeiro byte da mensagem

section .text

  global _start ; A diretiva 'global' torna o rótulo '_start'
                ; visível

_start:
  