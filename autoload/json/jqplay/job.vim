" ==============================================================================
" Integration of jq (the command-line JSON processor) into Vim
" File:         autoload/json/jqplay/job.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-jqplay
" Last Change:  Sep 3, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

function! json#jqplay#job#filter(in_buf, start_line, end_line, out_buf, jq_cmd) abort
    if exists('g:jq_job') && job_status(g:jq_job) ==# 'run'
        call job_stop(g:jq_job)
    endif

    let opts = {
            \ 'in_io': 'buffer',
            \ 'in_buf': a:in_buf,
            \ 'in_top': a:start_line,
            \ 'in_bot': a:end_line,
            \ 'out_io': 'buffer',
            \ 'out_buf': a:out_buf,
            \ 'err_io': 'out'
            \ }

    " https://github.com/vim/vim/issues/4718
    if has('patch-8.1.1757')
        call extend(opts, {
                \ 'err_io': 'pipe',
                \ 'err_cb': {_, msg -> appendbufline(a:out_buf, '$', '// ' . msg)}
                \ })
    endif

    " See Issue: https://github.com/vim/vim/issues/4688
    try
        let g:jq_job = job_start([&shell, &shellcmdflag, a:jq_cmd], opts)
    catch /^Vim\%((\a\+)\)\=:E631:/
    endtry
endfunction

function! json#jqplay#job#stop(...) abort
    if exists('g:jq_job')
        return job_stop(g:jq_job, a:0 ? a:1 : 'term')
    endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
