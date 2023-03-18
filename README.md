# Incomplete source files for [my blog](https://blog.lony.xyz)

This repo contains the basic files to build [my personal blog](https://blog.lony.xyz),
minus some personal upload tools (Makefile) and all content,
excluded for the following reasons:
- I do not want to commit every time I write a post.
- I do not want to spoil what I am writing about.
- I do not want my texts to be used by copilot.
- My writings do no have the same license as the code.

I am still looking for some solution to these problems that allows me to have a mixed system.
Maybe a git submodule in a private repo will do it.

## What is missing?

Basically:
- A directory `blog/_posts` with all the markdown files for the posts.
- A directory `blog/_bibliography` with all the bibtex files.
- A directory `blog/img` with all images for the posts.
- A directory `blog/js` with all scripts for the posts.
- All markdowns for the pages in `blog/*.md`.

## Building

You have to add content to the blog as you would with any other Jekyll blog.
Once that is done you can serve the blog with:
```sh
nix run .#serve
```
