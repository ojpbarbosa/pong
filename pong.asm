; masm/tasm 16-bit assembly pong

.model small
.stack 100h
.data                                             ; segmento de dados
      largura_tela               dw 140h          ; largura da tela (320 pixels)
      altura_tela                dw 0c8h          ; altura da tela (200 pixels)
      borda_tela                 dw 02h           ; borda da tela (2 pixels)


      bola_x_inicial             dw 0a0h          ; coordenada x (coluna) inicial da bola
      bola_y_inicial             dw 64h           ; coordenada y (linha) inicial da bola
      bola_x                     dw 0a0h          ; coordenada x (coluna) da bola
      bola_y                     dw 64h           ; coordenada y (linha) da bola

      tamanho_bola               dw 06h           ; tamanho da bola (4x4 pixels)
      velocidade_bola_x          dw 03h           ; velocidade da bola no eixo x (coluna) (3 pixels por frame)
      velocidade_bola_y          dw 02h           ; velocidade da bola no eixo y (linha) (2 pixels por frame)


      ultimo_timestamp           db 0             ; último timestamp registrado (usado para calcular o delta time)


      jogador_um_x               dw 06h           ; coordenada x (coluna) do jogador um
      jogador_um_y               dw 46h           ; coordenada y (linha) do jogador um
      pontos_jogador_um          db 0             ; pontos do jogador um
      string_pontos_jogador_um   db '0', '$'      ; string para exibir os pontos do jogador um

      jogador_dois_x             dw 134h          ; coordenada x (coluna) do jogador dois
      jogador_dois_y             dw 46h           ; coordenada y (linha) do jogador dois
      pontos_jogador_dois        db 0             ; pontos do jogador dois
      string_pontos_jogador_dois db '0', '$'      ; string para exibir os pontos do jogador dois

      altura_jogador             dw 20h           ; altura do jogador (32 pixels)
      largura_jogador            dw 06h           ; largura do jogador (4 pixels)
      velocidade_jogador         dw 03h           ; velocidade do jogador (3 pixels por frame)
.code

      ; procedimento para desenhar a bola na tela
desenhar_bola proc
                                     mov  cx, bola_x                            ; define a coordenada x inicial da bola
                                     mov  dx, bola_y                            ; define a coordenada y inicial da bola

      ; loop para desenhar cada um dos pixels da bola horizontalmente
      ; subtraindo a coordenada x inicial da bola da coordenada x atual
      ; e comparando com o tamanho da bola, incrementando a coluna e
      ; desenhando outro pixel até o tamanho da bola ser atingido
      ; depois, reinicia a coordenada x e incrementa a coordenada y
      ; e repete o processo até o tamanho da bola ser atingido
      desenhar_bola_loop:            
                                     mov  ah, 0ch                               ; interrupção para desenhar um pixel
                                     mov  al, 0fh                               ; define a cor do pixel como branca (0fh)
                                     int  10h                                   ; executa a interrupção

                                     inc  cx                                    ; incrementa a coordenada x
                                     mov  ax, cx                                ; move a coordenada x para ax
                                     sub  ax, bola_x                            ; subtrai a coordenada x inicial da bola

                                     cmp  ax, tamanho_bola                      ; compara com o tamanho da bola
                                     jng  desenhar_bola_loop                    ; se for menor ou igual, desenha outro pixel

                                     mov  cx, bola_x                            ; se não, reinicia a coordenada x
                                     inc  dx                                    ; incrementa a coordenada y
                                     mov  ax, dx                                ; move a coordenada y para ax
                                     sub  ax, bola_y                            ; subtrai a coordenada y inicial da bola

                                     cmp  ax, tamanho_bola                      ; compara com o tamanho da bola
                                     jng  desenhar_bola_loop                    ; se for menor ou igual, desenha outro pixel

                                     ret
desenhar_bola endp

      ; procedimento para limpar a tela
limpar_tela proc
      ; redefine o modo de vídeo para 320x200 256 cores, limpando a tela
                                     mov  ah, 00h                               ; define o modo de vídeo
                                     mov  al, 13h                               ; 320x200 256 cores
                                     int  10h                                   ; executa a interrupção

                                     ret
limpar_tela endp

      ; procedimento para mover a bola
