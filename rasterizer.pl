use GD;
use utf8;
use Encode;
use Data::Dumper;

#define FT_WinFNT_ID_CP1252    0
#define FT_WinFNT_ID_DEFAULT   1
#define FT_WinFNT_ID_SYMBOL    2
#define FT_WinFNT_ID_MAC      77
#define FT_WinFNT_ID_CP932   128
#define FT_WinFNT_ID_CP949   129
#define FT_WinFNT_ID_CP1361  130
#define FT_WinFNT_ID_CP936   134
#define FT_WinFNT_ID_CP950   136
#define FT_WinFNT_ID_CP1253  161
#define FT_WinFNT_ID_CP1254  162
#define FT_WinFNT_ID_CP1258  163
#define FT_WinFNT_ID_CP1255  177
#define FT_WinFNT_ID_CP1256  178
#define FT_WinFNT_ID_CP1257  186
#define FT_WinFNT_ID_CP1251  204
#define FT_WinFNT_ID_CP874   222
#define FT_WinFNT_ID_CP1250  238
#define FT_WinFNT_ID_OEM     255


# todo: draw fonts on PNG!
# todo: get info about FONTRES
# get it work under win2 and win3
# see https://codeberg.org/KOLANICH-wine/sfnt2fon/src/branch/master/sfnt2fon.c

@cp437_header=map{chr(hex($_))}qw/20 263A 263B 2665 2666 2663 2660 2022 25D8 25CB 25D9 2642 2640 266A 266B 263C 25BA 25C4 2195 203C 00B6 00A7 25AC 21A8 2191 2193 2192 2190 221F 2194 25B2 25BC/;

$outfile=$ARGV[0];
$internal1=$ARGV[1];
$charset=$ARGV[2];


$family="SissySys";

my $FNT_HEADER_SIZE=0x76;
my $FNT_MAX_NAME=20;

open(OUTFILE,">$outfile.fnt");

$fontfile="./Fifaks10Dev1.ttf";
$fontsize=9;
$codepage="cp1251";

$offset_x=0;
$offset_y=12;

$glyph_w=7;
$glyph_h=12;
$columns=int(($glyph_w+7)/8);
$glyph_bytes=$columns*$glyph_h;

$gl=GD::Image->new($glyph_w,$glyph_h,1);

$ox_min=$oy_min=$ow_min=$oh_min=0;
$ox_max=$oy_max=$ow_max=$oh_max=0;

my $FNT_BITMAP_OFFSET=$FNT_HEADER_SIZE+256*4;
my $FNT_NAME_OFFSET=$FNT_BITMAP_OFFSET+$glyph_bytes*256;
my $FNT_FILESIZE=$FNT_NAME_OFFSET+$FNT_MAX_NAME;

printFntHeader($family,$fontsize);

for($cch=0;$cch<256;$cch++){
print "Processing charcode $cch\n";

# draw char
# reset canvas
$gl->alphaBlending(0);
$gl->filledRectangle(0,0,$glyph_w,$glyph_h,0);
$gl->alphaBlending(1);
$gl->saveAlpha(1);

# draw fancy background
for($w=0;$w<$glyph_h;$w+=2){
#$gl->filledRectangle(0,$w,$glyph_w,$w,0xFFFFFF);
}

$string=$cch<0x20?$cp437_header[$cch]:decode($codepage,chr($cch));

#         @bounds[0,1]  Lower left corner (x,y)
#         @bounds[2,3]  Lower right corner (x,y)
#         @bounds[4,5]  Upper right corner (x,y)
#         @bounds[6,7]  Upper left corner (x,y)
@bounds=$gl->stringFT(0x000000,$fontfile,$fontsize,0,$offset_x+1,$offset_y+0,$string);
@bounds=$gl->stringFT(0x000000,$fontfile,$fontsize,0,$offset_x-1,$offset_y+0,$string);
@bounds=$gl->stringFT(0x000000,$fontfile,$fontsize,0,$offset_x+0,$offset_y+1,$string);
@bounds=$gl->stringFT(0x000000,$fontfile,$fontsize,0,$offset_x+0,$offset_y-1,$string);
@bounds=$gl->stringFT(0xFFFFFF,$fontfile,$fontsize,0,$offset_x,$offset_y,$string);

$cx=$bounds[0];
$cy=$bounds[7];
$cw=$bounds[4]-$bounds[6]+1;
$ch=$bounds[3]-$bounds[5]+1;

print "Current char $cch, offset:${cx}x${cy}, size: ${cw}x${ch}\n";
#print STDERR Dumper(\@bounds);

if($ch==0){
$ox_min=$ox_max=$cx;
$oy_min=$oy_max=$cy;
$ow_min=$ow_max=$cw;
$oh_min=$oh_max=$ch;
} else {
($ox_min,$ox_max)=resize($cx,$ox_min,$ox_max);
($oy_min,$oy_max)=resize($cy,$oy_min,$oy_max);
($ow_min,$ow_max)=resize($cw,$ow_min,$ow_max);
($oh_min,$oh_max)=resize($ch,$oh_min,$oh_max);
}

# treshold
for($w=0;$w<$glyph_h;$w++){
for($q=0;$q<$glyph_w;$q++){
$gl->setPixel($q,$w,($gl->getPixel($q,$w)&0xFF)<0x80?0:1);
}
}



# print char to console
for($w=0;$w<$glyph_h;$w++){
for($q=0;$q<$glyph_w;$q++){
print "".($gl->getPixel($q,$w)?" ":"\@");
}
print "\n";
}

# binary packing
$out="";
for($q=0;$q<$columns;$q++){
for($w=0;$w<$glyph_h;$w++){
$code=0;
for($e=0;$e<8;$e++){
$code=($code<<1) | $gl->getPixel($q*8+$e,$w);
}
$out.=pack("C",$code);
}
}
print OUTFILE $out;


}

