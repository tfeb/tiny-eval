# Just a cleaner
#

FASLS     = *.*fasl *.*fsl

.PHONY: clean

clean:
	@rm -f $(FASLS)
	@rm -f *~