mover_bola proc
      ; movimenta a bola horizontalmente
                                     mov  ax, velocidade_bola_x                 ; move a velocidade da bola no eixo x para ax
                                     add  bola_x, ax                            ; adiciona a velocidade da bola no eixo x à coordenada x da bola

      ; verifica colisões horizontais
                                     mov  ax, borda_tela                        ; move a borda da tela para ax
                                     cmp  bola_x, ax                            ; se a bola atingir a borda esquerda da tela contando a borda da tela
                                     jl   pontuar_jogador_dois                  ; pontua para o jogador dois

                                     mov  ax, largura_tela                      ; move a largura da tela para ax
                                     sub  ax, tamanho_bola                      ; subtrai o tamanho da bola
                                     sub  ax, borda_tela                        ; subtrai a borda da tela para considerar a borda direita da tela
                                     cmp  bola_x, ax                            ; compara com a coordenada x da bola
                                     jg   pontuar_jogador_um                    ; se a bola atingir a borda direita da tela contando a borda da tela, pontua para o jogador um
                                     jmp  mover_bola_verticalmente              ; se não, movimenta a bola verticalmente

      ; label para computar um ponto para o jogador um
      pontuar_jogador_um:            
                                     neg  velocidade_bola_x                     ; inverte a velocidade da bola no eixo x

                                     inc  pontos_jogador_um                     ; incrementa os pontos do jogador um
                                     call reiniciar_bola                        ; reinicia a bola

                                     call atualizar_pontos_jogador_um           ; atualiza os pontos do jogador um na tela

                                     cmp  pontos_jogador_um, 0ah                ; se os pontos do jogador um forem iguais a 10
                                     je   fim_jogo                              ; se sim, vai para o fim do jogo

                                     ret

      ; label para computar um ponto para o jogador dois
      pontuar_jogador_dois:          
                                     neg  velocidade_bola_x                     ; inverte a velocidade da bola no eixo x

                                     inc  pontos_jogador_dois                   ; incrementa os pontos do jogador dois
                                     call reiniciar_bola                        ; reinicia a bola

                                     call atualizar_pontos_jogador_dois         ; atualiza os pontos do jogador dois na tela

                                     cmp  pontos_jogador_dois, 0ah              ; se os pontos do jogador dois forem iguais a 10
                                     je   fim_jogo                              ; se sim, vai para o fim do jogo

                                     ret

      ; game over
      fim_jogo:                      
                                     mov  ax, 4c00h                             ; finaliza o programa com o código de erro 0
                                     int  21h                                   ; executa a interrupção

      ; movimenta a bola verticalmente
      mover_bola_verticalmente:      
                                     mov  ax, velocidade_bola_y                 ; move a velocidade da bola no eixo y para ax
                                     add  bola_y, ax                            ; adiciona a velocidade da bola no eixo y à coordenada y da bola

      ; verifica colisões verticais
                                     mov  ax, borda_tela                        ; move a borda da tela para ax
                                     cmp  bola_y, ax                            ; se a bola atingir a borda superior da tela contando a borda da tela
                                     jl   inverter_velocidade_bola_y            ; inverte a velocidade da bola no eixo y

                                     mov  ax, altura_tela                       ; move a altura da tela para ax
                                     sub  ax, tamanho_bola                      ; subtrai o tamanho da bola
                                     sub  ax, borda_tela                        ; subtrai a borda da tela para considerar a borda inferior da tela
                                     cmp  bola_y, ax                            ; compara com a coordenada y da bola
                                     jg   inverter_velocidade_bola_y            ; se a bola atingir a borda inferior da tela, inverte a velocidade da bola no eixo y

      ; verifica colisão com jogadores
      ; há colisão se com o jogador dois se:
      ; (bola_x + tamanho_bola < jogador_dois_x && jogador_dois_x + largura_jogador < bola_x && bola_y + tamanho_bola > jogador_dois_y && bola_y < jogador_dois_y + altura_jogador)
                                     mov  ax, bola_x                            ; move a coordenada x da bola para ax
                                     add  ax, tamanho_bola                      ; adiciona o tamanho da bola
                                     cmp  ax, jogador_dois_x                    ; compara com a coordenada x do jogador dois
                                     jng  verificar_colisao_jogador_um          ; se a bola estiver à esquerda do jogador dois, verifica a colisão com o jogador dois

                                     mov  ax, jogador_dois_x                    ; move a coordenada x do jogador dois para ax
                                     add  ax, largura_jogador                   ; adiciona a largura do jogador
                                     cmp  bola_x, ax                            ; compara com a coordenada x da bola
                                     jnl  verificar_colisao_jogador_um          ; se a bola estiver à direita do jogador dois, verifica a colisão com o jogador um

                                     mov  ax, bola_y                            ; move a coordenada y da bola para ax
                                     add  ax, tamanho_bola                      ; adiciona o tamanho da bola
                                     cmp  ax, jogador_dois_y                    ; compara com a coordenada y do jogador dois
                                     jng  verificar_colisao_jogador_um          ; se a bola estiver abaixo do jogador dois, verifica a colisão com o jogador dois

                                     mov  ax, jogador_dois_y                    ; move a coordenada y do jogador dois para ax
                                     add  ax, altura_jogador                    ; adiciona a altura do jogador
                                     cmp  bola_y, ax                            ; compara com a coordenada y da bola
                                     jnl  verificar_colisao_jogador_um          ; se a bola estiver acima do jogador dois, verifica a colisão com o jogador dois

                                     jmp  inverter_velocidade_bola_x            ; se a bola atingir o jogador dois, inverte a velocidade da bola no eixo x

      ; inverte a velocidade da bola no eixo x
      inverter_velocidade_bola_x:    
                                     neg  velocidade_bola_x                     ; inverte a velocidade da bola no eixo x ao negativar a velocidade da bola no eixo x
                                     jmp  mover_bola_fim                        ; vai para o fim do procedimento

      ; inverte a velocidade da bola no eixo y
      inverter_velocidade_bola_y:    
                                     mov  ax, velocidade_bola_x                 ; move a velocidade da bola no eixo x para ax
                                     neg  ax                                    ; negativa a velocidade da bola no eixo x
                                     add  bola_x, ax                            ; adiciona a velocidade da bola no eixo x à coordenada x da bola
                                     neg  velocidade_bola_y                     ; inverte a velocidade da bola no eixo y ao negativar a velocidade da bola no eixo y

      ; verifica colisão com o jogador um
      verificar_colisao_jogador_um:  
      ; há colisão se com o jogador um se:
      ; (bola_x + tamanho_bola > jogador_um_x && bola_x < jogador_um_x + largura_jogador && bola_y + tamanho_bola > jogador_um_y && bola_y < jogador_um_y + altura_jogador)
                                     mov  ax, bola_x                            ; move a coordenada x da bola para ax
                                     add  ax, tamanho_bola                      ; adiciona o tamanho da bola
                                     cmp  ax, jogador_um_x                      ; compara com a coordenada x do jogador um
                                     jng  mover_bola_fim                        ; se a bola estiver à direita do jogador um, não verifica a colisão com o jogador um

                                     mov  ax, jogador_um_x                      ; move a coordenada x do jogador um para ax
                                     add  ax, largura_jogador                   ; adiciona a largura do jogador
                                     cmp  bola_x, ax                            ; compara com a coordenada x da bola
                                     jnl  mover_bola_fim                        ; se a bola estiver à direita do jogador um, não verifica a colisão com o jogador um

                                     mov  ax, bola_y                            ; move a coordenada y da bola para ax
                                     add  ax, tamanho_bola                      ; adiciona o tamanho da bola
                                     cmp  ax, jogador_um_y                      ; compara com a coordenada y do jogador um
                                     jng  mover_bola_fim                        ; se a bola estiver abaixo do jogador um, não verifica a colisão com o jogador um

                                     mov  ax, jogador_um_y                      ; move a coordenada y do jogador um para ax
                                     add  ax, altura_jogador                    ; adiciona a altura do jogador
                                     cmp  bola_y, ax                            ; compara com a coordenada y da bola
                                     jnl  mover_bola_fim                        ; se a bola estiver acima do jogador um, não verifica a colisão com o jogador um

                                     jmp  inverter_velocidade_bola_x            ; se a bola atingir o jogador um, inverte a velocidade da bola no eixo x

      ; fim do procedimento
      mover_bola_fim:                
                                     ret

