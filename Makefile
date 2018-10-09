
dummy:
	echo The target is '"all"'

all: timeline_v3.html

timeline_v3.html: timeline_v3.pl
	perl timeline_v3.pl > timeline_v3.html
