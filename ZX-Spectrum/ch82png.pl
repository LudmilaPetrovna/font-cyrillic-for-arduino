use GD;
use utf8;
use Encode;
use File::Basename;
use Data::Dumper;

$font_file=$ARGV[0];

@charset=(
 32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,
 32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,
 32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
 48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
 64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  32,  93,  94,  95,
 32,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126,  32,
 32,  32,  32, 223,  32, 222,  32,  32,  32,  32, 221,  32,  32,  32,  32, 219,
 32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,
 32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,
 32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,
 32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,
 32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,
 32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,
 32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32
);

open(dd,$font_file) or die "$!";
read(dd,$file,-s(dd));
close(dd);

$glyph_w=$glyph_h=8;

$tiled=GD::Image->new($glyph_w*16,$glyph_h*16,1);
$tiled->alphaBlending(0);
$tiled->saveAlpha(1);
$tiled->filledRectangle(0,0,$glyph_w*16,$glyph_h*16,0);
$tiled->alphaBlending(1);

for($ch=0;$ch<256;$ch++){
$code=$charset[$ch]-32;
$offset=$code*8;
if($offset<0 || $offset>=length($file)){$offset=0;}
$tx=($ch%16)*$glyph_w;
$ty=int($ch/16)*$glyph_h;
#print "char: $ch, offset: $offset at $tx $ty\n";

for($w=0;$w<$glyph_h;$w++){
$byte=unpack("C",substr($file,$offset+$w,1));
for($e=0;$e<8;$e++){
$bit=($byte>>(7-$e))&1;
if($bit){
$tiled->setPixel($tx+$e,$ty+$w,0xFFFFFF);
}
}
}

}

$out_file=$font_file;
$out_file=~s/\.ch8$//si;
$out_file.=".png";
print "Writing font $font_file as $out_file...\n";
open(dd,">".$out_file) or die $!;
binmode(dd);
print dd $tiled->png(9);
close(dd);




