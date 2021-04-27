let s:adoc_pdf_live = luaeval('require("adoc_pdf_live")')

if s:adoc_pdf_live.is_configured()
    " Start/stop the live preview
    command! AdocPdfLiveStart :call s:adoc_pdf_live.start()
    command! AdocPdfLiveStop :call s:adoc_pdf_live.stop()
    " Start the live preview and open the file
    command! AdocPdfLiveOpen :call s:adoc_pdf_live.open()

    " Set debug mode
    command! AdocPdfLiveDebug :call s:adoc_pdf_live.set_debug(1)
    command! AdocPdfLiveNoDebug :call s:adoc_pdf_live.set_debug(1)
    " Set the style file
    command! -nargs=1 AdocPdfStyle :call s:adoc_pdf_live.set_style('<args>')

    " Show the logs
    command! AdocPdfLiveLogs :call s:adoc_pdf_live.show_logs()

    " Compile on save
    augroup asciidocpdf_live
        autocmd!
        autocmd BufWritePost *.adoc :call s:adoc_pdf_live.compile(1)
    augroup END
endif
