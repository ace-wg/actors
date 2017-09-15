OPEN=$(word 1, $(wildcard /usr/bin/xdg-open /usr/bin/open /bin/echo))
XML2RFC=xml2rfc
text: draft-ietf-ace-actors.txt
html: draft-ietf-ace-actors.html
all: text html

%.txt: %.xml
	$(XML2RFC) $<
#	$(OPEN) $@

%.html: %.xml
	$(XML2RFC) --html $<
	$(OPEN) $@

%.xml: %.mkd
	kramdown-rfc2629 $< >$@.new
	-diff $@ $@.new >$@.diff
	sed 10q $@.diff
	mv $@.new $@

rwdiff: draft-ietf-ace-actors-from--03-rw.diff.html

draft-ietf-ace-actors-from--03-rw.diff.html: draft-ietf-ace-actors.txt
	rfcdiff draft-ietf-ace-actors-03-rw.txt $<
	$(OPEN) $@
