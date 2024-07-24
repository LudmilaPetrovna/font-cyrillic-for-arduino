use GD;
use utf8;
use Encode;
use Data::Dumper;

$font_file=$ARGV[0];

open(dd,$font_file);
read(dd,$file,-s(dd));
close(dd);

($version,$filesize,$copyleft,$type,$bestsize,$vertres,$horres,$ascent,$ileading,$eleading,
$is_italic,$is_underline,$is_strikeout,$weight,$charset,$glyph_w,$glyph_h,
$pitch_family,$avg_width,$max_width,$char_start,$char_end,$char_def,$char_break,$stride_bytes,$devstr_offset,$fntname_offset,$null,$bitmap_offset,$null
)=unpack("SIA60SSSSSSSCCCSCSSCSSCCCCSIIIIC",substr($file,0,118));


$count=$char_end-$char_start;
$average=($filesize-$bitmap_offset)/$count;
$bitmap_size=($filesize-$bitmap_offset);

print <<TT;

($version,$filesize,$copyleft,$type,$bestsize,$vertres,$horres,$ascent,$ileading,$eleading,
$is_italic,$is_underline,$is_strikeout,$weight,$charset,$glyph_w,$glyph_h,
$pitch_family,$avg_width,$max_width,$char_start,$char_end,$char_def,$char_break,$stride_bytes,$devstr_offset,$fntname_offset,$null,$bitmap_offset,$null

$max_width x $glyph_w,$glyph_h,

count: $count
average: $average
stride:$stride_bytes
bitmap size: $bitmap_size
TT

@chars_info=();
for($q=$char_start;$q<=$char_end;$q++){
($gl_width,$gl_offset)=unpack("SS",substr($file,118+($q-$char_start)*4,4));
$chars_info[$q]=[$gl_width,$gl_offset];
}

=pod
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
=cut

if($glyph_w==0){
$glyph_w=$max_width;
}

$tiled=GD::Image->new($glyph_w*16,$glyph_h*16,1);
$tiled->alphaBlending(1);
$tiled->saveAlpha(1);

for($ch=0;$ch<256;$ch++){
if($ch<$char_start){next;}
$offset=$chars_info[$ch]->[1];
if(!$offset){next;}
$tx=($ch%16)*$glyph_w;
$ty=int($ch/16)*$glyph_h;
print "char: $ch, offset: $offset\n";

#$tiled->clip($tx,$ty,$tx+$glyph_w-1,$ty+$glyph_h-1);
$tiled->filledRectangle($tx,$ty,$tx+$glyph_w-1,$ty+$glyph_h-1,$xor?0xFF0000:0x00FF00);
$tiled->filledRectangle($tx+1,$ty+1,$tx+$glyph_w-2,$ty+$glyph_h-2,0x550000);

$wb=int(($chars_info[$ch]->[0]+7)/8);

for($q=0;$q<$wb;$q++){
for($w=0;$w<$glyph_h;$w++){
$byte=unpack("C",substr($file,$offset+$q*$glyph_h+$w,1));
for($e=0;$e<8;$e++){
$bit=($byte>>(7-$e))&1;
if($bit){
$tiled->setPixel($tx+$q*8+$e,$ty+$w,0xFFFFFF);
}
}
}
}

}

# phase 3: filter image, binarize it

$tw=$glyph_w*16;
$th=$glyph_h*16;

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


open(dd,">vgasys.png");
print dd $tiled->png(9);



