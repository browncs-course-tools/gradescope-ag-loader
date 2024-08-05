# Autograder Loader

This repository is an example "loader" for a gradescope autograder.
The code here is sufficient for cloning a "main" repository that
contains the actual autograder code and running a particular script
based on the gradescope submission metadata.  This makes it possible
to build only one autograder for an entire course, and to update the
autograder by simply pushing to a git repository.  


## Background

For an overview of how Gradescope autograders work, Gradescope's
[documentation](https://gradescope-autograders.readthedocs.io/en/latest/specs/)
is *super* helpful. This should give you a basic idea of the
input/output contract of a Gradescope autograder.

## Initial setup

Before starting, your local system must have the following:
 - 
 - `jq` (install with `brew install jq` or `sudo
   apt install jq`)
 - `rsync` (probably installed by default, check below)

> [!IMPORTANT]
> **If you use Windows**: you MUST use the autograder from inside WSL.
> To set up your WSL installation, you must install java and python
> inside WSL.  If you are on a standard Ubuntu WSL, there is a good
> chance you already have a suitable Python version installed, but you
> may need to install Java on your own with `apt`.  

### Testing your setup

In the terminal where you intend to run the autograder, you can make
sure you have the appropriate tools like this:

```shell 
# Python (need 3.9 or higher)
$ python3 --version
Python 3.11.5

# Check for jq (any version is fine)
$ jq --version
jq-1.7

# Check for rsync (any version is fine)
$ rsync --version
rsync  version 3.2.7  protocol version 31
[. . . Truncated . . .]
```

If you are missing anything, try to install it using your system's
package manager (`apt` in Ubuntu or WSL; if you are on MacOS, it's
recommended to install and use homebrew with `brew`)

### Recommended filesystem structure / repositories

Working with the autograder involves at least two repositories:
 1. The *main source repository* (eg. `source-main`), where all the
    solution code lives
 2. This repository, called the *autograder repository* 

You should clone both this repository and the main source repository
into the same directory on your system (say, your "CS200" folder),
like this:
```
  - /home/youruser/cs200/
  |-- autograder/      <------ This repository
  |-- source-main/     <------ Main source repository
```

To clone each repository, by running something like the following:

```
# Clone this repository
$ git clone git@github.com:brown-csci0200/autograder.git

# Clone the main source repository
$ git clone git@github.com:brown-csci0200/source-main.git 
```

> [!WARNING] 
> If you are on Windows, you **MUST** clone **BOTH** repositories from
> **inside** WSL (ie, from a WSL terminal).  Depending on how your
> github authentication is set up, you may need to copy or create a new
> SSH key to do this.  If you clone using another method (git bash,
> cygwin git, Github Desktop), you may have issues with line endings.

### Setting up your environment

Much of the autograder framework depends on Python, which uses
dependencies from a virtual environment.  To set up your virtual
environment, do the following:

1. `cd` into the autograder repository

2. Create a virtual environment in the `env` directory:  `python3 -m
   venv env`

3. Install dependencies:  `pip install -r source/requirements.txt`

The installation process should take a few minutes.  Once it
completes, you should enter the virtual environment, as described in
the next section.

### Entering the virtual environment

Once your virtual environment has been configured, you can enter it by
running the script `bin/activate` inside the environment directory
(`env`, if you followed the instructions above), as
follows:

```
$ source env/bin/activate
```

This should produce no output, but your terminal prompt should change
indicating you are in the virtual environment.  This will ensure that
Python can load all the dependencies for the autograder.

### Local configuration (`local-env.sh`)

To run the autograder locally, you need to configure it with some
information about your system  in a file called `local-env.sh`.  This
config file tells the autograder how to find the main source
repository on your system, which normally occurs through another
process when run on Gradescope.

To set up your local configuration:
1. Copy the file `local-env.example.sh` to `local-env.sh`
2. Find the full path to your main source repository (ie, the
   *absolute path*).  You can do this from any directory using the
   `realpath` command, like this:
   
```
# Syntax:  realpath <path to main source repo> 
you@your-system:~/cs200/autograder$ realpath ../source-main
/home/you/whatever/cs200/source-main
```

3. Open your `local-env.sh` and set the variable
   `INSTRUCTOR_LOCAL_REPO` to whatever path you found in the previous step,
   eg.:

```
INSTRUCTOR_LOCAL_REPO=/home/you/whatever/cs200/source-main
```

4. Save the file.  Your autograder should now be configured.

**Note**: Do not commit your `local-env.sh` file to the repository.
This file contains configuration info specific to your system, so it
should not be shared with others.

## Running the autograder locally

Once you have configured the autograder, you're ready to run it!  To
do this:

1. Make sure you are running in the [virtual
   environment](#Entering-the-virtual-environment)
   
2. Look up the name of the assignment you want to run in the main
   autograder config, located in `<main source
   repo>/autograder-support/config.json`.  For example, HW2's
   implementation assignment is called `hw2-dll`, and its testing
   assignment is called `hw2-dll-wc`.  
   
3. Run the autograder using `./local_run`, like this:

```
(env) you@your-system:~/cs200/autograder$ ./local_run hw02-dll
```

By default `./local_run` runs the autograder using the solution code
from the main source repository in place of a student submission.  If
you want to run on a different submission, it's easy to do so, see the
next section for details.

If the run was successful, you should see a bunch of output showing
the autograder's run process, followed by a bunch of JSON.  The JSON
follows [gradescope's autograder
specification](https://gradescope-autograders.readthedocs.io/en/latest/specs/#output-format)
and is normally passed back to gradescope to compute the score.  When
running locally, you need to interpret it yourself.  For comparison,
take a look at the same assignment on Gradescope and try to match up
the JSON to what you see in the web interface.  

The JSON output is stored in `results/results.json` for easier
viewing.  Note that **even on the solution code, not all autograder
tests may pass**, particularly for the wheat/chaff tests.

### Running on a separate submission

By default, `local_run` will run the autograder using the solution
code as the student submission.  To run on a separate submission (say,
one that you download from Gradescope with the "Download submission"
button, you can use the `--submission` option, like this:

```
# Run the autograder for HW2 (implementation version) on external submission
$ ./local_run hw02-dll --submission path/to/submission
```

Where `path/to/submission` should point to a directory containing the
files that a student would upload to Gradescope.  All of the files
MUST be in the same directory (ie, no src/sol/test structure), just
like when a student uploads to gradescope.

## Autograder architecture

The autograder is composed of a several scripts to configure, prepare,
and run tests on student submissions.  This section describes the most
important scripts and their workflow.

#### Normal run scripts

The following scripts are involved in the autograder's normal
operation, ie. the process of running our autograder tests on student
submissions.


#### Setup scripts

These scripts are used by Gradescope to build the autograder.  These
are run once when you upload the autograder zip file to gradescope.
Gradescope uses them to build a container image, which is stored and
run each time a student uploads a submission.

- **`source/setup.sh`**: when uploading the autograder, Gradescope
  will run this to set up the container image with any dependencies
  the autograder uses.  If you need to add or change the set of
  packages installed in the autograder or their versions, change it
  here
- **`source/requirements.txt`: List of Python modules required to run
  the autograder framework and any Python assignment code.  This file
  will necessarily contain a superset of the python modules that
  students are required to install

# Autograder management tasks

The following sections describe various tasks for working with the
autograder.  Use these as you need them.


## Packaging and uploading to Gradescope

To deploy an autograder to Gradescope, you need to create a zip file
containing the autograder code.  This should only be necessary when
the autograder framework itself changes--the autograder will
automatically fetch the latest version of the solutions and test code
from the main source repository on each run.

**One-time setup**: The autograder requires an [SSH deploy
key](https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys)
to clone the main source repository.  See the section "creating a
deploy key" for instructions on how to do this.

To package the autograder for upload:

1. Make sure you have our SSH deploy key in the `source/ssh-key`
   directory of this repo, as described above.
   
2. Run the `./package` script from the main directory of this
   repository.  This should create a file called
   `combined-autograder.zip` located in the `zipped` directory
   
3. Upload `combined-autograder.zip` to the gradescope assignment


### Uploading large data

Some assignments (particularly Search) may involve data that is too
large to move via Github. In this case, before uploading, you should
instead add required data files to the `source/large_data` folder so
that when the autograder files are zipped and uploaded, the dataset is
included. For instance, for Search, MedWiki.xml and BigWiki.xml should
be downloaded locally into `source/wikis/` before zipping and
uploading.

## Creating a deploy key

As discussed earlier, all of the assignment-specific tests run by the
autograder live in the main source repository, allowing you to change and push
tests without having to repackage and upload the autograder to
Gradescope.   To make this work, the autograder needs to clone the
main source repo each time it runs.

To allow the autograder script to access the main source repo, you
must use an SSH key, which Github calls a **deploy key**. You can read
Github's official tutorial
[here](https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys),
though the following steps should be sufficient:

1. Make an ssh key (i.e. `ssh-keygen -t rsa -b 4096 -C
   your@email.here`) on your computer called `deploy_key`. No password
   is needed.
2. Place the two files, `deploy_key` and `deploy_key.pub` in
   `source/ssh-key`. To make this easier for yourself, you could
   simply run the ssh-keygen command from the ssh-key directory.
3. In your instructor repository settings on Github, click
   **Settings** then **Deploy Keys**, and select **Add Deploy
   Key**. Paste the contents of `deploy_key.pub` and click **Add
   Key**. You should not give the deploy key write access.

You will notice that git does not track the two deploy key files you
just added. This is intended--for security reasons, it is not a good
practice to commit credentials like passwords and SSH keys to git.  As
long as the files are present locally, they will be included in the
zip uploaded to gradescope.

## Attribution

Components of this autograder are based on components of autograders
from CS200 (first developed by Milda Zizyte) and CS1660 (original
development by Zachary Espiritu)