mover_bola endp

      ; procedimento para reiniciar a bola no centro da tela
reiniciar_bola proc
      ; reinicia a coordenada x e y da bola para o centro da tela
                                     mov  ax, bola_x_inicial                    ; move a coordenada x inicial da bola para ax
                                     mov  bola_x, ax                            ; move a coordenada x inicial da bola para a coordenada x da bola

                                     mov  ax, bola_y_inicial                    ; move a coordenada y inicial da bola para ax
                                     mov  bola_y, ax                            ; move a coordenada y inicial da bola para a coordenada y da bola

                                     ret
reiniciar_bola endp

      ; procedimento para desenhar os jogadores
desenhar_jogadores proc
                                     mov  cx, jogador_um_x                      ; define a coordenada x inicial do jogador um
                                     mov  dx, jogador_um_y                      ; define a coordenada y inicial do jogador um

      ; loop para desenhar cada um dos pixels do jogador um horizontalmente
      ; subtraindo a coordenada x inicial do jogador um da coordenada x atual
      ; e comparando com a largura do jogador um, incrementando a coluna e
      ; desenhando outro pixel até a largura do jogador um ser atingido
      ; depois, reinicia a coordenada x e incrementa a coordenada y
      ; e repete o processo até a altura do jogador um ser atingido
      desenhar_jogador_um_loop:      
                                     mov  ah, 0ch                               ; interrupção para desenhar um pixel
                                     mov  al, 0fh                               ; define a cor do pixel como branca (0fh)
                                     int  10h                                   ; executa a interrupção

                                     inc  cx                                    ; incrementa a coordenada x
                                     mov  ax, cx                                ; move a coordenada x para ax
                                     sub  ax, jogador_um_x                      ; subtrai a coordenada x inicial do jogador

                                     cmp  ax, largura_jogador                   ; compara com a largura do jogador
                                     jng  desenhar_jogador_um_loop              ; se for menor ou igual, desenha outro pixel

                                     mov  cx, jogador_um_x                      ; se não, reinicia a coordenada x
                                     inc  dx                                    ; incrementa a coordenada y
                                     mov  ax, dx                                ; move a coordenada y para ax
                                     sub  ax, jogador_um_y                      ; subtrai a coordenada y inicial do jogador

                                     cmp  ax, altura_jogador                    ; compara com a altura do jogador
                                     jng  desenhar_jogador_um_loop              ; se for menor ou igual, desenha outro pixel

                                     mov  cx, jogador_dois_x                    ; define a coordenada x inicial do jogador dois
                                     mov  dx, jogador_dois_y                    ; define a coordenada y inicial do jogador dois

      ; loop para desenhar cada um dos pixels do jogador dois horizontalmente
      ; subtraindo a coordenada x inicial do jogador dois da coordenada x atual
      ; e comparando com a largura do jogador dois, incrementando a coluna e
      ; desenhando outro pixel até a largura do jogador dois ser atingido
      ; depois, reinicia a coordenada x e incrementa a coordenada y
      ; e repete o processo até a altura do jogador dois ser atingido
      desenhar_jogador_dois_loop:    
                                     mov  ah, 0ch                               ; interrupção para desenhar um pixel
                                     mov  al, 0fh                               ; define a cor do pixel como branca (0fh)
                                     int  10h                                   ; executa a interrupção

                                     inc  cx                                    ; incrementa a coordenada x
                                     mov  ax, cx                                ; move a coordenada x para ax
                                     sub  ax, jogador_dois_x                    ; subtrai a coordenada x inicial do jogador

                                     cmp  ax, largura_jogador                   ; compara com a largura do jogador
                                     jng  desenhar_jogador_dois_loop            ; se for menor ou igual, desenha outro pixel

                                     mov  cx, jogador_dois_x                    ; se não, reinicia a coordenada x
                                     inc  dx                                    ; incrementa a coordenada y
                                     mov  ax, dx                                ; move a coordenada y para ax
                                     sub  ax, jogador_dois_y                    ; subtrai a coordenada y inicial do jogador

                                     cmp  ax, altura_jogador                    ; compara com a altura do jogador
                                     jng  desenhar_jogador_dois_loop            ; se for menor ou igual, desenha outro pixel

                                     ret


