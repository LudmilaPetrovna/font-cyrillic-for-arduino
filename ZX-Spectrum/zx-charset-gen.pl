use utf8;
use Encode;
binmode(STDOUT,":utf8");

@cp437=map{chr(hex($_))}qw/20 263A 263B 2665 2666 2663 2660 2022 25D8 25CB 25D9 2642 2640 266A 266B 263C 25BA 25C4 2195 203C 00B6 00A7 25AC 21A8 2191 2193 2192 2190 221F 2194 25B2 25BC/;
$cp437[0x7f]=chr(0x2302);

$mapto="cp866";
$defchar=32;

@lines=split(/\n/,<<CODE);
x0		INK	 	0	\@	P	£	p	 	(A)	(Q)	VAL	USR	FORMAT	LPRINT	LIST
x1		PAPER	!	1	A	Q	a	q	▝	(B)	(R)	LEN	STR\$	MOVE	LLIST	LET
x2		FLASH	\"	2	B	R	b	r	▘	(C)	(S)	SIN	CHR\$	ERASE	STOP	PAUSE
x3		BRIGHT	\#	3	C	S	c	s	▀	(D)	(T)*	COS	NOT	OPEN #	READ	NEXT
x4		INVERSE	\$	4	D	T	d	t	▗	(E)	(U)**	TAN	BIN	CLOSE #	DATA	POKE
x5		OVER	%	5	E	U	e	u	▐	(F)	RND	ASN	OR	MERGE	RESTORE	PRINT
x6	comma	AT	&	6	F	V	f	v	▚	(G)	INKEY\$	ACS	AND	VERIFY	NEW	PLOT
x7		TAB	\'	7	G	W	g	w	▜	(H)	PI	ATN	<=	BEEP	BORDER	RUN
x8	left		(	8	H	X	h	x	▖	(I)	FN	LN	>=	CIRCLE	CONTINUE	SAVE
x9	right		)	9	I	Y	i	y	▞	(J)	POINT	EXP	<>	INK	DIM	RANDOMIZE
xA	down		*	:	J	Z	j	z	▌	(K)	SCREEN\$	INT	LINE	PAPER	REM	IF
xB	up		+	;	K	[	k	{	▛	(L)	ATTR	SQR	THEN	FLASH	FOR	CLS
xC	delete		,	<	L	\	l	|	▅	(M)	AT	SGN	TO	BRIGHT	GO TO	DRAW
xD	enter		-	=	M	]	m	}	▟	(N)	TAB	ABS	STEP	INVERSE	GO SUB	CLEAR
xE			.	>	N	^	n	~	▙	(O)	VAL\$	PEEK	DEF FN	OVER	INPUT	RETURN
xF			/	?	O	_	o	©	█	(P)	CODE	IN	CAT	OUT	LOAD	COPY
CODE

# create forward map
%codepoints=();
for($q=0;$q<256;$q++){
$uni=$cp437[$q]?$cp437[$q]:decode($mapto,chr($q));
$codepoints{$uni}=$q;
print $uni.($q && ($q&0xf)==15?"\n":"");
}

for($q=0;$q<256;$q++){
$line=$q&0xF;
@cols=split(/\t/,$lines[$line]);
$char=$cols[($q>>4)+1];
$code=exists $codepoints{$char}?$codepoints{$char}:$defchar;
printf("%3d, ",$code);

if($q && ($q%16)==15){
print "\n";
}

}