# AROS Programming guide: a guide to quickly get into AROS development
(at least hopefully quicker than it took to me to have it all working)

> This guide is oriented towards Linux users with a good deal of time on their hands and stubborn enough to get to compile the first `hello_world.c`.

## 1 - Install needed packages to compile

    $ sudo apt-get install bison flex build-essential automake autoconf netpbm python libc6-dev-i386 (64bit distro) or libc6-dev (32bit distro)

## 2 - AROS sources download and compilation

There is no working AROS SDK available, you need to download AROS sources and compile AROS and its GCC cross-compiler to have the SDK too.

AROS sources are still on Subversion. Access to that repo is too complicated so if you want to compile the SDK you need to download a tarball [here](http://aros.sourceforge.net/nightly.php) (choose the most recent from "Core AROS sources"):

    $ tar xvzf AROS-YYYYMMDD-source.tar.bz2
    $ mkdir AROS-source
    $ cd AROS-source
    $ ../AROS-YYYYMMDD-source/configure --target=linux-i386 --enable-debug
    $ make

The reason to compile in another directory is that the build system has some problems and apparently doesn't compile correctly if launched in the source directory itself.

Another note about compilation `--target`: the implicit target is `linux-i386` to build the hosted version of AROS (i.e. it runs as a Linux process). In order to create a bootable ISO on real (supported) hardware use target `pc-i386` and after `make` run also `make bootiso`.

In order to increase the debug output of an AROS build, append `arguments sysdebug=all` to the file `bin/linux-i386/AROS/boot/linux/AROSBootstrap.conf`.

## 3 - Use many AROS versions to test your software

AROS is a bit of a moving target so ensure to test your software against many AROS releases. I use **three** different environment to ensure the least possible bugs sneak into a release:
- **AROS built from sources** (which you just did)
- a recent **AROS pre-built nightly release**
- **Icaros** the main, stable, full-featured release that ideally represents the distribution for the general public.

### AROS latest nightly build (linux-i386)

Download from [here](http://aros.sourceforge.net/nightly.php).

### **Icaros**

Download from [here](http://www.icarosdesktop.org).

Icaros can run inside real hardware or a virtual machine (Virtualbox, VMWare, QEMU). The recommended way to move files to and from the virtual machine is through a local network FTP (see Icaros documentation).

I couldn't make FTP work; since I only use Virtualbox and there's no way to share a directory with an Virtualbox Icaros guest machine, I had to use a "secondary" virtual FAT32 hard drive to be **alternatively** mounted either on the virtual machine or the Linux host filesystem.

The file is a VDI image, I have a bash script [vdimount.sh](https://github.com/apiraino/aros_guide/blob/master/vdimount.sh) (requires the `qemu-utils` package) that mounts and unmounts the VDI file on the host filesystem. Customize paths in that script to your needs.

## 4 - Compile your first "Hello, world!"

Time for your first "Hello, World!" compiled for AROS.

    #include <stdio.h>

    int main(void)
    {
        puts("Hello World");
        return 0;
    }

Compile with:

    $ i386-aros-gcc -Wall -Wextra -m32 -fno-stack-protector -g hello.c -o hello

Now copy the binary created into the directory where you have AROS and run it with:

    $ cd /path/to/AROS
    $ boot/linux/AROSBootstrap

Once AROS is running, find your executable and run it.

In this GIT repo you'll find a handy script ([aros.sh](https://github.com/apiraino/aros_guide/blob/master/aros.sh)) to start AROS from the sources you just compiled (runs directly from gdb) or AROS nightly build.

    # Run AROS from your compiled sources, directly from GDB
    $ sh aros.sh DBG
    # Run AROS from a nightly build
    $ sh aros.sh

Adjust the variables in the script to suit your needs.

## 5 - Debug a crash in your application

In order to debug a segfault you need to run AROS hosted and use GDB on the hosting machine to diagnose problems.
- run `ulimit -u unlimited`
- then `boot/AROSBootstrap`
- run your application and when it crashes, AROS will abrutly die and leave a core dump
- run it into GDB with `gdb core`

OR

- run AROS hosted directly from gdb with `gdb boot/AROSBootstrap`

My script [aros.sh](https://github.com/apiraino/aros_guide/blob/master/aros.sh) can run AROS compiled directly inside GDB with a GDB config file with specific GDB commands to inspect the stack. See [here](http://aros.sourceforge.net/documentation/developers/debugging.php) for some help on how to debug your AROS software.

Note: sometimes AROS crashes and automatically reboots, proving difficult to diagnose what's wrong in your software.
After AROS compilation you can edit the file `bin/linux-i386/gen/include/inline/exec.h` adding `asm("int3")` at the end of the static function `__inline_Exec_Alert`:

    static inline void __inline_Exec_Alert(ULONG __arg1, APTR __SysBase)
    {
        AROS_LC1NR(void, Alert,
            AROS_LCA(ULONG,(__arg1),D7),
            struct ExecBase *, (__SysBase), 18, Exec    );
    }

it should become like this:

    static inline void __inline_Exec_Alert(ULONG __arg1, APTR __SysBase)
    {
        AROS_LC1NR(void, Alert,
            AROS_LCA(ULONG,(__arg1),D7),
            struct ExecBase *, (__SysBase), 18, Exec    );
        asm("int3");
    }

Rerun "make".

This way you inject a breakpoint to (hopefully) help you debugging.

## 6 - Emacs configuration:

I moved from a graphical IDE to EMACS (+24). My current setup involves the following MELPA packages:
- `prelude` (general project management) from https://github.com/bbatsov/prelude
- `helm` (for tagging code and move around files) from http://tuhdo.github.io/helm-intro.html
- `zenburn-theme` :-) from https://github.com/bbatsov/zenburn-emacs

## 7 - Eclipse configuration:

This part has been written in 2013 so it's outdated. Still, it provides a general guidance:

Let the SDK be here:
`/path/to/compiled/aros/AROS-source/bin/linux-i386/AROS/Development/include`

Open Eclipse
New -> C Project -> Linux GCC -> Next

Why not "Cross GCC"?
Because the SDK installation is still in need of care.

- Click on "Advanced Settings"
- C/C++ Build -> Select "All Configurations, then "Makefile Generation", untick "Generate Makefiles automatically"
- C/C++ General -> Path and Symbols, "GNU C" in Languages, add a new path (see above), click "add to all configurations" -> OK
- We are back to the Wizard
- Select Next, don't select any prefix/path for the cross compiler -> Finish
- If you want to see the output of make, ensure that "Console" tab (lower part of the screen) has "Display selected Console" set to either "CDT Global Build Console" or "CDT Build Console [YourPrjName]"
