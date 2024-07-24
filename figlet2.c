// стандартные библиотеки
// внутри микроконтроллера могут быть не нужны

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// инклюдим шрифты нашей библиотеки
#define SSD1306_ASCII_FULL
#include "pico-ssd1306-master/textRenderer/5x8_font.h"
#include "pico-ssd1306-master/textRenderer/8x8_font.h"
#include "pico-ssd1306-master/textRenderer/12x16_font.h"
#include "pico-ssd1306-master/textRenderer/16x32_font.h"

char *font=(char*)font_16x32;

void draw_char(uint8_t *canv, int canv_width, int canv_height, int ax, int ay, uint8_t ch){
if(!font || ch < 32)return;

uint8_t font_width = font[0];
uint8_t font_height = font[1];

uint16_t seek = (ch - 32) * (font_width * font_height) / 8 + 2;

uint8_t b_seek = 0;

for (uint8_t x = 0; x < font_width; x++) {
    for (uint8_t y = 0; y < font_height; y++) {
        if (font[seek] >> b_seek & 0b00000001) {


int canv_x=x+ax;
int canv_y=y+ay;
// А мы точно не уехали за границы экрана? Нам безопасно рисовать дальше?
if(canv_x<0 || canv_y<0 || canv_x>=canv_width || canv_y>=canv_height){
continue;
}

// Добавляем "пиксель" в наш буфер, аналог вызова setPixel в большинстве библиотек
canv[canv_x+canv_y*canv_width]='*';


                }
                b_seek++;
                if (b_seek == 8) {
                    b_seek = 0;
                    seek++;
                }
            }
        }
}

// Основная функция нашей программы
int main(int argc, char **argv){

// А пользователь точно не идиот?
if(argc<2){fprintf(stderr,"Usage: %s \"your text here\"\n",argv[0]);abort();}

char *text=argv[1];
int text_len=strlen(text);

// Делаем виртуальный холст, на котором потом будем рисовать
int canv_width=text_len*font[0];
int canv_height=font[1];
char *canv=malloc(canv_width*canv_height);
memset(canv,' ',canv_width*canv_height);

int q;
for(q=0;q<text_len;q++){
// Рисуем по 1 символу за раз через нашу функцию отрисовки шрифта
draw_char((uint8_t*)canv,canv_width,canv_height,q*font[0],0,(uint8_t)text[q]);
}

// Выводим по строчкам на экран.
for(q=0;q<canv_height;q++){
printf("%.*s\n",canv_width,canv+canv_width*q);
}


return EXIT_SUCCESS;
}
