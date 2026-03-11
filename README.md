Mudpuppy
=====

Application for modeling plasma-liquid and related problems. Built on top of MOOSE framework and applications Zapdos and CRANE.

Currently there is no dedicated documentation for public readership.

Name is inspiried by the common mudpuppy (*Necturus maculosus*), a species of salamander with external gills (which makes it easily confused with the very popular axolotl (*Ambystoma mexicanum*). The common mudpuppy is a threatened species within the state of Illinois and is of considerable conservation effort in the Sangamon river.

# Installation
=====
Install MOOSE separately in an appropriate directory.


Clone mudpuppy:
```bash
cd ~/research
git clone https://github.com/smpeyres/mudpuppy
cd mudpuppy
git submodule update --init --recursive zapdos
```

Note: `--recursive` pulls zapdos and its dependencies (crane, squirrel, and moose). This will take some time and requires ~10GB of disk space.

Compile mudpuppy:
```bash
conda activate moose
cd ~/research/mudpuppy
make -j 4
```

Test mudpuppy:
```bash
./run_tests
```
