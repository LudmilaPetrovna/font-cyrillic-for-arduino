use utf8;
use Encode;


# http://aspell.net/charsets/cyrillic.html - небольшая история кодировок с кириллицей

@cp437=map{chr(hex($_))}qw/20 263A 263B 2665 2666 2663 2660 2022 25D8 25CB 25D9 2642 2640 266A 266B 263C 25BA 25C4 2195 203C 00B6 00A7 25AC 21A8 2191 2193 2192 2190 221F 2194 25B2 25BC/;
$cp437[0x7f]=chr(0x2302);


@cs=qw/cp866 cp1251 ISO-8859-5 KOI8-R KOI8-U MacCyrillic/;

@canv=map{" "}(1..5000);

$ox=2;
$oy=0;

foreach $charset(@cs){

for($q=0;$q<256;$q++){
$tx=$q%16;
$ty=int($q/16);
$ch=$cp437[$q]?$cp437[$q]:decode($charset,chr($q));
$p=$ox+$tx+($oy+$ty)*100;
$canv[$p]=$ch;
}

$ox+=20;
if($ox>60){
$ox=2;
$oy+=20;
}

}

for($q=0;$q<45;$q++){
$canv[$q*100]="\n";

}

binmode(STDOUT,":utf8");

print @canv;