printFntTail($family,$fontsize);


unlink("$outfile.coff");
unlink("$outfile.fon");

print "Output file must be $FNT_FILESIZE";
print `stat $outfile.fnt`;
#print `/usr/bin/x86_64-w64-mingw32-windres -i $outfile.rc --codepage=cp1251 -o $outfile.coff -OCOFF`;
#print `/usr/bin/x86_64-w64-mingw32-ld $outfile.coff -o $outfile.fon`;
# test it with win95


print <<AAA;
Coords:
($ox_min,$ox_max)
($oy_min,$oy_max)
($ow_min,$ow_max)
($oh_min,$oh_max)
AAA


sub resize{
my $newval=shift;
my $min=shift;
my $max=shift;
return(($min<$newval?$min:$newval),($max>$newval?$max:$newval));
}


sub printFntHeader{
my $fontname=shift;
my $fontsize=shift;

print OUTFILE pack("SIA60SSSSSSSCCCSCSS",
0x0200, #version
$FNT_FILESIZE,
"THIS IS MY COPYLEFT!!!", #copyleft
0, # type
$fontsize, # bestsize
96+$internal1*10,96+$internal1*10, #vertres/horres
$offset_y, #ascent
$internal1,0, #uint16_t dfInternalLeading;uint16_t dfExternalLeading;
0,0,0,#int8_t is_italic;uint8_t is_underline;uint8_t is_strikeout;
400, #uint16_t weight; // 0..1000, default=400
$charset, #204, #uint8_t charset;
$glyph_w, #uint16_t pix_width; // may be zero for variable width font, non-zero for fixed width
$glyph_h #uint16_t pix_height;
);

print OUTFILE pack("CSSCCCCSIIIIC",

(3<<4), #uint8_t dfPitchAndFamily;

$glyph_w,#uint16_t avg_width; // width of char 'X'
$glyph_w,#uint16_t max_width; // or same width if fixed-width
0,#uint8_t first_char;
255,#uint8_t last_char;
ord('?'),#uint8_t default_char; // maybe '?'-first_char, but not space (32-first_char)
ord(' '),#uint8_t break_char; // maybe ' ' (32-first_char)
256*$columns,#uint16_t bitmap_width_bytes; // must be even for raster, non sense for vector
0,#uint32_t device_string_offset; // usually zero
$FNT_NAME_OFFSET,#uint32_t facename_offset; // null-terminated
0,#uint32_t bitmap_pointer; // used at loading
$FNT_BITMAP_OFFSET,#uint32_t bitmap_offset; // used at loading
0#uint8_t reserved1;
);


my $q;
for($q=0;$q<256;$q++){
print OUTFILE pack("SS",$glyph_w,$FNT_BITMAP_OFFSET+$q*$glyph_bytes);
}


}


sub printFntTail{
my $fontname=shift;
my $fontsize=shift;

my $padded_name=substr($fontname.("\0" x $FNT_MAX_NAME),0,$FNT_MAX_NAME);
print OUTFILE $padded_name;

}






























