slide:
	pandoc README.md --from markdown-yaml_metadata_block -is -t revealjs|sed s/simple.css/black.css/ > index.html
	git add -A; git ci -m Mod; git push origin master
