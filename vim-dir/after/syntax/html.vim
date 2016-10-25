syn match htmlConditional  +<!--\[if[^]]*\]>+
syn match htmlConditional  +<!\[endif\]-->+
hi def link htmlConditional htmlPreProc

syn region htmlFold start=+<!--\[if[^]]*\]>+ end=+<!\[endif\]-->+ fold transparent keepend extend containedin=htmlH\d
