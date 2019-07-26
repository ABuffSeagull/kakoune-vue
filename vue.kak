# Vue file
# ‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.vue %{
	set-option buffer filetype vue
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook -group vue-highlight global WinSetOption filetype=vue %{ add-highlighter window/vue ref vue }

hook global WinSetOption filetype=vue %{
	require-module vue

	hook window ModeChange insert:.* -group vue-hooks  vue-filter-around-selections
	hook window InsertChar '>' -group vue-indent vue-indent-on-greater-than
	hook window InsertChar \n -group vue-indent vue-indent-on-new-line
	set  window comment_line        '//'
	set  window comment_block_begin '<!--'
	set  window comment_block_end   '-->'
}

hook -group vue-highlight global WinSetOption filetype=(?!vue).* %{ remove-highlighter window/vue }

hook global WinSetOption filetype=(?!vue).* %{
	remove-hooks window vue-indent
	remove-hooks window vue-hooks
}

provide-module vue %[

try %{
	require-module html
	require-module css
	require-module javascript
	require-module pug
	require-module scss
	require-module less
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/vue regions
add-highlighter shared/vue/tag  region  <          >  regions
add-highlighter shared/vue/pug  region  <template\b.*?lang="pug".*?>\K      (?=</template>) ref pug
add-highlighter shared/vue/html region  <template\b.*?>\K                   (?=</template>) ref html
add-highlighter shared/vue/scss region  <style\b.*?lang="scss".*?>\K        (?=</style>)    ref scss
add-highlighter shared/vue/sass region  <style\b.*?lang="sass".*?>\K        (?=</style>)    ref sass
add-highlighter shared/vue/less region  <style\b.*?lang="less".*?>\K        (?=</style>)    ref less
add-highlighter shared/vue/css  region  <style\b.*?>\K                      (?=</style>)    ref css
add-highlighter shared/vue/ts   region  <script\b.*?lang="ts".*?>\K (?=</script>)   ref typescript
add-highlighter shared/vue/js   region  <script\b.*?>\K                     (?=</script>)   ref javascript

add-highlighter shared/vue/tag/base default-region group
add-highlighter shared/vue/tag/ region '"' (?<!\\)(\\\\)*" fill string
add-highlighter shared/vue/tag/ region "'" "'"             fill string

add-highlighter shared/vue/tag/base/ regex \b([a-zA-Z0-9_-]+)=? 1:attribute
add-highlighter shared/vue/tag/base/ regex </?(\w+) 1:keyword

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden vue-filter-around-selections %{
	# remove trailing white spaces
	try %{ execute-keys -draft -itersel <a-x> s \h+$ <ret> d }
}

define-command -hidden vue-indent-on-greater-than %[
	evaluate-commands -draft -itersel %[
		# align closing tag to opening when alone on a line
		try %[ execute-keys -draft <space> <a-h> s ^\h+<lt>/(\w+)<gt>$ <ret> {c<lt><c-r>1,<lt>/<c-r>1<gt> <ret> s \A|.\z <ret> 1<a-&> ]
	]
]

define-command -hidden vue-indent-on-new-line %{
	evaluate-commands -draft -itersel %{
		# preserve previous line indent
		try %{ execute-keys -draft \; K <a-&> }
		# filter previous line
		try %{ execute-keys -draft k : vue-filter-around-selections <ret> }
		# indent after lines ending with opening tag
		try %{ execute-keys -draft k <a-x> <a-k> <[^/][^>]+>$ <ret> j <a-gt> }
	}
}

]
