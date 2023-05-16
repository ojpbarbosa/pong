; masm 16-bit assembly pong

.model small
.stack 100h
.data     ; segmento de dados
.code
main proc
  ; inicializa e define o segmento de dados
       mov ax, @data
       mov ds, ax

  fim:
       mov ax, 4c00h  ; termina o programa com código 0
       int 21h        ; executa o término do programa
main endp
end main
