; masm 16-bit assembly pong

.model small
.stack 100h
.data                                ; segmento de dados
      largura_tela      dw 140h      ; largura da tela (320 pixels)
      altura_tela       dw 0c8h      ; altura da tela (200 pixels)
      borda_tela        dw 02h       ; borda da tela (2 pixels)

      bola_x_inicial    dw 0a0h      ; coordenada x (coluna) inicial da bola
      bola_y_inicial    dw 64h       ; coordenada y (linha) inicial da bola
      bola_x            dw 04h       ; coordenada x (coluna) da bola
      bola_y            dw 04h       ; coordenada y (linha) da bola
      tamanho_bola      dw 04h       ; tamanho da bola (4x4 pixels)
      velocidade_bola_x dw 03h       ; velocidade da bola no eixo x (coluna) (3 pixels por frame)
      velocidade_bola_y dw 02h       ; velocidade da bola no eixo y (linha) (2 pixels por frame)

      ultimo_timestamp  db 00h       ; último timestamp registrado (usado para calcular o delta time

      jogador_um_x      dw 04h       ; coordenada x (coluna) do jogador um
      jogador_um_y      dw 04h       ; coordenada y (linha) do jogador um
      jogador_dois_x    dw 0b0h      ; coordenada x (coluna) do jogador dois
      jogador_dois_y    dw 04h       ; coordenada y (linha) do jogador dois
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

                                 cmp  ax, tamanho_bola           ; compara com o tamanho da bola
                                 jng  desenhar_bola_loop         ; se for menor ou igual, desenha outro pixel

                                 mov  cx, bola_x                 ; se não, reinicia a coordenada x
                                 inc  dx                         ; incrementa a coordenada y
                                 mov  ax, dx                     ; move a coordenada y para ax
                                 sub  ax, bola_y                 ; subtrai a coordenada y inicial da bola

                                 cmp  ax, tamanho_bola           ; compara com o tamanho da bola
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

      ; procedimento para mover a bola
mover_bola proc
      ; movimenta a bola horizontalmente
                                 mov  ax, velocidade_bola_x      ; move a velocidade da bola no eixo x para ax
                                 add  bola_x, ax                 ; adiciona a velocidade da bola no eixo x à coordenada x da bola

                                 mov  ax, borda_tela             ; move a borda da tela para ax
                                 cmp  bola_x, ax                 ; se a bola atingir a borda esquerda da tela contando a borda da tela
      ; jl   inverter_velocidade_bola_x             ; inverte a velocidade da bola no eixo x
                                 jl   reiniciar_bola

      ; senão
                                 mov  ax, largura_tela           ; move a largura da tela para ax
                                 sub  ax, tamanho_bola           ; subtrai o tamanho da bola
                                 sub  ax, borda_tela             ; subtrai a borda da tela para considerar a borda direita da tela
                                 cmp  bola_x, ax                 ; compara com a coordenada x da bola
      ;    jg   inverter_velocidade_bola_x             ; se a bola atingir a borda direita da tela, inverte a velocidade da bola no eixo x
                                 jg   reiniciar_bola


      ; movimenta a bola verticalmente
                                 mov  ax, velocidade_bola_y      ; move a velocidade da bola no eixo y para ax
                                 add  bola_y, ax                 ; adiciona a velocidade da bola no eixo y à coordenada y da bola

                                 mov  ax, borda_tela             ; move a borda da tela para ax
                                 cmp  bola_y, ax                 ; se a bola atingir a borda superior da tela contando a borda da tela
      ;      jl   inverter_velocidade_bola_y             ; inverte a velocidade da bola no eixo y
                                 jl   reiniciar_bola

      ; senão
                                 mov  ax, altura_tela            ; move a altura da tela para ax
                                 sub  ax, tamanho_bola           ; subtrai o tamanho da bola
                                 sub  ax, borda_tela             ; subtrai a borda da tela para considerar a borda inferior da tela
                                 cmp  bola_y, ax                 ; compara com a coordenada y da bola
      ;     jg   inverter_velocidade_bola_y             ; se a bola atingir a borda inferior da tela, inverte a velocidade da bola no eixo y
                                 jg   reiniciar_bola

                                 ret

      ; inverte a velocidade da bola no eixo x
      inverter_velocidade_bola_x:
                                 neg  velocidade_bola_x

                                 ret


      ; inverte a velocidade da bola no eixo y
      inverter_velocidade_bola_y:
                                 neg  velocidade_bola_y

                                 ret

mover_bola endp

      ; procedimento para reiniciar a bola no centro da tela
reiniciar_bola proc
      ; reinicia a coordenada x e y da bola para o centro da tela
                                 mov  ax, bola_x_inicial         ; move a coordenada x inicial da bola para ax
                                 mov  bola_x, ax                 ; move a coordenada x inicial da bola para a coordenada x da bola
                                 mov  ax, bola_y_inicial         ; move a coordenada y inicial da bola para ax
                                 mov  bola_y, ax                 ; move a coordenada y inicial da bola para a coordenada y da bola

                                 ret
reiniciar_bola endp

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
