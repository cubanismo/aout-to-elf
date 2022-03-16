If Google brought you here, I'm sorry. This probably isn't what you'd hoped for.

I wanted to see if a statically-linked (including libc) a.out x86 Linux binary
could be converted to a working ELF binary directly. I didn't quite succeed, but
it seems like the concept should work in theory. I'm sharing these here in case
any poor soul finds themselves in the same situation and has more time & effort
to put into it but needs some ideas to get started. They aren't actually useful
as-is. As noted in the comments at the top of the shell scripts, they are each
hard-coded to only work with one specific a.out executable, and even then don't
produce working results.
