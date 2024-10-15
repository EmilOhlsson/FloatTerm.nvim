if exists("g:loaded_FloatTerm")
	finish
endif

let g:loaded_FloatTerm = 1

lua require("FloatTerm").setup({ debug = false })
