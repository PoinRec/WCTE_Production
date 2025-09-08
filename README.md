# WCTE_Production
Scripts to run WCTE Monte Carlo Simulations on idark and to convert the output .root files from WCSim to .h5 files for further WatChMaL training.

There are several different folders under `WCTE_Production/` (e.g. `e-/`, `gamma/`), representing scripts for generating different particles. For now, there are only scripts for cases that the pariticles are uniformly distributed -- both homogeneous and isotropic.


## Dependencies
This repo needs environment for both [**WatChMaL**](https://github.com/WatChMaL/WatChMaL) and [**WCSim**](https://github.com/WCSim/WCSim) so you may need twocontainer images.

To successfully run this repo, you need to clone the `dev` branch of my fork of the [**MC_Production**](https://github.com/PoinRec/MC_Production/tree/dev) repository, which modifies the output path to write under whatever path you want (in my case `/lustre` due to the large file size).
 
I highly recommend `software_workshop.sif` for the image of WCSim since I source all the necessary environment variables using `source /opt/entrypoint.sh` in my scripts. So if you want to use other images, you may need to modify that.


## `config.sh`
I’ve tried to make this repo as encapsulated as possible. Most parameters can be configured without modifying the code, via the `config.sh` file.

An example file `EXAMPLE_config.sh` is provided under `WCTE_Production`. You should create your own `config.sh` in the same directory by copying and modifying this example before running any simulations.

All scripts begin by sourcing `config.sh` via `source $HOME/WCTE_Production/config.sh`, so that all variables are properly loaded. Therefore, the only path you must keep consistent is placing `WCTE_Production` directly under your `$HOME`.

Most variables in `config.sh` specify paths, except for `NO_MNT`. If `NO_MNT=TRUE` is set, the container does **not** mount directories under `/mnt`. Instead, it mounts them directly using paths like:

```bash
singularity exec -B "$HOME":"$HOME" \
        -B "$MYLUSTRE":"$MYLUSTRE" \
        "$IMAGE_H5" \
        bash -lc "
                # SOME SCRIPTS
                "
```

If you’re unsure, just set `NO_MNT=TRUE` as shown in `EXAMPLE_config.sh`.

I've involved `config.sh` in `.gitignore` so its change won't be saved by git.


## Scripts
For most scripts under the subfolder like `e-/`, they start with a number (e.g. `00_create_mac_and_submit_all.sh`, `02_root2npz.sh`) indicating the sequence you should execute the shell script in. The Script `01_run_validation.sh` is not necessary for the whole pipeline of Monte Carlo simulation, they are just inserted in a proper position they should be executed. But you can also run it with `02_root2npz.sh` at the same time.

There are two kinds of scripts (actually three, with an extra `ZZ_check_gamma_conv.C` whose usage will be mentioned later) starting with a number in general -- `.sh` and `.pbs`, `*.sh` are scripts that can be finish in seconds so can be run on login node, while `.pbs` are scripts that takes long time so should be submitted using PBS. And in general, all scripts you need to run in command line are all `.sh` files.

Scripts that starts without a number (always in the `*.pbs` form) in their name is not used for direct runs, they are called and used in other `.sh` scripts that starts with a number, so you should never run them on your own.

### `XX_resubmit_missing_root.sh`, `YY_resubmit_mission_npz.sh`
These are special scripts used when you submitted a large amount of jobs, but some of them failed. The code can help you find which of the jobs failed (by checking some missing output files compared to input files) and resubmit them.

### `ZZ_check_gamma_conv.C`
This is especially for plotting the gamma conversion length, the usage is a little complicated:

```bash
cd WCTE_Production/gamma
source ../config.sh
singularity shell -B $HOME:$HOME -B $MYLUSTRE:$MYLUSTRE ~/Images/softwarecontainer_workshop.sif

# in singularity
source /opt/entrypoint.sh
root -l

# in root
.L ZZ_check_gamma_conv.C
ZZ_check_gamma_conv();

# by default, the function uses output files from config.sh, and only analysis *0000.root.
# You can use `ZZ_check_gamma_conv(nullptr, false);` for analyzing all root files (a little bit slow though)

.q  	# exit from root
exit	# exit from singularity
```

Plus, you can run it with `nohup` when trying to analyzing all root files, which continues to run after you log out (This can still be killed if you are running for too long time on the login node, so a better way for a extremely large dataset, say > 0.3 mil events, is to write a `.pbs`):

```bash
nohup singularity exec \
  -B $HOME:$HOME -B $MYLUSTRE:$MYLUSTRE \
  ~/Images/softwarecontainer_workshop.sif \
  bash -c "source /opt/entrypoint.sh && \
           root -l -b -q 'ZZ_check_gamma_conv.C+(nullptr,false)'" \
  > gamma_conv.log 2>&1 &
```
And you can view the status of this job by `ps -u $USER | grep root`. 

However, this will produce some `ZZ_check_gamma_conv_C_ACLiC_dict_rdict.pcm`, `ZZ_check_gamma_conv_C.d` and `ZZ_check_gamma_conv_C.so` which tells ROOT’s **ACLiC** (Automatic Compiler of Libraries for Cling) to compile your macro into a shared library instead of just interpreting it. If you delete them, ROOT will just regenerate them next time you run `.L ZZ_check_gamma_conv.C+`.

### More Events
If you want to run on more events, you should always changing the `.mac` files `00_create_mac_and_submit_all.sh` generates (detailed usage is mentioned below). Modifying the number of events generated by each `.mac` file in `00_create_mac_and_submit_all.sh` is discouraged, since all the time limits in `.pbs` file is based on 10k events per job times 100 jobs, so you may need to adjust it based on your real number of events if you really wanna do so.

## Usage
### `.sh` Script
For `.sh` scripts, you can run them like this:
```bash
./some_number_*.sh
```

If your get some error named `Permission denied`, then you may don't have the permission to execute it. You can either use

```bash
shell ./some_number_*.sh

```
to run it, or run the command line below to change the mode:

```bash
chmod u+x some_number_*.sh
```

Specially, for `00_create_mac_and_submit_all.sh` you can always pass a `-f` to indicate how many `.mac` files you want to generate (by default it's 10). Basic Usage is listed below:

```bash
./00_create_mac_and_submit_all.sh -f 100
```

And for `01_run_validation.sh`, in default it displays event #42. But you can make it display any event you want by running the command line below in your shell:
```bash
./01_run_validation 137
```


## Modifying the scripts
If you want to add additional particles, simply ensure that the particle folder name matches the value you pass to the `-p` option. This convention makes it easier to check and debug your setup.

If you've modified many scripts under, say, the `e-/` folder and don't want to manually replicate the changes under `gamma/`, a convenient approach is to remove `gamma/` and copy `e-/` instead:

```bash
cd ~/WCTE_Production
rm -rf gamma/
cp -r e-/ gamma/
cd gamma/
mv MC_e-.pbs/ MC_gamma.pbs
```

Then, change all occurrences of `e-` to `gamma` and also `*_0_1200MeV*` to `*_10_1210MeV*` (for gamma, there's threshold of 1.022 MeV to convert into electron and positron, so the energy range should be shifted a little) using Vim:

```vim
:%s/e-/gamma/gc
:%s/_0_1200MeV/_10_1210MeV/gc
```

In `00_create_mac_and_submit_all.sh`, you should also change `python3 createWCSimFiles.py -p gamma -u 0,1200 -n 10000 -f "$F" -s 42` to `python3 createWCSimFiles.py -p gamma -u 10,1210 -n 10000 -f "$F" -s 42` to adjust the energy range.


Besides all these, there is a tiny difference of `00_create_mac_and_submit_all.sh` between e- and gamma: in gamma production scripts, you should use the gamma-conversion option (which will make the gamma converting into electrons and positrons as soon as they are generated), so that you can control the conversion vertex instead of the gamma emitting position (it usually takes ~ 48 cm for gamma to convert in water).

To achieve that, the script `00_create_mac_and_submit_all.sh` for gamma has an additional line:
```bash
find "$OUTPUT_PATH/gamma/mac/" -type f -name "wcsim*.mac" -exec sed -i 's|#/mygen/generator gps|#/mygen/generator gamma-conversion|' {} +
```
which changes `/mygen/generator gps` to `/mygen/generator gamma-conversion` in all "wcsim\*.mac" files

