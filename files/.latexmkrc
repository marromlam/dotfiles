# $pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode';
# @generated_exts = (@generated_exts, 'synctex.gz');

# Use pdflatex
$pdf_mode = 1;
$force_mode = 1;

# Add options to pdflatex
# $pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1';
# $pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 -file-line-error -recorder %O %S';
# $pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 %O "\\AtBeginDocument{\\makeatletter\\def\\Ginclude@graphics##1{\\IfFileExists{##1}{\\includegraphics{##1}}{\\fbox{Missing file: ##1}}}\\makeatother}\\input{%S}"';
$pdflatex = "pdflatex -synctex=1 -halt-on-error %O %S";



# Put all aux files into .build/
$aux_dir = '.build';
# $out_dir = '.build';

# But keep the final PDF next to the .tex file
$emulate_aux_dir = 1;


# Allow missing figures: force LaTeX to continue if graphics are missing
$latex = 'pdflatex -interaction=nonstopmode -synctex=1 -file-line-error -recorder "\\AtBeginDocument{\\renewcommand{\\Gin@extensions}{.pdf,.png,.jpg,.eps,.ps}}\\AtBeginDocument{\\renewcommand{\\Ginclude@graphics}[2][]{\\fbox{Missing: ##2}}}\\input %S"';
