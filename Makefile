publish:
	nix run .
	rsync -a --delete ./_site/ root@195.201.231.120:/srv/blog.sergio.sh/
	ssh root@195.201.231.120 'chmod -R 755 /srv/blog.sergio.sh/'
