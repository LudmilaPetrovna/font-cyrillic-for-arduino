use GD;
use utf8;
use Encode;
use Data::Dumper;

@cp437=map{chr(hex($_))}qw/20 263A 263B 2665 2666 2663 2660 2022 25D8 25CB 25D9 2642 2640 266A 266B 263C 25BA 25C4 2195 203C 00B6 00A7 25AC 21A8 2191 2193 2192 2190 221F 2194 25B2 25BC/;
$cp437[0x7f]=chr(0x2302);

$font_file="./Giana.ttf";
$font_size=6;
$font_width=8;
$font_height=8;
$font_ox=0;
$font_oy=7;
$font_autoalign=0;

$font_file="./FSEX302.ttf";
$font_size=12;
$font_width=8;
$font_height=15;
$font_ox=0;
$font_oy=12;
$font_autoalign=1;


# generate charset
my @charset=map{$cp437[$_]?$cp437[$_]:decode("cp866",chr($_))}(0..255);

# phase 1: calculate bounging box

$tmp=GD::Image->new($font_size*10,$font_size*10,1);
$center=int($font_size*10/2);
@bb=(0xFFFF,0xFFFF,0,0);
for($ch=32;$ch<240;$ch++){
@bc=$tmp->stringFT(0xffffff,$font_file,$font_size,0,$center,$center,$charset[$ch]);

=pod
         @bounds[0,1]  Lower left corner (x,y)
         @bounds[2,3]  Lower right corner (x,y)
         @bounds[4,5]  Upper right corner (x,y)
         @bounds[6,7]  Upper left corner (x,y)
=cut

if($bb[0]>$bc[6]){$bb[0]=$bc[6];}
if($bb[1]>$bc[7]){$bb[1]=$bc[7];}
if($bb[2]<$bc[2]){$bb[2]=$bc[2];}
if($bb[3]<$bc[3]){$bb[3]=$bc[3];}
}

print "Calculated bounds:\n";
print "Size: (max): ".($bb[2]-$bb[0]+1)."x".($bb[3]-$bb[1]+1)."\n";
print "Offset (min): ".($bb[0]-$center)."x".($bb[1]-$center)."\n";


# phase 2: generate tiled font image

$tiled=GD::Image->new($font_width*16,$font_height*16,1);
$tiled->alphaBlending(1);
$tiled->saveAlpha(1);

for($ch=0;$ch<256;$ch++){

$tx=($ch%16)*$font_width;
$ty=int($ch/16)*$font_height;

$char=$charset[$ch];

$xor=(($ch%16)^int($ch/16))&1;
$tiled->clip($tx,$ty,$tx+$font_width-1,$ty+$font_height-1);

$tiled->filledRectangle($tx,$ty,$tx+$font_width-1,$ty+$font_height-1,$xor?0xFF0000:0x00FF00);
$tiled->filledRectangle($tx+1,$ty+1,$tx+$font_width-2,$ty+$font_height-2,0x550000);

@bc=$tmp->stringFT(0xffffff,$font_file,$font_size,0,$center,$center,$char);
$width=$bc[2]-$bc[6]+1;
$cox=$font_ox;

$is_blocky=($ch>=176 && $ch<224)?1:0;

if($font_autoalign && $width>$font_width && !$is_blocky){
$cox=-int(($width-$font_width)/2);
}
$tiled->stringFT(0xffffff,$font_file,$font_size,0,$tx+$cox,$ty+$font_oy,$char);
}

# phase 3: filter image, binarize it

$tw=$font_width*16;
$th=$font_height*16;

$tiled->clip(0,0,$tw,$th);

for($w=0;$w<$th;$w++){
for($q=0;$q<$tw;$q++){
$pix=$tiled->getPixel($q,$w);

$pr=($pix>>16)&0xFF;
$pg=($pix>>8)&0xFF;
$pb=$pix&0xFF;

$luma=sqrt(0.299*($pr**2)+0.587*($pg**2)+0.114*($pb**2));

$luma=$luma>200?255:0;

$pix=($luma<<16) | ($luma<<8) | $luma;

$tiled->setPixel($q,$w,$pix);
}
}



open(dd,">rasterized.png");
print dd $tiled->png(9);



