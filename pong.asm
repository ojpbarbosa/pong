; masm 16-bit assembly pong

.model small
.stack 100h
.data                               ; segmento de dados
      bola_x            dw 00h      ; coordenada x (coluna) da bola
      bola_y            dw 00h      ; coordenada y (linha) da bola
      tamanho_bola      db 04h      ; tamanho da bola (4x4 pixels)
      velocidade_bola_x dw 03h      ; velocidade da bola no eixo x (coluna) (3 pixels por frame)
      velocidade_bola_y dw 02h      ; velocidade da bola no eixo y (linha) (2 pixels por frame)

      ultimo_timestamp  db 00h      ; último timestamp registrado (usado para calcular o delta time)
.code

      ; procedimento para desenhar a bola na tela
desenhar_bola proc
                         mov  cx, bola_x                 ; define a coordenada x inicial da bola
                         mov  dx, bola_y                 ; define a coordenada y inicial da bola

      ; loop para desenhar cada um dos pixels da bola horizontalmente
      ; subtraindo a coordenada x inicial da bola da coordenada x atual
      ; e comparando com o tamanho da bola, incrementando a coluna e
      ; desenhando outro pixel até o tamanho da bola ser atingido
      ; depois, reinicia a coordenada x e incrementa a coordenada y
      ; e repete o processo até o tamanho da bola ser atingido
      desenhar_bola_loop:
                         mov  ah, 0ch                    ; função para desenhar um pixel
                         mov  al, 0fh                    ; define a cor do pixel como branca (0fh)
                         int  10h                        ; executa a função

                         inc  cx                         ; incrementa a coordenada x
                         mov  ax, cx                     ; move a coordenada x para ax
                         sub  ax, bola_x                 ; subtrai a coordenada x inicial da bola

                         cmp  al, tamanho_bola           ; compara com o tamanho da bola
                         jng  desenhar_bola_loop         ; se for menor ou igual, desenha outro pixel

                         mov  cx, bola_x                 ; se não, reinicia a coordenada x
                         inc  dx                         ; incrementa a coordenada y
                         mov  ax, dx                     ; move a coordenada y para ax
                         sub  ax, bola_y                 ; subtrai a coordenada y inicial da bola

                         cmp  al, tamanho_bola           ; compara com o tamanho da bola
                         jng  desenhar_bola_loop         ; se for menor ou igual, desenha outro pixel

                         ret
desenhar_bola endp

      ; procedimento para limpar a tela
limpar_tela proc
      ; redefine o modo de vídeo para 320x200 256 cores, limpando a tela
                         mov  ah, 00h                    ; define o modo de vídeo
                         mov  al, 13h                    ; 320x200 256 cores
                         int  10h                        ; executa a função

                         ret
limpar_tela endp

mover_bola proc
                         mov  ax, velocidade_bola_x      ; move a velocidade da bola no eixo x para ax
                         add  bola_x, ax                 ; adiciona a velocidade da bola no eixo x à coordenada x da bola

                         mov  ax, velocidade_bola_y      ; move a velocidade da bola no eixo y para ax
                         add  bola_y, ax                 ; adiciona a velocidade da bola no eixo y à coordenada y da bola

                         ret
mover_bola endp

      pong:              
                         mov  ax, @data                  ; inicializa e define o segmento de dados
                         mov  ds, ax

                         call limpar_tela                ; limpa a tela

      ; loop para atualizar o frame a cada time delta
      atualizar_frame:   
                         mov  ah, 2ch                    ; função para obter o timestamp
                         int  21h                        ; executa a função

                         cmp  dl, ultimo_timestamp       ; compara o timestamp atual (dl) com o último timestamp
                         je   atualizar_frame            ; se for igual, repete o loop

                         mov  ultimo_timestamp, dl       ; se não, atualiza o último timestamp

                         call limpar_tela                ; limpa a tela

                         call mover_bola                 ; move a bola
                         call desenhar_bola              ; desenha a bola na tela

                         jmp  atualizar_frame            ; repete o loop

  end pong
