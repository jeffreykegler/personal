
dummy:
	echo The target is '"all"'

all: timeline_v3.html

timeline_v3.html: mk_v3_timeline0.pl timeline_v3.html1
	perl mk_v3_timeline0.pl timeline_v3.html1 > timeline_v3.html