desenhar_jogadores endp

      ; procedimento para mover os jogadores
mover_jogadores proc
                                     mov  ah, 01h                               ; interrupção para verificar se uma tecla foi pressionada
                                     int  16h                                   ; executa a interrupção

                                     jz   mover_jogador_dois                    ; se nenhuma tecla foi pressionada, pula para mover o jogador dois

                                     mov  ah, 00h                               ; interrupção para obter o código da tecla pressionada
                                     int  16h                                   ; executa a interrupção

                                     cmp  al, 'w'                               ; compara o código da tecla pressionada com a tecla 'w'
                                     je   mover_jogador_um_cima                 ; se for igual, pula para mover o jogador um para cima

                                     cmp  al, 'W'                               ; compara o código da tecla pressionada com a tecla 'W'
                                     je   mover_jogador_um_cima                 ; se for igual, pula para mover o jogador um para cima

                                     cmp  al, 's'                               ; compara o código da tecla pressionada com a tecla 's'
                                     je   mover_jogador_um_baixo                ; se for igual, pula para mover o jogador um para baixo

                                     cmp  al, 'S'                               ; compara o código da tecla pressionada com a tecla 'S'
                                     je   mover_jogador_um_baixo                ; se for igual, pula para mover o jogador um para baixo

                                     jmp  mover_jogador_dois                    ; se não, pula para mover o jogador dois

      ; label para mover o jogador um para cima
      mover_jogador_um_cima:         
                                     mov  ax, velocidade_jogador                ; move a velocidade do jogador para ax
                                     sub  jogador_um_y, ax                      ; subtrai a velocidade do jogador à coordenada y do jogador um

                                     mov  ax, borda_tela                        ; move a borda da tela para ax
                                     cmp  jogador_um_y, ax                      ; compara a coordenada y do jogador um com a borda da tela
                                     jl   redefinir_jogador_um_y_cima           ; se for menor, redefine a coordenada y do jogador um

                                     jmp  mover_jogador_dois                    ; pula para mover o jogador dois

      ; label para redefinir a coordenada y do jogador um para cima
      redefinir_jogador_um_y_cima:   
                                     mov  jogador_um_y, ax                      ; redefine a coordenada y do jogador um
                                     jmp  mover_jogador_dois                    ; pula para mover o jogador dois

      ; label para mover o jogador um para baixo
      mover_jogador_um_baixo:        
                                     mov  ax, velocidade_jogador                ; move a velocidade do jogador para ax
                                     add  jogador_um_y, ax                      ; adiciona a velocidade do jogador à coordenada y do jogador um

                                     mov  ax, altura_tela                       ; move a altura da tela para ax
                                     sub  ax, borda_tela                        ; subtrai a borda da tela da altura da tela
                                     sub  ax, altura_jogador                    ; subtrai a altura do jogador da altura da tela
                                     cmp  jogador_um_y, ax                      ; compara a coordenada y do jogador um com a altura da tela
                                     jg   redefinir_jogador_um_y_baixo          ; se for maior, redefine a coordenada y do jogador um

                                     jmp  mover_jogador_dois                    ; pula para mover o jogador dois

      ; label para redefinir a coordenada y do jogador um para baixo
      redefinir_jogador_um_y_baixo:  
                                     mov  jogador_um_y, ax                      ; redefine a coordenada y do jogador um
                                     jmp  mover_jogador_dois                    ; pula para mover o jogador dois

      ; label para mover o jogador dois
      mover_jogador_dois:            
                                     mov  ah, 01h                               ; interrupção para verificar se uma tecla foi pressionada
                                     int  16h                                   ; executa a interrupção
                                     jz   mover_jogadores_fim                   ; se nenhuma tecla foi pressionada, pula para mover_jogadores_fim

                                     mov  ah, 00h                               ; interrupção para obter o código da tecla pressionada
                                     int  16h                                   ; executa a interrupção

                                     cmp  al, 'i'                               ; compara o código da tecla pressionada com a tecla 'i'
                                     je   mover_jogador_dois_cima               ; se for igual, pula para mover o jogador dois para cima

                                     cmp  al, 'I'                               ; compara o código da tecla pressionada com a tecla 'I'
                                     je   mover_jogador_dois_cima               ; se for igual, pula para mover o jogador dois para cima

                                     cmp  al, 'k'                               ; compara o código da tecla pressionada com a tecla 'k'
                                     je   mover_jogador_dois_baixo              ; se for igual, pula para mover o jogador dois para baixo

                                     cmp  al, 'K'                               ; compara o código da tecla pressionada com a tecla 'K'
                                     je   mover_jogador_dois_baixo              ; se for igual, pula para mover o jogador dois para baixo

                                     jmp  mover_jogadores_fim                   ; se não, pula para mover_jogadores_fim

      ; label para mover o jogador dois para cima
      mover_jogador_dois_cima:       
                                     mov  ax, velocidade_jogador                ; move a velocidade do jogador para ax
                                     sub  jogador_dois_y, ax                    ; subtrai a velocidade do jogador à coordenada y do jogador dois

                                     mov  ax, borda_tela                        ; move a borda da tela para ax
                                     cmp  jogador_dois_y, ax                    ; compara a coordenada y do jogador dois com a borda da tela
                                     jl   redefinir_jogador_dois_y_cima         ; se for menor, redefine a coordenada y do jogador dois

                                     jmp  mover_jogadores_fim                   ; pula para mover_jogadores_fim

      ; label para redefinir a coordenada y do jogador dois para cima
      redefinir_jogador_dois_y_cima: 
                                     mov  jogador_dois_y, ax                    ; redefine a coordenada y do jogador dois

                                     jmp  mover_jogadores_fim                   ; pula para mover_jogadores_fim

      ; label para mover o jogador dois para baixo
      mover_jogador_dois_baixo:      
                                     mov  ax, velocidade_jogador                ; move a velocidade do jogador para ax
                                     add  jogador_dois_y, ax                    ; adiciona a velocidade do jogador à coordenada y do jogador dois

                                     mov  ax, altura_tela                       ; move a altura da tela para ax
                                     sub  ax, borda_tela                        ; subtrai a borda da tela da altura da tela
                                     sub  ax, altura_jogador                    ; subtrai a altura do jogador da altura da tela
                                     cmp  jogador_dois_y, ax                    ; compara a coordenada y do jogador dois com a altura da tela
                                     jg   redefinir_jogador_dois_y_baixo        ; se for maior, redefine a coordenada y do jogador dois

                                     jmp  mover_jogadores_fim                   ; pula para mover_jogadores_fim

      ; label para redefinir a coordenada y do jogador dois para baixo
      redefinir_jogador_dois_y_baixo:
                                     mov  jogador_dois_y, ax                    ; redefine a coordenada y do jogador dois

      ; fim do procedimento para mover os jogadores
      mover_jogadores_fim:           
                                     ret

