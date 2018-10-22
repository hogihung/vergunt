# README


This docker image contains the following development tools:

  - Vim             [8.1.477]
  - Elixir          [1.7.3]
  - RVM             [1.29.4]
  - Ruby            [2.5.1 (2.4.1, 2.3.5)]
  - Go              [1.11.1]
  - Git             [2.19.1]
  - Ubuntu (for OS) [18.10]
  - NodeJS          [10.12.0]
  - Tmux            [2.7]


## CLONE THE REPO

```
cd /path/to/your/docker/projects
git clone https://github.com/hogihung/vergunt.git
cd vergunt
```



## BUILD THE DOCKER IMAGE

```
docker build -t vergunt:1.0.0
```



## RUN THE IMAGE (in a container)

```
# User the command 'docker images' to get a listing of images, including the new one created
docker run -it --name=vergunt-dev --hostname=devbox --rm [image-id]

*Note: the --rm flag is optional and it will remove the container on exit.


# Running the image and mounting your local file system into the container:
docker run -it --name=vergunt-dev --hostname=devbox --rm \
-v /path/to/local/dir:/usr/local/development/dir  [image-id]

*Note: Windows uses need to replace the \ character with the ^ character when
       spanning multiple lines.
```



## KNOWN ISSUES

At this time there is an issue when trying to run elixir as it is appended to the
end of the PATH.  To work around this issue, I've created two aliases which are
located in the $HOME/.bashrc.local file.

On initial image spin up, if you want to use elixir, use the following:

  - elixir_go

This alias will source the current kiex elixir env file and setup the path so
that elixir is comes first.

To reset things so RVM/Ruby work, use the following:

  - reset_path

This will restore the PATH back to its' original state.



## POST IMAGE BUILDING - UPDATES/REPAIRS

```
# Assume previous docker run step was executed, then run any commands/installs
# or make config changes that you want to persist into an image created from
# this container.

{--none at this time--}

```



## SAVE UPDATED CONTAINER AS NEW IMAGE

```
docker commit --message "some message here" [running-container-id] hub-repo-name/image-name:x.y.z

# Example:
docker commit --message "Fix elixir_go and reset_path scripts" vergunt-dev hogihung/vergunt:1.0.1
```

