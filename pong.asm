; masm 16-bit assembly pong

.model small
.stack 100h
.data                          ; segmento de dados
      bola_x       dw 0ah      ; coordenada x da bola
      bola_y       dw 0ah      ; coordenada y da bola
      tamanho_bola db 04h      ; tamanho da bola
.code

      ; procedimento para desenhar a bola na tela
desenhar_bola proc
                         mov  cx, bola_x              ; define a coordenada x inicial da bola
                         mov  dx, bola_y              ; define a coordenada y inicial da bola

      ; loop para desenhar cada um dos pixels da bola horizontalmente
      ; subtraindo a coordenada x inicial da bola da coordenada x atual
      ; e comparando com o tamanho da bola, incrementando a coluna e
      ; desenhando outro pixel até o tamanho da bola ser atingido
      ; depois, reinicia a coordenada x e incrementa a coordenada y
      ; e repete o processo até o tamanho da bola ser atingido
      desenhar_bola_loop:
                         mov  ah, 0ch                 ; define a cor do pixel
                         mov  al, 0fh                 ; como branco (0fh)
                         int  10h                     ; executa a função

                         inc  cx                      ; incrementa a coordenada x
                         mov  ax, cx                  ; move a coordenada x para ax
                         sub  ax, bola_x              ; subtrai a coordenada x inicial da bola

                         cmp  al, tamanho_bola        ; compara com o tamanho da bola
                         jng  desenhar_bola_loop      ; se for menor ou igual, desenha outro pixel

                         mov  cx, bola_x              ; se não, reinicia a coordenada x
                         inc  dx                      ; incrementa a coordenada y
                         mov  ax, dx                  ; move a coordenada y para ax
                         sub  ax, bola_y              ; subtrai a coordenada y inicial da bola

                         cmp  al, tamanho_bola        ; compara com o tamanho da bola
                         jng  desenhar_bola_loop      ; se for menor ou igual, desenha outro pixel

                         ret
desenhar_bola endp

      start:             
                         mov  ax, @data               ; inicializa e define o segmento de dados
                         mov  ds, ax

                         mov  ah, 00h                 ; define o modo de vídeo
                         mov  al, 13h                 ; 320x200 256 cores
                         int  10h                     ; executa a função

                         call desenhar_bola           ; desenha a bola na tela

  end start
