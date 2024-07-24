use GD;
use Encode;
use Text::Unidecode;

$filename=$ARGV[0];
$charset=$ARGV[1] || "cp866";

if(!$filename){die "Usage: png2picolib.pl filename.png [cp866]";}

$img=GD::Image->newFromPng($filename,1);
($iw,$ih)=$img->getBounds();
($cw,$ch)=($iw/16,$ih/16);
$name=$filename;
$name=~s/.+\///gs;
$name=~s/\.png//is;
$name=~s/[^a-z0-9_]+/_/is;
$name=~s/_?${cw}x${ch}//s;

print "Converting file \"$filename\" as font \"$name\" size: ${cw}x${ch}\n";

$defname=uc("${name}_${cw}x${ch}_font");
$varname=lc("font_${name}_${cw}x${ch}");
$outfilename='pico-ssd1306-master/textRenderer/'.lc($defname).".h";


$cbl=int(($ch+7)/8);
@glyphs=();
for($chr=32;$chr<256;$chr++){

$tx=$chr%16;
$ty=int($chr/16);
@bytes=();

for($q=0;$q<$cw;$q++){
for($w=0;$w<$cbl;$w++){
$byte="";
for($e=0;$e<8;$e++){
$byte.=$img->getPixel($tx*$cw+$q,$ty*$ch+$w*8+7-$e)?"1":"0";
}
push(@bytes,ord(pack("B8",$byte)));
}
}
$hch=sprintf("%2x",$chr);
$text=unidecode(decode($charset,chr($chr)));
$glyphs[$chr]="/* char $chr (0x$hch) $text */ ".join(",",@bytes);

}


$full=join(",\n",@glyphs[32..255]);
$half=join(",\n",@glyphs[32..127]);

open(dd,">".$outfilename);
print dd <<CODE;

#ifndef SSD1306_${defname}_H
#define SSD1306_${defname}_H

#ifndef SSD1306_ASCII_FULL

const unsigned char ${varname}[] = {
    ${cw}, ${ch}, // font width, height
$full
};

#else
const unsigned char ${varname}[] = {
    ${cw}, ${ch}, // font width, height
$half
};

#endif // SSD1306_ASCII_FULL
#endif // SSD1306_${defname}_H

CODE
close(dd);

