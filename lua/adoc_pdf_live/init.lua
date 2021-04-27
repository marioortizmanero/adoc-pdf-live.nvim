local adoc_pdf_live = {}

local function log(txt)
    if adoc_pdf_live.options.debug then
        print(txt)
    end

    local date = vim.fn.trim(vim.fn.system("date"))
    txt = string.format("[%s] %s", date, txt)
    adoc_pdf_live.logs = adoc_pdf_live.logs .. "\n" .. txt
end

-- Wrapper to run commands with or without stdout. May be ran in the background
-- when `run_bg` is set to `1`.
local function exec(cmd, run_bg)
    cmd = cmd .. (run_bg and " &" or "")
    local out = vim.fn.trim(vim.fn.system(cmd))

    log(string.format("%s: %s", cmd, out))

    return out
end

local function with_defaults(options)
    return {
        enabled = options.enabled or false,
        -- The viewer command must be like `command <file>`
        viewer = options.viewer or 'zathura',
        binary = 'asciidoctor-pdf',
        params = options.params or '',
        -- Shows the command stdout when activated
        debug = options.debug or false,
        style = options.style or '',
        style_regex = options.style_regex or 'style\\.ya?ml'
    }
end

-- Tries to find a style file. It will only use the first one given by `find`
-- in the current directory, and it may be configured manually later.
local function find_style()
    if adoc_pdf_live.options.style ~= "" then return end

    log("Looking for styles automatically")

    -- TODO: if the directory is too large this will block
    local cmd = string.format("find . -regex '.*/%s' -regextype sed -print -quit", adoc_pdf_live.options.style_regex)
    local found = exec(cmd, false)

    if #found > 0 then
        log("Found style: " .. found)
        adoc_pdf_live.options.style = found
    else
        log("Couldn't find a style")
    end
end

function adoc_pdf_live.setup(options)
   adoc_pdf_live.options = with_defaults(options or {})

    -- Initializing logging
   adoc_pdf_live.logs = ""

   -- Auto start-up
   if adoc_pdf_live.options.enabled then
       adoc_pdf_live.start()
   end
end

function adoc_pdf_live.is_configured()
   return adoc_pdf_live.options ~= nil
end

function adoc_pdf_live.is_enabled()
   return adoc_pdf_live.is_configured() and adoc_pdf_live.options.enabled
end

-- Compiles the document, in the background when `run_bg` is set to 1.
function adoc_pdf_live.compile(run_bg)
    if not adoc_pdf_live.is_enabled() then return end

    local params = adoc_pdf_live.options.params
    if #adoc_pdf_live.options.style > 0 then
        params = params .. " -a pdf-style=" .. adoc_pdf_live.options.style
    end

    local cmd = string.format("%s %s '%s'", adoc_pdf_live.options.binary, params, vim.fn.expand("%r"))
    exec(cmd, run_bg)
end

-- Starts the live preview without opening the PDF viewer
function adoc_pdf_live.start()
    if not adoc_pdf_live.is_configured() then return end

    log("Starting live preview")
    adoc_pdf_live.options.enabled = true
    find_style()
    adoc_pdf_live.compile(true)
end

-- Starts the live preview, and once the first run is complete a pdf viewer is
-- opened with the document.
function adoc_pdf_live.open()
    if not adoc_pdf_live.is_configured() then return end

    -- This compilation can't be asynchronous, or we aren't guaranteed that
    -- a compiled file is available by the time the viewer starts.
    adoc_pdf_live.options.enabled = true
    find_style()
    adoc_pdf_live.compile(false)

    local cmd = string.format("%s '%s.pdf'", adoc_pdf_live.options.viewer, vim.fn.expand("%:r"))
    exec(cmd, true)
end

-- Stops the live preview if it wasn't already.
function adoc_pdf_live.stop()
    if not adoc_pdf_live.is_enabled() then return end

    log("Stopping live preview")
    adoc_pdf_live.options.enabled = false
end

function adoc_pdf_live.set_style(file)
    log("Setting " .. file .. " as style")
    adoc_pdf_live.options.style = file
    adoc_pdf_live.start()
end

function adoc_pdf_live.set_debug(val)
    log("Setting debug to " .. val)
    adoc_pdf_live.options.debug = val
end

function adoc_pdf_live.show_logs()
    print(adoc_pdf_live.logs)
end

return adoc_pdf_live
