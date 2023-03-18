publish:
	nix run .
	rsync -a --delete ./_site/ linode:/var/www/blog.lony.xyz/