mover_jogadores endp

      ; procedimento para desenhar a rede
desenhar_rede proc
                                     mov  cx, si                                ; move si para cx (coordenada x inicial da rede)
                                     mov  dx, di                                ; move di para dx (coordenada y inicial da rede)

      ; loop para desenhar a rede na tela, percorrendo a largura e a altura da rede
      desenhar_rede_loop:            
                                     mov  ah, 0ch                               ; interrupção para desenhar um pixel
                                     mov  al, 0fh                               ; define a cor do pixel como branca (0fh)
                                     int  10h                                   ; executa a interrupção

                                     inc  cx                                    ; incrementa a coordenada x
                                     mov  ax, cx                                ; move a coordenada x para ax
                                     sub  ax, si                                ; subtrai a coordenada x inicial do jogador

                                     cmp  ax, 03h                               ; compara com a largura da rede
                                     jng  desenhar_rede_loop                    ; se for menor ou igual, desenha outro pixel

                                     mov  cx, si                                ; move a coordenada x inicial da bola para cx (rede)
                                     inc  dx                                    ; incrementa a coordenada y

                                     cmp  dx, bx                                ; compara com a altura da rede
                                     jng  desenhar_rede_loop                    ; se for menor ou igual, desenha outro pixel

                                     ret
desenhar_rede endp

      ; desenha a interface do jogo na tela
