publish:
	nix run .
	rsync -a --delete ./_site/ linode:/var/www/blog.lony.xyz/
	ssh linode 'chmod -R 755 /var/www/blog.lony.xyz'
