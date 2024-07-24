use GD;
use utf8;
use Encode;
use Data::Dumper;
use Digest::MD5 "md5_hex";

@codepages=();
$data=<<DAT;
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
DAT

while($data=~/_ID_(\S+)\s+(\d+)/gs){
$codepages[$2]=lc($1)	;
}

opendir(dd,"fnt");
@files=grep{/\.fnt$|fon_8/i}readdir(dd);
closedir(dd);

foreach $filename(@files){

$filename="fnt/".$filename;

open(dd,$filename);
read(dd,$file,-s(dd));
close(dd);

($version,$filesize,$copyleft,$type,$bestsize,$vertres,$horres,$ascent,$ileading,$eleading,
$is_italic,$is_underline,$is_strikeout,$weight,$charset,$glyph_w,$glyph_h,
$pitch_family,$avg_width,$max_width,$char_start,$char_end,$char_def,$char_break,$stride_bytes,$devstr_offset,$fntname_offset,$null,$bitmap_offset,$null
)=unpack("SIA60SSSSSSSCCCSCSSCSSCCCCSIIIIC",substr($file,0,118));

$name=substr($file,$fntname_offset,60);
$name=~s/\x00.*//gs;

$hash=md5_hex($file);

$newfile="$name-$codepages[$charset]-${max_width}x${bestsize}.fnt";



print "$newfile $filename -> $newfile\n";
rename($filename,$newfile);
}