desenhar_interface proc
                                     mov  ah, 02h                               ; interrupção para mover o cursor
                                     mov  bh, 00h                               ; move o número da página 0
                                     mov  dh, 02h                               ; move o cursor para a linha 2
                                     mov  dl, 09h                               ; move o cursor para a coluna 9
                                     int  10h                                   ; executa a interrupção

                                     mov  ah, 09h                               ; interrupção para imprimir uma string
                                     lea  dx, string_pontos_jogador_um          ; carrega o endereço da string para dx
                                     int  21h                                   ; executa a interrupção

                                     mov  ah, 02h                               ; interrupção para mover o cursor
                                     mov  bh, 00h                               ; move o número da página 0
                                     mov  dh, 02h                               ; move o cursor para a linha 2
                                     mov  dl, 1eh                               ; move o cursor para a coluna 30
                                     int  10h                                   ; executa a interrupção

                                     mov  ah, 09h                               ; interrupção para imprimir uma string
                                     lea  dx, string_pontos_jogador_dois        ; carrega o endereço da string para dx
                                     int  21h                                   ; executa a interrupção

                                     mov  si, bola_x_inicial                    ; move a coordenada x inicial da bola para si

      ; desenha as diferentes redes de forma vazada
                                     mov  di, 00h                               ; move a coordenada y inicial da rede
                                     mov  bx, 11h                               ; move a altura da rede para bx
                                     call desenhar_rede                         ; desenha a rede

                                     mov  di, 20h                               ; move a coordenada y inicial da rede
                                     mov  bx, 31h                               ; move a altura da rede para bx
                                     call desenhar_rede                         ; desenha a rede

                                     mov  di, 42h                               ; move a coordenada y inicial da rede
                                     mov  bx, 53h                               ; move a altura da rede para bx
                                     call desenhar_rede                         ; desenha a rede

                                     mov  di, 64h                               ; move a coordenada y inicial da rede
                                     mov  bx, 75h                               ; move a altura da rede para bx
                                     call desenhar_rede                         ; desenha a rede

                                     mov  di, 86h                               ; move a coordenada y inicial da rede
                                     mov  bx, 97h                               ; move a altura da rede para bx
                                     call desenhar_rede                         ; desenha a rede

                                     mov  di, 0a8h                              ; move a coordenada y inicial da rede
                                     mov  bx, 0b9h                              ; move a altura da rede para bx
                                     call desenhar_rede                         ; desenha a rede

                                     ret


