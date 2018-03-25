
dummy:
	echo The target is '"all"'

all: timeline.html

timeline.html: mk_timeline0.pl timeline.html1
	perl mk_timeline0.pl timeline.html1 > timeline.html
