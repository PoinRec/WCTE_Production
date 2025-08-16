# WCTE_Production
Scripts to run WCTE Monte Carlo Simulations on idark and to convert the output .root files from WCSim to .h5 files for further WatChMaL training.

There are several different folders under `WCTE_Production/` (e.g. `electron/`, `gamma/`), representing scripts for generating different particles. For now, there are only scripts for cases that the pariticles are uniformly distributed -- both homogeneous and isotropic.


## Dependencies
This repo needs environment for both [**WatChMaL**](https://github.com/WatChMaL/WatChMaL) and [**WCSim**](https://github.com/WCSim/WCSim) so you may need twocontainer images.

I highly recommend `software_workshop.sif` for the image of WCSim since I source all the necessary environment variables using `source /opt/entrypoint.sh` in my scripts. But if you want to use other images, you may need to modify that.


## Scripts
For most scripts under the subfolder like `electron`, they start with a number (e.g. `00_create_mac_files,sh`, `03_run_conversion2npz.pbs`) indicating the sequence you should execute the shell script in. The Script `02_run_validation.pbs` is not necessary for the whole pipeline of Monte Carlo simulation, they are just inserted in a proper position they should be executed. But you can also run it with `03_run_conversion2npz.pbs` at the same time. 

Plus, the script `99_clear.sh` under `WCTE_Production` is a script to clean up all files generated in the process of simulation under folders like `fig/`, `log/`, `mac/`, `out/`, `shell/` and some geofiles which are usually in the form of `geo*.txt`. The number 99 is just an indication that you should run this script after the whole process of simulation. Usually you need to run it if you want to run MC simulation 

There are two kinds of scripts starting with a number in general -- `.sh` and `.pbs`, `*.sh` are scripts that can be finish in seconds so can be run on login node, while `.pbs` are scripts that takes long time so should be submitted using PBS.

Scripts that starts without a number in their name is not used for direct runs, they are called and used in other scripts that starts with a number, so you should never run them on your own.

### More Events
If you want to run on more events, you can modify `00_create_mac_files.sh` But all time limits in `.pbs` file is based on 1k events per job, so you may need to adjust it based on your real number of events.

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

### `.pbs` Script
For `.pbs` scripts, you can run them like this:
```bash
qsub some_number_*.sh
```

Specially, for `02_run_validation.pbs`, in default it displays event #42. But you can make it display any event you want by running the command line below in your shell:
```bash
qsub -v EVENT_ID=137 02_run_validation.pbs
```



