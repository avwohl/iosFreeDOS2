NASM = nasm

# DOS COM programs (file transfer utilities)
DOS_PROGS = dos/r.com dos/w.com

all: $(DOS_PROGS)

dos/r.com: dos/r.asm
	$(NASM) -f bin -o $@ $<

dos/w.com: dos/w.asm
	$(NASM) -f bin -o $@ $<

clean:
	rm -f $(DOS_PROGS)

.PHONY: all clean
