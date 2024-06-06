# CLEAN BUILD DIRECTORIES
write-host -nonewline "Cleaning old build artifacts... `t"
new-item -type directory build -erroraction ignore > $null
new-item -type directory output -erroraction ignore > $null
remove-item build/* -erroraction ignore > $null
remove-item output/consolidated.pdf -erroraction ignore > $null
write-host "Done"

# CONSOLIDATE
write-host "Consolidating documents..."
nvim --clean --headless "+so compile.lua" +qa
write-host "`nConsolidated documents."

# CONVERT TO LATEX
write-host -nonewline "Converting to DocBook... `t`t"
asciidoctor -b docbook5 src/consolidated.adoc -o build/consolidated.xml
if (-not $?) { exit 1 }
write-host "Done"

write-host -nonewline "Converting to LaTeX... `t`t`t"
pandoc -d opts.yaml
if (-not $?) { exit 1 }
write-host "Done"

# pandoc escapes latex in docbooks & ieee is called ieeetr in bibtex
write-host -nonewline "Tweaking LaTeX file... `t`t`t"
(get-content build/consolidated.tex).replace("\{", "{").replace("\}", "}").replace("\textbackslash ", "\").replace("ieee", "ieeetr") | set-content build/consolidated.tex
write-host "Done"

# BUILD LATEX
cd build
try
{
	write-host -nonewline "Building LaTeX (1st pass)... `t`t"
	xelatex consolidated.tex > $null
	if (-not $?) { exit 1 }
	write-host "Done"

	write-host -nonewline "Building LaTeX (final pass)... `t`t"
	xelatex consolidated.tex > $null
	if (-not $?) { exit 1 }
	write-host "Done"
}
finally
{
	cd ..
}

# TITLE PAGE (I don't wanna recreate this in latex)
write-host -nonewline "Adding cover page... `t`t`t"
pdftk templates/cover.pdf build/consolidated.pdf cat output output/consolidated.pdf
write-host "Done"

write-host "`nDone building. See ./output/consolidated.pdf"
