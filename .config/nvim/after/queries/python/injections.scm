; extends

; shout out to https://github.com/milanglacier/nvim/blob/master/after/queries/python/injections.scm
(((string_content) @sql
                   (#lua-match? @sql "^%s*--sql")) @injection.content
 (#set! injection.language "sql"))

(
  string
    (
      (string_content)
      ( (interpolation) (string_content))*
    ) @injection.content
    (#match? @sql)
    (#set! injection.language "sql")
    ;(#set! injection.include-children)
    ;(#set! injection.combined)
)
