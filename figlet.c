// стандартные библиотеки
// внутри микроконтроллера могут быть не нужны

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// инклюдим нашу "картинку" со шрифтом
#include "bge_bw.xbm"

// определяем параметры нашего шрифта
#define font_bge_char_width 5
#define font_bge_char_height 8
// (тут я использую префикс font_, чтобы не запутаться, но далее нам понадобится и bge_bw_bits/bge_bw_width без этого префикса)

// Делаем простейшую функцию отрисовки на буфере
void draw_char(uint8_t *canv, int canv_width, int canv_height, int x, int y, uint8_t ch){
int q,w,canv_x,canv_y,ppos_x,ppos_y,tpos_x,tpos_y,bo,bit;

// Где наш символ внутри "картинки"?
tpos_x=ch%16;
tpos_y=ch/16;

// Переносим пикселы символа из нашей картинки в предоставленный функии холст
for(w=0;w<font_bge_char_height;w++){
for(q=0;q<font_bge_char_width;q++){

canv_x=x+q;
canv_y=y+w;
// А мы точно не уехали за границы экрана? Нам безопасно рисовать дальше?
if(canv_x<0 || canv_y<0 || canv_x>=canv_width || canv_y>=canv_height){
continue;
}

ppos_x=tpos_x*font_bge_char_width+q;
ppos_y=tpos_y*font_bge_char_height+w;
bo=ppos_x+ppos_y*bge_bw_width;
bit=(bge_bw_bits[bo/8]>>(ppos_x%8))&1;

// Добавляем "пиксель" в наш буфер, аналог вызова setPixel в большинстве библиотек
canv[canv_x+canv_y*canv_width]=bit?'*':' ';
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
int canv_width=text_len*font_bge_char_width;
int canv_height=font_bge_char_height;
char *canv=malloc(canv_width*canv_height);


int q;
for(q=0;q<text_len;q++){
// Рисуем по 1 символу за раз через нашу функцию отрисовки шрифта
draw_char((uint8_t*)canv,canv_width,canv_height,q*font_bge_char_width,0,(uint8_t)text[q]);
}

// Выводим по строчкам на экран.
for(q=0;q<canv_height;q++){
printf("%.*s\n",canv_width,canv+canv_width*q);
}


return EXIT_SUCCESS;
}