desenhar_interface endp

      ; atualiza os pontos do jogador um
atualizar_pontos_jogador_um proc
                                     xor  ax, ax                                ; limpa o registrador ax

                                     mov  al, pontos_jogador_um                 ; move os pontos do jogador um para al
                                     add  al, '0'                               ; adiciona o código ASCII de '0' a al, para converter o número para string
                                     mov  [string_pontos_jogador_um], al        ; move o código ASCII de '0' para a string de pontos do jogador um

                                     ret
atualizar_pontos_jogador_um endp

      ; atualiza os pontos do jogador dois
atualizar_pontos_jogador_dois proc
                                     xor  ax, ax                                ; limpa o registrador ax

                                     mov  al, pontos_jogador_dois               ; move os pontos do jogador dois para al
                                     add  al, '0'                               ; adiciona o código ASCII de '0' a al, para converter o número para string
                                     mov  [string_pontos_jogador_dois], al      ; move o código ASCII de '0' para a string de pontos do jogador dois

                                     ret
atualizar_pontos_jogador_dois endp

      pong:                          
                                     mov  ax, @data                             ; inicializa e define o segmento de dados
                                     mov  ds, ax

                                     call limpar_tela                           ; limpa a tela

      ; loop para atualizar o frame a cada time delta
      atualizar_frame:               
                                     mov  ah, 2ch                               ; interrupção para obter o timestamp
                                     int  21h                                   ; executa a interrupção

                                     cmp  dl, ultimo_timestamp                  ; compara o timestamp atual (dl) com o último timestamp
                                     je   atualizar_frame                       ; se for igual, repete o loop

                                     mov  ultimo_timestamp, dl                  ; se não, atualiza o último timestamp

                                     call limpar_tela                           ; limpa a tela

                                     call mover_bola                            ; move a bola
                                     call desenhar_bola                         ; desenha a bola na tela

                                     call mover_jogadores                       ; move os jogadores
                                     call desenhar_jogadores                    ; desenha os jogadores na tela

                                     call desenhar_interface                    ; desenha a interface do jogo na tela

                                     jmp  atualizar_frame                       ; repete o loop

  end pong
