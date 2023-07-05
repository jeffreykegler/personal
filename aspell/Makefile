
all: aspell-timeline-api

timeline-ignore.txt: timeline-ignore.source
	sed -e 's/#.*$$//' -e 's/ *$$//' $? > $@

aspell-timeline-api: timeline-ignore.txt
	cat ../timeline_v3.html | \
	  aspell list --home-dir=. --personal=timeline-ignore.txt -H | sort | uniq

