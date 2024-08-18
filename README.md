# Autograder Loader

This repository is an example "loader" for a gradescope autograder.
The code here is sufficient for cloning a "main" repository that
contains the actual autograder code and running a particular script
based on the gradescope submission metadata.  This makes it possible
to build only one autograder for an entire course, and to update the
autograder by simply pushing to a git repository.  


## Background

For an overview of how Gradescope autograders work, see Gradescope's
[documentation](https://gradescope-autograders.readthedocs.io/en/latest/specs/).
This "loader" only deals with the first steps of Gradescope's
process:  it is the first script that Gradescope will run when the
autograder starts, which will then load some assignment-specific
autograding code.

### How it works

When using a loader, your course's autograding environment will have
at least two repositories:
 - The *loader repository*:  which is this repository.  This is the
   code that you will package and upload to Gradescope.
 - The *main autograder repository* (also called the "instructor
   repository"): where most of your autograder will live.  [This
   repository](https://github.com/browncs-course-tools/gradescope-ag-main)
   is a template, which contains the code that the loader will run.
   From there, you will need to configure it to run your own
   autograder code.

The loader repository is designed to be as simple as possible: it
contains only enough code to download the main repository and decide
which assignment to run.  The next few sections describe the major
components and how to configure them.

> [!NOTE] The loader architecture requires you to have all of the
> autograder code in a single repository (ie, your main autograder
> repository).  Fetching from multiple repositories (or git
> submodules) is currently not supported.  If you want to do this, it
> will require changes to the loader--talk to Nick for details.

## Initial setup

### Configuring your system

To run and test the autograder and loader, your local system must have
the following:
 - 
 - `jq` (install with `brew install jq` or `sudo
   apt install jq`)
 - `rsync` (probably installed by default, check below)
 - Any other tools your particular course autograders may need
   (eg. Python, Go, Java, etc.)

> [!IMPORTANT] **If you use Windows**: you MUST use this autograder
> environment from inside WSL.  To set up your WSL installation, you
> must install java and python inside WSL.  If you are on a standard
> Ubuntu WSL, there is a good chance you already have a suitable
> Python version installed, but you
> may need to install Java on your own with `apt`.  

In the terminal where you intend to run the autograder, you can make
sure you have the appropriate tools like this:

```shell 
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


### Repository setup

Your course should have its own "fork" of both the loader and main
autograder repository, which you'll modify with your own code.
However, since Github doesn't allow private forks (and you'll *probably*
want your autograder code to be private), you can do this manually, as
follows:
   
1. **Clone** both repositories on your local system.  For easiest
   setup, we recommend cloning both repos into the same directory on
   your system (say, your "CS NNNN" folder), like this:

```
  - /home/youruser/csNNNN/
  |-- gradescope-ag-loader/      <------ This repository (the "loader" repo)
  |-- gradescope-ag-main/        <------ The "main autograder repository"
```

> [!WARNING] 
> If you are on Windows, you **MUST** clone **BOTH** repositories from
> **inside** WSL (ie, from a WSL terminal).  Depending on how your
> github authentication is set up, you may need to copy or create a new
> SSH key to do this.  If you clone using another method (git bash,
> cygwin git, Github Desktop), you may have issues with line endings.


2. On Github, create two new private repositories in your course org,
   then change the git remote on the repos you just cloned to point to
   your new repo URLs, like the example below.  Alternately, if you
   already have an existing repo to hold your autograder code, you can
   continue using it as your "main" autograder repo--just copy the
   files from the `gradescope-ag-main` repo into your own repository.
  
```
# Remove the original remote (ie, the template repo)
$ git remote rm origin 

# Set the remote URL to point to your new repo (eg. git@github.cm:brown-csci1680/gradescope-ag-loader.git)
$ git remote add origin <clone URL for your new repository>

# Push the code to the new remote
$ git push origin main 
```

You should now see the same code appear in your own repo, ready for
configuring for your course!

### Configuring the loader

To configure the loader for your course, do the following:

1. Open the file `source/early-env.sh`.  This file contains
   environment variables used by the loader to find your main
   autograder repository.  Update these to match your repository, for
   example:
   
```shell
# Clone URL for your main autograder repository  (NOTE:  this MUST be an SSH url
#(eg. starts with "git@github.com", NOT an "https://" URL)
INSTRUCTOR_REPO=git@github.com:browncs-course-tools/gradescope-ag-main.git

# Branch to clone on main autograder repo (can probably leave as main)
INSTRUCTOR_REPO_BRANCH=main

# Path to assignment configuration file in main repo (can leave as default)
INSTRUCTOR_CONFIG_REL_PATH=config/config.json
```

2. Open the file `source/setup.sh`.  This file is `setup.sh` script
   that Gradescope will run when building your autograder.  **Modify
   this file to install any dependencies necessary to run ALL of your
   course's autograder code**.  If you already have existing
   Gradescope autograders, doing this will involve combining the stuff
   you install in all your existing `setup.sh` scripts.
   
   The current `setup.sh` file is an example based on Nick's courses,
   so feel free to use this as a template.  For example, if your course uses
   Python, you can list all of your required Python modules in
   `setup/requirements.txt`, which the existing `setup.sh` script will
   install automatically.
   
3. In the main autograder repo, configure the *assignment
   configuration file* (eg. `config/config.json`), which tells the
   loader which code to run for each Gradescope assignment.  For
   instructions, see
   [here](https://github.com/browncs-course-tools/gradescope-ag-main/tree/main/config/README.md).
   
The loader should now be configured!  Before we test it, however,
you'll need to configure your local environment to run the loader in a
manner similar to Gradescope, as described in the next section.  

## Testing the autograder locally

### Local environment configuration (`env-local.sh`)

To run the autograder locally, you need to configure it with some
information about your system  in a file called `env-local.sh`.  This
config file tells the autograder how to find the main source
repository on your system, which normally occurs through another
process when run on Gradescope.

To set up your local configuration:
1. Copy the file `local-env.example.sh` to `env-local.sh`
2. Find the full path to your main source repository (ie, the
   *absolute path*).  You can do this from any directory using the
   `realpath` command, like this:
   
```
# Syntax:  realpath <path to main source repo> 
you@your-system:~/cs200/ag-loader realpath ../ag-main
/home/you/whatever/cs200/ag-main
```

3. Open your `env-local.sh` and set the variable
   `INSTRUCTOR_ROOT` to whatever path you found in the previous step,
   eg.:

```
INSTRUCTOR_ROOT=/home/you/whatever/ag-main
```

4. Save the file.  Your autograder should now be configured.

**Note**: Do not commit your `env-local.sh` file to the repository.
This file contains configuration info specific to your system, so it
should not be shared with others.

### Local Python environment setup (if your course uses Python)

If your course's autograders or student code rely on Python, you
should configure a local virtual environment to match the same
configuration used by the loader--this will make sure you are testing
in an environment similar to Gradescope.  To do this:

#### Setting up your environment

To set up your virtual environment, do the following:

1. `cd` to the root directory of this repository (ie, the loader)

2. Create a virtual environment in the `env` directory:  `python3 -m
   venv env`
   
3. Enter your new virtual environment, as described [here](#Entering-the-virtual-environment).
   next section
   
3. In your new virtual environment, install any Python modules
   required for your autograder.  If you set up the provided
   `requirements.txt` file earlier in these instructions, you can do
   this with:  `pip install -r source/requirements.txt`

The installation process should take a few minutes.  Once it
completes, you should be able to test your autograder!

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


## Running the autograder locally

Once you have configured the autograder, you're ready to run it!  To
do this:

1. If your autograder uses Python, make sure you are running in the
   [virtual environment](#Entering-the-virtual-environment)
   
2. Look up the name of the assignment you want to run in the main
   autograder config, located in `<main autograder
   repo>/config/config.json`.  Specifically, you need the value of the
   `name` field.
   
3. Run the autograder using `./local_run`, by providing the
   assignment's name (eg. `test-proj1`) and a path to the submission
   (eg. the student's code).  

```
# ./local_run <assignment name> <path to submission>
(env) you@your-system:~/cs200/autograder$ ./local_run test-proj1 .

# (In this example, we just give "." for the submission path since the
# demo assignment test-proj1 doesn't require any code.)

```

If the run was successful, you should see a bunch of output showing
the autograder's run process, followed by a bunch of JSON.  For
example, the `test-proj1` autograder should output something like
this:

```
{
  "visibility": "visible",
  "stdout_visibility": "visible",
  "tests": [
    {
      "name": "Example status check",
      "status": "passed",
      "output": "This is a test without a point value, used for pass/fail checks"
    },
    {
      "name": "Example test",
      "score": 1,
      "max_score": 1,
      "output": "This is another example test"
    }
  ]
}
```


The JSON follows [gradescope's autograder
specification](https://gradescope-autograders.readthedocs.io/en/latest/specs/#output-format)
and is normally passed back to gradescope to compute the total score
by adding up the total number of points from all the tests.  When
running locally, you need to interpret it yourself.  For comparison,
take a look at the same assignment on Gradescope and try to match up
the JSON to what you see in the web interface.  

The JSON output is stored in `results/results.json` so you can always
refer back to it.  For easier viewing or parsing, you can pass the
file to the utility `jq`.  For example, you can use `jq` to print out
the JSON with nice formatting like this:

```shell
$ jq < results/results.json
```

# Deploying the autograder to gradescope

Once you have confirmed the loader and main autograder repository work
on your local system, you can push the autograder to Gradescope.  To
do this:

## Creating an SSH deploy key

When running on Gradescope, the loader clones the main autograder
repository each time the autograder is executed.  To do this, the
loader needs an SSH deploy key to give it permission to clone the
repo.  You can find full instructions on this [here](https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys),
, but the following should be sufficient:

1. From the main directory of the loader repo, cd to the `source/ssh` directory

2. Create a key called `deploy_key`, like this:
```shell
you@host:csNNNN/ag-loader/source/ssh$ ssh-keygen -f deploy_key
```
3. When prompted, **leave the password blank**.  After two password
   prompts, the key should be created.

4. If the key generation was successful, you should see two files in
   the `source/ssh` directory: `deploy_key` (the private key) and
   `deploy_key.pub` (the public key).
   
5. Open the github page for your main autograder repository and select
   **Settings** > **Deploy keys** > **Add Deploy Key** and paste in
   the contents of `deploy_key.pub`.  Then, click **Add key**.  You
   should NOT give the deploy key write access.
   

> [!WARNING] **DO NOT** commit the deploy key files to your loader
> repsository, or any other repository.  This is for security reasons:
> it is not a good practice to commit credentials like SSH
> keys/passwords to git.  The loader repository is already configured
> to exclude the SSH key files via `.gitignore` file (preventing you
> from committing these files accidentally)--do not circumvent this,
> or try to commit the files some other way.
> 
> If your course will have multiplep people building and deploying the
> autograder, you can 1) have each person create their own deploy key
> and add it to the main repo, or 2) store the deploy key on a Google
> Drive folder and share it only with those who need access.

Once you have created your deploy key, you can now package and upload
your autograder to Gradescope!  

## Packaging and uploading to Gradescope

To deploy the loader Gradescope, we need to create a zip file with the
loader code.  Since the loader automatically downloads the latest
autograder for each assignment, you should only need to re-package the
loader when the loader configure itself changes, which should be rare
(once per semester, or possibly longer).  To do this:

1. If you have not done so already, create an SSH deploy key called
   `deploy_key` and place it in the `source/ssh` directory of this
   repository.  Make sure these files are present before continuing.

2. Run the `./package` script from the main directory of this
   repository.  This should create a file called
   `export/autograder-loader.zip` located in the `export` directory
   
3. Upload `autograder-loader.zip` to your Gradescope assignment and
   try it out!  If you're just testing the initial `test-proj1`
   assignment, there's no required code as input, so you can just
   upload any file (even a blank PDF).  


## Attribution

Components of this autograder are based on components of autograders
from CS200 (first developed by Milda Zizyte) and CS1660 (original
development by Zachary Espiritu)

